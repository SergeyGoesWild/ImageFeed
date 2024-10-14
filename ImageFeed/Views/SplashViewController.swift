//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 22/09/2024.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        KeychainWrapper.standard.removeObject(forKey: "token")
        setupSplashScreen()
    }
    
    deinit {
        print("LOG: Deinit [SplashViewController] deallocated")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            didAuthenticate()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController {
                viewController.delegate = self
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    func setupSplashScreen() {
        let logo = UIImage(named: "LogoUnsplash")
        let imageView = UIImageView(image: logo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate() {
        dismiss(animated: true)
        UIBlockingProgressHUD.show()
        guard let token = oauth2TokenStorage.token else {
            print("LOG: [SplashViewController]: Error with token")
            return
        }
        ProfileService.shared.fetchProfile(token) { result in
            switch result {
            case .success(let profile):
                UIBlockingProgressHUD.dismiss()
                ProfileImageService.shared.fetchProfileImageURL(userName: profile.username) { result in
                    switch result {
                    case .success(_):
                        print("LOG: [SplashViewController]: ProfileImageService ended in SUCCESS")
                    case .failure(_):
                        print("LOG: [SplashViewController]: ProfileImageService ended in FAILURE")
                    }
                }
            case .failure(let error):
                print("LOG: [SplashViewController]: Error while retrieving profile data: \(error)")
                UIBlockingProgressHUD.dismiss()
            }
        }
        switchToTabBarController()
    }
}
