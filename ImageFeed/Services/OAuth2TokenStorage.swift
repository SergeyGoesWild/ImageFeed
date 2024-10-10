//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 21/09/2024.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage{
    var token: String? {
        get {
            guard let returnValue = KeychainWrapper.standard.string(forKey: "token") else {
                print("LOG: Problem with getting the token from memory")
                return nil
            }
            return returnValue
        }
        set {
            KeychainWrapper.standard.set(newValue ?? "", forKey: "token")
        }
    }
}
