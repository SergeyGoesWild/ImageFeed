//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 05/09/2024.
//

import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }

            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
//        Просто пытаюсь отцентрировать изображение, пока без масштабирования, в оригинальном размере, чтобы было проще.
        super.viewDidLoad()
        guard let image = image else { return }
        imageView.image = image
        imageView.layer.borderColor = UIColor.red.cgColor
        imageView.layer.borderWidth = 2
//        imageView.frame.size = image.size
//        scrollView.contentSize = image.size
//        let newX = abs(scrollView.frame.width / 2 - imageView.frame.size.width / 2)
//        let newY = abs(scrollView.frame.height / 2 - imageView.frame.size.height / 2)
//        scrollView.contentOffset = CGPoint(x: newX, y: newY)
//        rescaleAndCenterImageInScrollView(image: image)
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Now the scrollView frame is set, and we can get its size
        guard let image = image else { return }
        let ratio = image.size.height / image.size.width
        
        imageView.frame.size.width = scrollView.frame.width
        imageView.frame.size.height = imageView.frame.size.width * ratio
        
        scrollView.contentSize = scrollView.frame.size
        
        let newY = scrollView.frame.height / 2 - imageView.frame.size.height / 2
        scrollView.contentOffset = CGPoint(x: 0, y: -newY)
        
        print("new Y : ", newY)
        print(ratio)
        print(imageView.frame.size.width, " x ", imageView.frame.size.height)
        print(scrollView.frame.size.width, " x ", scrollView.frame.size.height)
//        imageView.frame.size = image.size
//        scrollView.contentSize = image.size
//        let newX = abs(scrollView.frame.width / 2 - imageView.frame.size.width / 2)
//        let newY = abs(scrollView.frame.height / 2 - imageView.frame.size.height / 2)
//        scrollView.contentOffset = CGPoint(x: newX, y: newY)
//        print(imageView.frame.size.width, " x ", imageView.frame.size.height)
//        print(scrollView.frame.size.width, " x ", scrollView.frame.size.height)
//        print(newX, newY)

    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    @IBAction private func pushBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = image else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

