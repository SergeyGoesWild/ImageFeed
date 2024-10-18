//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 18/10/2024.
//

import Foundation
import UIKit

protocol ImagesListViewPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    
    func updateTableViewAnimated() {
        print("LOG: [ImagesListViewController] UPDATING the table")
        guard let view = view else { return }
        let oldCount = view.photos.count
        let newCount = ImagesListService.shared.photos.count
        view.photos = ImagesListService.shared.photos
        if oldCount != newCount {
            print("LOG: [ImagesListViewController] BATCHING")
            view.tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                view.tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}
