//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 01/10/2024.
//

import Foundation

struct UserResult: Codable {
    let profile_image: Avatars
}

struct Avatars: Codable {
    let small: String
    let medium: String
    let large: String
}

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
        
    static let shared = ProfileImageService()
    private init() {}
    
    private let storage = OAuth2TokenStorage()
    private let networkClient = NetworkClient()
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(userName: String, _ completion: @escaping (Result<String, Error>) -> Void){
        guard let token = storage.token else {
            print("LOG: [ProfileImageService]: token error")
            completion(.failure(CommonError.tokenError))
            return
        }
        
        guard let request = makeUrlRequestProfile(token: token, userName: userName) else {
            print("LOG: [ProfileImageService]: url request error")
            completion(.failure(NetworkError.urlRequestError))
            return
        }
        
        networkClient.objectTask(for: request) { (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profile_image.small
                guard let profileImageURL = self.avatarURL else {
                    print("LOG: [ProfileImageService]: url unwrap error")
                    completion(.failure(NetworkError.urlUnwrapError))
                    return
                }
                completion(.success(profileImageURL))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL])
            case .failure(let error):
                print("LOG: [ProfileImageService]: Error in networkClient")
                completion(.failure(error))
            }
        }
    }
    
    private func makeUrlRequestProfile(token: String, userName: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/users/\(userName)"
        
        if let url = urlComponents.url {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        } else {
            print("LOG: [ProfileImageService]: url components error")
            return nil
        }
    }
}
