//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 21/09/2024.
//

import Foundation
import UIKit

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}

final class OAuth2TokenStorage{
    var bearerToken: String {
        get {
            guard let returnValue = UserDefaults.standard.string(forKey: "bearerToken") else {
                print("Problem with getting the token from memory")
                return ""
            }
            return returnValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "bearerToken")
        }
    }
}
