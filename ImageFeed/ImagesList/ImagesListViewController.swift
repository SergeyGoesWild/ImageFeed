//
//  ViewController.swift
//  ImageFeed
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var photos: [Photo] { get set }
    var tableView: UITableView! { get set }
    var presenter: ImagesListViewPresenterProtocol? { get set }
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    var presenter: ImagesListViewPresenterProtocol?
    var photos: [Photo] = []
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    deinit {
        print("LOG: Deinit [ImagesListViewController] deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            tableView.isPrefetchingEnabled = false
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.viewDidLoad()
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            viewController.fullImageURL = URL(string: photos[indexPath.row].largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            print("LOG: [ImagesListViewController] TRIGGERING NEW")
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let currentObject = photos[indexPath.row]
        cell.backgroundImage.kf.indicatorType = .activity
        cell.setIsLiked(isLiked: currentObject.isLiked)
        cell.backgroundImage.contentMode = .center
        cell.backgroundImage.kf.setImage(with: URL(string: currentObject.thumbImageURL), placeholder: UIImage(named: "Placeholder.png")) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                cell.backgroundImage.contentMode = .scaleAspectFill
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(_):
                print("LOG: [ImagesListController] Failed to load the image")
            }
        }
        cell.dateLabel.text = dateFormatter.string(from: currentObject.createdAt ?? Date())
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentObject = photos[indexPath.row]
        let aspectRatio = currentObject.size.width / currentObject.size.height
        return tableView.bounds.width / aspectRatio
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.presenterProcessLike(cell)
    }
}
