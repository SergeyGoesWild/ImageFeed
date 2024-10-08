//
//  AlertService.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 08/10/2024.
//

import Foundation
import UIKit

final class AlertService {
    static let shared = AlertService()
    private init() {}
    
    func showAlert(withTitle title: String, withText text: String, on viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            print("LOG: OK tapped")
        }
        
        alert.addAction(okAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
