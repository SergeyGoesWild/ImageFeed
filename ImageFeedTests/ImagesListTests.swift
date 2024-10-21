//
//  ImagesListTests.swift
//  ImagesListTests
//
//  Created by Sergey Telnov on 20/10/2024.
//

import XCTest
@testable import ImageFeed

final class ImagesViewTests: XCTestCase {
    
    func testNumberOfElementsCreated() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagesViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        guard let imagesViewController else { return }
        let tables = imagesViewController.view.subviews.compactMap { $0 as? UITableView }
        let cells = imagesViewController.view.subviews.compactMap { $0 as? UITableViewCell }
        XCTAssertEqual(tables.count, 1)
        XCTAssertEqual(cells.count, 0)
    }
    
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagesViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        guard let imagesViewController else { return }
        let presenter = ImagesListPresenterSpy()
        imagesViewController.presenter = presenter
        presenter.view = imagesViewController
        imagesViewController.loadViewIfNeeded()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    //    func testViewPresenterReactsToNotification() {
    //        let notificationEmmiter = ImageListServiceSpy()
    //        let presenter = ImagesListPresenterSpy()
    //        profileViewController.presenter = presenter
    //        presenter.view = profileViewController
    //        let imageService = ImageServiceSpy()
    //        presenter.viewDidLoad()
    //        imageService.sendNotification()
    //        XCTAssertTrue(profileViewController.notificationDidReact)
    //    }
}

final class ImagesListPresenterSpy: ImagesListViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: (any ImageFeed.ImagesListViewControllerProtocol)?
    
    func updateTableViewAnimated() {
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func presenterProcessLike(_ cell: ImageFeed.ImagesListCell) {
    }
}

final class ImageListServiceSpy {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func sendNotification() {
        NotificationCenter.default
            .post(
                name: ImagesListService.didChangeNotification,
                object: self)
    }
}

final class ImagesListControllerSpy: ImagesListViewControllerProtocol {
    var photos: [ImageFeed.Photo] = []
    
    var tableView: UITableView!
    
    var presenter: (any ImageFeed.ImagesListViewPresenterProtocol)?
    
    var notificationDidReact: Bool = false
    
}

