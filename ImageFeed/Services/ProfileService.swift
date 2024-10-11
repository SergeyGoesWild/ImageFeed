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
    private let networkClient = NetworkClient()
    private(set) var profileToShare: Profile = Profile(username: "", name: "", loginName: "", bio: "")
    
    func prepareToLogout() {
        profileToShare = Profile(username: "", name: "", loginName: "", bio: "")
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeUrlRequestProfile(token: token) else {
            print("-----> [ProfileService]: url request error")
            completion(.failure(NetworkError.urlRequestError))
            return
        }
        networkClient.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(username: profileResult.username, name: profileResult.first_name + " " + profileResult.last_name, loginName: "@" + profileResult.username, bio: profileResult.bio)
                self.profileToShare = profile
                completion(.success(profile))
            case .failure(let error):
                print("LOG: [ProfileService]: Error in networkClient")
                completion(.failure(error))
            }
        }
    }
    
    private func makeUrlRequestProfile(token: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/me"
        
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
