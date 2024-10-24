//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 10/10/2024.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

struct PhotoResult: Codable {
    let id: String
    let created_at: String?
    let width: Int
    let height: Int
    let description: String?
    let liked_by_user: Bool
    let urls: Urls
}

struct Urls: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    var lastPageReached: Bool = false
    let perPage = 10
    var lastLoadedPage: Int?
    let networkClient = NetworkClient()
    let storage = OAuth2TokenStorage()
    
    func prepareToLogout() {
        photos = []
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        print("LOG: [ImageService] Like action FOLLOWED 02")
        guard let token = storage.token else { return }
        var request: URLRequest
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/photos/\(photoId)/like"
        if let url = urlComponents.url {
            request = URLRequest(url: url)
            request.httpMethod = isLike ? "POST" : "DELETE"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("LOG: [ImageListService] - Problem with URL COMPONENTS")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
            
            guard data != nil else {
                print("LOG: [NetworkClient]: dataTask error while unwrapping data")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.dataError))
                }
                return
            }
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let photo = self.photos[index]
                let newPhoto = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: !photo.isLiked
                )
                DispatchQueue.main.async {
                    self.photos = self.photos.withReplaced(at: index, with: newPhoto)
                }
            }
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    func fetchPhotosNextPage() {
        if lastPageReached { return }
        let nextPage = (lastLoadedPage ?? 0) + 1
        lastLoadedPage = nextPage
        guard let token = storage.token else {
            print("LOG: [ImageListService] - Problem with TOKEN")
            return
        }
        guard let request = makeUrlRequestImageService(token: token, page: nextPage, perPage: perPage) else {
            print("LOG: [ImageListService] - Problem with REQUEST")
            return
        }
        networkClient.objectTask(for: request) { (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photosFromFetch):
                let photosConverted = self.convertToPhotos(photos: photosFromFetch)
                self.photos.append(contentsOf: photosConverted)
                
                if photosFromFetch.isEmpty {
                    self.lastPageReached = true
                    return
                } else {
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self)
                }
            case .failure(_):
                print("LOG: [ImageListService] networkClient.objectTask FAILURE")
            }
        }
    }
    
    private func makeUrlRequestImageService(token: String, page: Int, perPage: Int) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        
        if let url = urlComponents.url {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        } else {
            print("LOG: [ImageListService] - Problem with URL COMPONENTS")
            return nil
        }
    }
    
    private func convertToPhotos(photos: [PhotoResult]) -> [Photo] {
        var photosResult: [Photo] = []
        for photo in photos {
            var dateConverted: Date?
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = dateFormatter.date(from: photo.created_at ?? "") {
                dateConverted = date
            }
            let sizeConverted = CGSize(width: CGFloat(photo.width), height: CGFloat(photo.height))
            let convertedPhoto = Photo(id: photo.id, size: sizeConverted, createdAt: dateConverted, welcomeDescription: photo.description, thumbImageURL: photo.urls.thumb, largeImageURL: photo.urls.full, isLiked: photo.liked_by_user)
            photosResult.append(convertedPhoto)
        }
        
        return photosResult
    }
}

extension Array {
    func withReplaced(at index: Int, with element: Element) -> [Element] {
        var newArray = self
        if index >= 0 && index < newArray.count {
            newArray[index] = element
        }
        return newArray
    }
}
