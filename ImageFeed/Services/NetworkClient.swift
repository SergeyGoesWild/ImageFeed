//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 03/10/2024.
//

import Foundation

final class NetworkClient {
    
    var task: URLSessionDataTask?
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        
        fetchData(for: request) { data in
            switch data {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let convertedData = try decoder.decode(T.self, from: data)
                    completion(.success(convertedData))
                }
                catch {
                    print("LOG: [NetworkClient] Decoding error: \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(CommonError.decodingError))
                }
            case .failure(let error):
                print("LOG: [NetworkClient] Error in fetchData")
                self.task?.cancel()
                completion(.failure(error))
            }
        }
    }
    
    func fetchData(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("LOG: [NetworkClient]: dataTask returned error with code: \(error.errorCode ?? 0)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print("LOG: [NetworkClient]: response error with code \(response.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse {
                self.checkRateLimit(response: response)
            } else {
                print("Failed to cast URLResponse to HTTPURLResponse.")
            }
            
            guard let data = data else {
                print("LOG: [NetworkClient]: dataTask error while unwrapping data")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.dataError))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
        guard let networkTask = task else { return }
        networkTask.resume()
    }
    
    func checkRateLimit(response: HTTPURLResponse) {
        if let limit = response.allHeaderFields["X-Ratelimit-Limit"] as? String,
           let remaining = response.allHeaderFields["X-Ratelimit-Remaining"] as? String,
           let reset = response.allHeaderFields["X-Ratelimit-Reset"] as? String {
            print("Limit: \(limit)")
            print("Remaining: \(remaining)")
            print("Resets at: \(reset)")
        } else {
            print("Rate limit information not found in headers.")
        }
    }
}
