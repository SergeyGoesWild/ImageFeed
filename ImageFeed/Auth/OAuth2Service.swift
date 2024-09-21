//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 20/09/2024.
//

import Foundation
import UIKit

final class OAuth2Service {
    private let storage = OAuth2TokenStorage()
    static let shared = OAuth2Service()
    private init() {}

    func fetchOAuthToken(code: String) -> Void {
        
        guard var request = makeUrlRequest(code: code) else {
            print("problem with making URL request")
            return
        }
        request.httpMethod = "POST"
        networkClient(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let stringData = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    print("DATA RECEIVED")
                    print("Token from storage 01 : ")
                    print(self.storage.bearerToken)
                    self.storage.bearerToken = stringData.access_token
                    print("Token from storage 02 : ")
                    print(self.storage.bearerToken)
                } catch {
                    print("Problem with DECODING data")
                }
            case .failure(let error):
                print("Error while FETCHING: ", error)
            }
        }
    }
    
    func makeUrlRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/oauth/token"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        if let url = urlComponents.url {
            return URLRequest(url: url)
        } else {
            print("Problem with URL")
            return nil
        }
    }
    
    func networkClient(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
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
        
        task.resume()
    }
}
