//
//  ProfileViewTests.swift
//  ProfileViewTests
//
//  Created by Sergey Telnov on 20/10/2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        let profileViewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        _ = presenter.viewDidLoad()
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewPresenterReactsNotification() {
        let profileViewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        let imageService = ImageServiceSpy()
        imageService.sendNotification()
        XCTAssertTrue(profileViewController.notificationDidReact)
    }
}

final class ProfilePresenterSpy: ProfileViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: (any ImageFeed.ProfileViewControllerProtocol)?
    
    func exitButtonPressed() {
    }
    
    func sendToAuthScreen() {
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

final class ImageServiceSpy {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func sendNotification() {
        NotificationCenter.default
            .post(
                name: ImageServiceSpy.didChangeNotification,
                object: self)
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var notificationDidReact: Bool = false
    var presenter: (any ImageFeed.ProfileViewPresenterProtocol)?
    
    func updateAvatar() {
        notificationDidReact = true
    }
    
    
}
