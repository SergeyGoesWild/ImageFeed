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
        
        let imageView = spawnProfilePicture(profilePictureName: "ProfilePhoto")
        let nameLabel = spawnNameLabel(userName: "Екатерина Новикова")
        let tagLabel = spawnTagLabel(profileTag: "@ekaterina_nov")
        let textLabel = spawnTextLabel(profileText: "Hello, world!")
        let exitButton = spawnExitButton(iconName: "ExitButton")
        
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
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tagLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            tagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            textLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 8),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
    }
    
    @objc
    private func didTapExitButton() {
        print("pressed EXIT button")
    }
    
    private func spawnProfilePicture(profilePictureName: String) -> UIImageView {
        let UserPicture = UIImage(named: profilePictureName)
        let imageView = UIImageView(image: UserPicture)
        return imageView
    }
    
    private func spawnNameLabel(userName: String) -> UILabel {
        let nameLabel = UILabel()
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.text = userName
        return nameLabel
    }
    
    private func spawnTagLabel(profileTag: String) -> UILabel {
        let tagLabel = UILabel()
        tagLabel.textColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1.00)
        tagLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        tagLabel.text = profileTag
        return tagLabel
    }
    
    private func spawnTextLabel(profileText: String) -> UILabel {
        let textLabel = UILabel()
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        textLabel.text = profileText
        return textLabel
    }
    
    private func spawnExitButton(iconName: String) -> UIButton {
        let exitIcon = UIImage(named: iconName)
        let backupIcon = UIImage(systemName: "xmark.square")
        let exitButton = UIButton.systemButton(with: exitIcon ?? backupIcon!, target: self, action: #selector(Self.didTapExitButton))
        return exitButton
    }
    
}
