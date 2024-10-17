//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 16/10/2024.
//

import Foundation
import UIKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func exitButtonPressed()
    func sendToAuthScreen()
    func viewDidLoad()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: (any ProfileViewControllerProtocol)?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.view?.updateAvatar()
            }
        view?.updateAvatar()
    }
    
    func exitButtonPressed() {
        AlertService.shared.showAlert(withTitle: "Пока-пока!", withText: "Уверены, что хотите выйти?", on: view as! UIViewController, withOk: "Да", withCancel: "Нет", okAction: {
            print("Ok pressed")
            ProfileLogoutService.shared.logout()
            self.sendToAuthScreen()
        }, cancelAction: {
            print("Cancel pressed")
        })
    }
    
    func sendToAuthScreen() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let splashScreen = SplashViewController()
        window.rootViewController = splashScreen
        window.makeKeyAndVisible()
    }
}
