//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 30/08/2024.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
}
