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
    
    func showAlert(withTitle title: String, withText text: String, on viewController: UIViewController, withOk okTitle: String, withCancel cancelTitle: String? = nil, okAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
            okAction?()
        }
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default) { _ in
            cancelAction?()
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
