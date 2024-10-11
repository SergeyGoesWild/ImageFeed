//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 11/10/2024.
//

import Foundation
import SwiftKeychainWrapper
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() { }
    
    func logout() {
        cleanCookies()
        deleteKey()
        deleteData()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func deleteKey() {
        KeychainWrapper.standard.removeObject(forKey: "token")
    }
    
    private func deleteData() {
        ProfileImageService.shared.prepareToLogout()
        ProfileService.shared.prepareToLogout()
        ImagesListService.shared.prepareToLogout()
    }
}

