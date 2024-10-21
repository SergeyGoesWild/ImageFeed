//
//  ProfileViewTests.swift
//  ProfileViewTests
//
//  Created by Sergey Telnov on 20/10/2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    func testNumberOfElementsCreated() {
        let profileController = ProfileViewController()
        let buttons = profileController.view.subviews.compactMap { $0 as? UIButton }
        let textFields = profileController.view.subviews.compactMap { $0 as? UILabel }
        let images = profileController.view.subviews.compactMap { $0 as? UIImageView }
        
        XCTAssertEqual(buttons.count, 1)
        XCTAssertEqual(textFields.count, 3)
        XCTAssertEqual(images.count, 1)
    }
    
    func testViewControllerCallsViewDidLoad() {
        let profileViewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        profileViewController.loadViewIfNeeded()

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewPresenterReactsToNotification() {
        let profileViewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        let imageService = ImageServiceSpy()
        presenter.viewDidLoad()
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
                name: ProfileImageService.didChangeNotification,
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
