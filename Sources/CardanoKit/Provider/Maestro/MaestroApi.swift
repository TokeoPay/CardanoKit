//
//  MaestroApi.swift
//  CardanoKit
//
//  Created by Gavin Harris on 16/9/2025.
//

import Foundation
import Alamofire


public protocol MaestroAPIProtocol {
    func request<T: Decodable & Sendable, E: Decodable & Sendable>(
        path: String,
        responseType: T.Type,
        errorType: E.Type
    ) async throws -> T
    
    func requestPost<T: Decodable & Sendable, E: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        responseType: T.Type,
        errorType: E.Type
    ) async throws -> T
}


public struct MaestroConfig: Sendable {
    public let apiKeyProvider: APIKeyProvider
    public let baseURL: URL
    
    public init(apiKeyProvider: @escaping APIKeyProvider, baseURL: URL) {
        self.apiKeyProvider = apiKeyProvider
        self.baseURL = baseURL
    }
}

public enum MaestroError<E: Decodable & Sendable>: Error, Sendable {
    case rateLimited
    case api(E)             // Decoded API error model
    case network(AFError?)  // General transport error
}

/// Encodable wrapper
public struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }
    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// MARK: - Actor-based API client

public actor MaestroAPI: MaestroAPIProtocol {
    private let config: MaestroConfig
    private let session: Session
    
    // Rate limiting
    private var requestsPerSecondLimit: Int?
    private var remainingRequestsThisSecond: Int?
    
    // Queue of waiters when rate limit exceeded
    private var waiters: [CheckedContinuation<Void, Error>] = []
    
    public init(config: MaestroConfig) {
        self.config = config
        self.session = Session()
    }
    
    // MARK: - Public Async Methods
    
    public func request<T: Decodable & Sendable, E: Decodable & Sendable>(
        path: String,
        responseType: T.Type,
        errorType: E.Type
    ) async throws -> T {
        try await performRequest(path: path,
                                 method: .get,
                                 body: nil,
                                 responseType: responseType,
                                 errorType: errorType)
    }
    
    public func requestPost<T: Decodable & Sendable, E: Decodable & Sendable, B: Encodable & Sendable>(
        path: String,
        body: B,
        responseType: T.Type,
        errorType: E.Type
    ) async throws -> T {
        try await performRequest(path: path,
                                 method: .post,
                                 body: body,
                                 responseType: responseType,
                                 errorType: errorType)
    }
    
    // MARK: - Core Request
    
    private func performRequest<T: Decodable & Sendable, E: Decodable & Sendable>(
        path: String,
        method: HTTPMethod,
        body: Encodable?,
        responseType: T.Type,
        errorType: E.Type
    ) async throws -> T {
        // await until quota allows
        try await waitForQuota()
        
        // resolve api key
        let apiKey = await config.apiKeyProvider()
        
        guard let url = config.baseURL.appendingPathOrQuery(path) else {
            fatalError("Invalid URL string: \(path)")
        }
        
        let headers: HTTPHeaders = [
            "api-key": apiKey,
            "Content-Type": "application/json"
        ]
        
        var dataRequest: DataRequest
        if let body = body {
            var urlRequest = URLRequest(url: url)
            urlRequest.method = method
            urlRequest.headers = headers
            urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            dataRequest = session.request(urlRequest)
        } else {
            dataRequest = session.request(url, method: method, headers: headers)
        }
        
        // Wait for Alamofire async result
        return try await withCheckedThrowingContinuation { continuation in
            dataRequest
                .validate()
                .responseDecodable(of: responseType) { response in
                    Task { await self.updateRateLimits(from: response.response) }
                    
                    switch response.result {
                    case .success(let decoded):
                        continuation.resume(returning: decoded)
                    case .failure:
                        if let data = response.data,
                           let apiError = try? JSONDecoder().decode(errorType, from: data) {
                            continuation.resume(throwing: MaestroError<E>.api(apiError))
                        } else {
                            continuation.resume(throwing: MaestroError<E>.network(response.error))
                        }
                    }
                }
        }
    }
    
    // MARK: - Rate Limiting
    
    private func waitForQuota() async throws {
        if canSendRequest() {
            remainingRequestsThisSecond? -= 1
            return
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            waiters.append(continuation)
        }
    }
    
    private func updateRateLimits(from httpResponse: HTTPURLResponse?) {
        guard let headers = httpResponse?.allHeaderFields as? [String: String] else { return }
        
        if let limit = headers["X-RateLimit-Limit-Second"], let v = Int(limit) {
            requestsPerSecondLimit = v
        }
        if let remaining = headers["X-RateLimit-Remaining-Second"], let v = Int(remaining) {
            remainingRequestsThisSecond = v
        }
        
        // Schedule quota reset if not already active
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1s
            self.resetQuota()
        }
    }
    
    private func resetQuota() {
        remainingRequestsThisSecond = requestsPerSecondLimit
        flushWaiters()
    }
    
    private func flushWaiters() {
        guard let remaining = remainingRequestsThisSecond, remaining > 0 else { return }
        var allowed = remaining
        while allowed > 0 && !waiters.isEmpty {
            let cont = waiters.removeFirst()
            cont.resume()
            allowed -= 1
        }
        remainingRequestsThisSecond = allowed
    }
    
    private func canSendRequest() -> Bool {
        if let remaining = remainingRequestsThisSecond {
            return remaining > 0
        }
        return true // optimistic first request
    }
}


extension URL {
    /// Safely appends either a plain path or a path-with-query to the base URL.
    /// - Parameter pathOrAbsolute: A string starting with "/" that may optionally include a query string.
    /// - Returns: A new `URL` or `nil` if the result is invalid.
    func appendingPathOrQuery(_ pathOrAbsolute: String) -> URL? {
        if pathOrAbsolute.contains("?") || pathOrAbsolute.contains("#") {
            // Treat as full path + query
            return URL(string: pathOrAbsolute, relativeTo: self)
        } else {
            // Safe for pure paths
            return self.appendingPathComponent(pathOrAbsolute)
        }
    }
}
