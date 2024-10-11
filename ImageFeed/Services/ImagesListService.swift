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
    let likes: Int
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
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    let perPage = 10
    var lastLoadedPage: Int?
    let networkClient = NetworkClient()
    let storage = OAuth2TokenStorage()
    
    func fetchPhotosNextPage() {
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
                print("Notification POSTED *********************")
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self)
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
            //TODO: рассмотреть случай, где не разворачивается
            if let date = dateFormatter.date(from: photo.created_at ?? "") {
                dateConverted = date
            }
            let sizeConverted = CGSize(width: CGFloat(photo.width), height: CGFloat(photo.height))
            let convertedPhoto = Photo(id: photo.id, size: sizeConverted, createdAt: dateConverted, welcomeDescription: photo.description, thumbImageURL: photo.urls.thumb, largeImageURL: photo.urls.full, isLiked: photo.likes > 0)
            photosResult.append(convertedPhoto)
        }
        
        return photosResult
    }
}
