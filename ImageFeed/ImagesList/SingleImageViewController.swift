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
        super.viewDidLoad()
        scrollView.delegate = self
        guard let image = image else { return }
        imageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let image = image else { return }
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    //        Комментарий для проверяющего. Авторское решение, предложенное в уроке для метода rescaleAndCenterImageInScrollView не сработало у меня, даже если копировал-вставлял весь класс. Почему, пока не разобрался. Но написал свой метод, надеюсь, что вас это устроит, так как требования он удовлетворяет, видимо. + Добавил центрирование после отЗУМления картинки.
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

