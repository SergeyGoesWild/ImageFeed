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
    
    var fullImageURL: URL?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    deinit {
        print("LOG: Deinit [SingleImageViewController] deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityIdentifier = "nav back button white"
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                image = imageResult.image
            case .failure:
                AlertService.shared.showAlert(withTitle: "Что-то пошло не так", withText: "Попробовать ещё раз?", on: self, withOk: "Повторить", withCancel: "Не надо",
                    okAction: {
                    self.imageView.kf.setImage(with: self.fullImageURL)
                }, cancelAction: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let image = image else { return }
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let ratio = image.size.height / image.size.width
        imageView.frame.size.width = scrollView.frame.width
        imageView.frame.size.height = imageView.frame.size.width * ratio
        scrollView.contentSize = scrollView.frame.size
        let newY = scrollView.frame.height / 2 - imageView.frame.size.height / 2
        scrollView.contentOffset = CGPoint(x: 0, y: -newY)
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
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let horizontalInset = (scrollView.frame.size.width - imageView.frame.size.width) / 2
        let verticalInset = (scrollView.frame.size.height - imageView.frame.size.height) / 2
        if scale < 1 {
            scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        } else {
            scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
        }
    }
}

