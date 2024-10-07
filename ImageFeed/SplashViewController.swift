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
        KeychainWrapper.standard.removeObject(forKey: "token")
        setupSplashScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            print(token)
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
        print("CAME TO DID AUTH")
        dismiss(animated: true)
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(oauth2TokenStorage.token!) { result in
            print("Запустили фетч ПРОФАЙЛ")
            switch result {
            //TODO: что-то решить с этой передачей профиля которая уже не нужна
            case .success(let profile):
                
                    UIBlockingProgressHUD.dismiss()
                    print("КОНЕЦ фетч ПРОФАЙЛ")
                
            case .failure(let error):
                
                    print("Error while retrieving profile DATA")
                    print(error)
                    UIBlockingProgressHUD.dismiss()
                
            }
        }
        
        switchToTabBarController()
        
        ProfileImageService.shared.fetchProfileImageURL(userName: "sergeytelnov34") { result in
            print("Запустили фетч ФОТО")
            switch result {
            case .success(let result):
                print("конец фетч ФОТО")
            case .failure(let error):
                print(error)
            }
        }
    }
}
