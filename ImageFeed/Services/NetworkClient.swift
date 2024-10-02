//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 03/10/2024.
//

import Foundation

final class NetworkClient {
    
    var data: Data?
    
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
                    print("Profile ERROR from decoding")
                    completion(.failure(NetworkError.urlRequestError))
                }
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchData(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Profile ERROR from error")
                completion(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print("Profile ERROR from code")
                completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.decodingError))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}
