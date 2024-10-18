//
//  Tab Bar Controller.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 05/10/2024.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        
        let imagesListPresenter = ImagesListViewPresenter()
        if let imagesListViewController = imagesListViewController as? ImagesListViewControllerProtocol {
            imagesListViewController.presenter = imagesListPresenter
            imagesListPresenter.view = imagesListViewController
        }
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    deinit {
        print("LOG: Deinit [TabBar] deallocated")
    }
}

