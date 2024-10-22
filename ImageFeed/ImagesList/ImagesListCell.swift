//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 30/08/2024.
//

import Foundation
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImage.kf.cancelDownloadTask()
        backgroundImage.image = nil
    }
    
    func setIsLiked(isLiked: Bool) {
        print("LOG: [CELL] Like is SET to : \(isLiked)")
        likeButton.setImage(UIImage(named: isLiked ? "LikeClicked" : "Like"), for: .normal)
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        print("LOG: [CELL] Like CLICKED")
        delegate?.imageListCellDidTapLike(self)
    }
}
