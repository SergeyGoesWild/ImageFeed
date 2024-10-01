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
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(userName: String, _ completion: @escaping (Result<String, Error>) -> Void){
        guard let token = storage.token else {
            print("Profile Image token ERROR")
            completion(.failure(NetworkError.urlRequestError))
            return
        }
        
        guard let request = makeUrlRequestProfile(token: token, userName: userName) else {
            print("Profile ERROR from request")
            completion(.failure(NetworkError.urlRequestError))
            return
        }
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
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let stringData = try decoder.decode(UserResult.self, from: data)
                let userResult = UserResult(profile_image: stringData.profile_image)
                self.avatarURL = userResult.profile_image.small
                guard let avatarSmall = self.avatarURL else {
                    completion(.failure(NetworkError.decodingError))
                    return
                }
                completion(.success(avatarSmall))
            }
            catch {
                print("Profile ERROR from decoding")
                //TODO: Привести в порядок все сообщения об ошибках
                completion(.failure(NetworkError.urlRequestError))
            }
        }
        task.resume()
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
            print("Problem with URL")
            return nil
        }
    }
}
