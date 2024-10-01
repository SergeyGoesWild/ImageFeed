//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 27/09/2024.
//

import Foundation

struct ProfileResult: Codable {
    let id: String
    let username: String
    let first_name: String
    let last_name: String
    let bio: String
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}

final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    private let storage = OAuth2TokenStorage()
    private(set) var profileToShare: Profile = Profile(username: "A", name: "B", loginName: "C", bio: "D")
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeUrlRequestProfile(token: token) else {
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
                let stringData = try decoder.decode(ProfileResult.self, from: data)
                let profile = Profile(username: stringData.username, name: stringData.first_name + " " + stringData.last_name, loginName: "@" + stringData.username, bio: stringData.bio)
                self.profileToShare = profile
                completion(.success(profile))
            }
            catch {
                print("Profile ERROR from decoding")
                //TODO: Привести в порядок все сообщения об ошибках
                completion(.failure(NetworkError.urlRequestError))
            }
        }
        task.resume()
    }
    
    func makeUrlRequestProfile(token: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/me"
        
        if let url = urlComponents.url {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("TOKEN: ", token)
            return request
        } else {
            print("Problem with URL")
            return nil
        }
    }
}
