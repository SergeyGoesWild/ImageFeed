//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 20/09/2024.
//

import Foundation
import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError
    case urlSessionError
    case urlUnwrapError
    case dataError
}

enum CommonError: Error {
    case decodingError
    case tokenError
}

extension Error {
    var errorCode:Int? {
        return (self as NSError).code
    }
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}
