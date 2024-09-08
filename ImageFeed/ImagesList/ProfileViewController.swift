//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 05/09/2024.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let UserPicture = UIImage(named: "ProfilePhoto")
        let imageView = UIImageView(image: UserPicture)
        
        let nameLabel = UILabel()
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.text = "Екатерина Новикова"
        
        let tagLabel = UILabel()
        tagLabel.textColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1.00)
        tagLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        tagLabel.text = "@ekaterina_nov"
        
        let textLabel = UILabel()
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        textLabel.text = "Hello, world!"
        
        let exitIcon = UIImage(named: "ExitButton")
        let exitButton = UIButton.systemButton(with: exitIcon!, target: self, action: #selector(Self.didTapExitButton))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(tagLabel)
        view.addSubview(textLabel)
        view.addSubview(exitButton)
        
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        tagLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        tagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        textLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 8).isActive = true
        exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
    @objc
    func didTapExitButton() {
        print("pressed EXIT button")
    }
}
