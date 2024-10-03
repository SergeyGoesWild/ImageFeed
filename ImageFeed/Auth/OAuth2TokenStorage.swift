//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 21/09/2024.
//

import Foundation
import UIKit

final class OAuth2TokenStorage{
    var token: String? {
        get {
            guard let returnValue = UserDefaults.standard.string(forKey: "token") else {
                print("Problem with getting the token from memory")
                return nil
            }
            return returnValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "token")
        }
    }
}
