//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 16/09/2024.
//

import Foundation
import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate()
}

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage()
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        ProgressHUD.animate()
        oauth2Service.fetchOAuthToken(code: code) { result in
            switch result {
            case .success(let access_token):
                ProgressHUD.dismiss()
                self.storage.token = access_token
                print("WENT TO SUCCESS")
                self.delegate?.didAuthenticate()
            case .failure(let error):
                //TODO: наладить функционирование, чтобы нормально закрывалось окно и как-то реагировало приложение
                ProgressHUD.dismiss()
                print("This error during Network or decoding: ", error)
                print("WENT TO FAILURE")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.00)
    }
}
