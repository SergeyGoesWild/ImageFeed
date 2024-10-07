//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 20/09/2024.
//

import Foundation
import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let networkClient = NetworkClient()
    private init() {}
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(code: String, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
                print("-----> 01")
            } else {
                print("-----> 02")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                print("-----> 03")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        
        guard let request = makeUrlRequest(code: code) else {
            print("-----> [AuthService]: url request error")
            completion(.failure(NetworkError.urlRequestError))
            return
        }
        
        networkClient.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let tokenResponse):
                completion(.success(tokenResponse.access_token))
            case .failure(let error):
                print("-----> [AuthService]: Error while fetching")
                completion(.failure(error))
            }
        }
    }
    
    func makeUrlRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash1.com"
        urlComponents.path = "/oauth/token"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        if let url = urlComponents.url {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            return request
        } else {
            print("Problem with URL")
            return nil
        }
    }
    
    //TODO: материал чтобы изменить состояние гонки здесь, примени, потом удали это
    func networkClient(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
                self.task = nil
                self.lastCode = nil
            }
        }
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            
            if let error = error {
                fulfillCompletionOnTheMainThread(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            
            guard let data = data else { return }
            fulfillCompletionOnTheMainThread(.success(data))
        }
        self.task = task
        task.resume()
    }
}
