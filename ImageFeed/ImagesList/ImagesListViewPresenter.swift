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
    func updateTableViewAnimated()
    func viewDidLoad()
    func presenterProcessLike(_ cell: ImagesListCell)
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    private var imagesListObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        imagesListObserver = NotificationCenter.default.addObserver(forName: ImagesListService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
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
    
    func presenterProcessLike(_ cell: ImagesListCell) {
        guard let view = view else { return }
        guard let indexPath = view.tableView.indexPath(for: cell) else { return }
        let photo = view.photos[indexPath.row]
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                view.photos =  ImagesListService.shared.photos
                cell.setIsLiked(isLiked: view.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
                
            case .failure:
                UIBlockingProgressHUD.dismiss()
                DispatchQueue.main.async {
                    AlertService.shared.showAlert(withTitle: "Ой-ой", withText: "Что-то не так с лайком", on: view as! UIViewController, withOk: "Ok", okAction: { print("OkAction") })
                }
            }
        }
    }
}
