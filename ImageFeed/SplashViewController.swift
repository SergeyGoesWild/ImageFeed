//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 22/09/2024.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2TokenStorage = OAuth2TokenStorage()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            didAuthenticate()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate() {
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
