//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Sergey Telnov on 05/09/2024.
//

import Foundation
import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    private var profileImageServiceObserver: NSObjectProtocol?
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = makeProfilePicture(profilePictureName: "ProfilePhoto")
        let nameLabel = makeNameLabel(userName: "Екатерина Новикова")
        let tagLabel = makeTagLabel(profileTag: "@ekaterina_nov")
        let textLabel = makeTextLabel(profileText: "Hello, world!")
        let exitButton = makeExitButton(iconName: "ExitButton")
        
        setupProfileScreen(profilePicture: imageView, nameLabel: nameLabel, tagLabel: tagLabel, textLabel: textLabel, exitButton: exitButton, sidePadding: 16, topPadding: 52, lineSpacing: 8)
        
        nameLabel.text = ProfileService.shared.profileToShare.name
        tagLabel.text = ProfileService.shared.profileToShare.loginName
        textLabel.text = ProfileService.shared.profileToShare.bio
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            print("LOG: [ProfileViewController]: Problem in updateAvatar()")
            return
        }
        imageView.kf.setImage(with: url, placeholder: UIImage(named: "ProfilePhoto.png"))
    }
    
    @objc
    private func didTapExitButton() {
        print("LOG: [ProfileViewController]: Pressed EXIT button")
    }
    
    private func makeProfilePicture(profilePictureName: String) -> UIImageView {
        let userPicture = UIImage(named: profilePictureName)
        let imageView = UIImageView(image: userPicture)
        return imageView
    }
    
    private func makeNameLabel(userName: String) -> UILabel {
        let nameLabel = UILabel()
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.text = userName
        return nameLabel
    }
    
    private func makeTagLabel(profileTag: String) -> UILabel {
        let tagLabel = UILabel()
        tagLabel.textColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1.00)
        tagLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        tagLabel.text = profileTag
        return tagLabel
    }
    
    private func makeTextLabel(profileText: String) -> UILabel {
        let textLabel = UILabel()
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        textLabel.text = profileText
        return textLabel
    }
    
    private func makeExitButton(iconName: String) -> UIButton {
        let exitIcon = UIImage(named: iconName)
        let backupIcon = UIImage(systemName: "xmark.square")
        let exitButton = UIButton.systemButton(with: exitIcon ?? backupIcon!, target: self, action: #selector(Self.didTapExitButton))
        return exitButton
    }
    
    private func setupProfileScreen(profilePicture: UIImageView, nameLabel: UILabel, tagLabel: UILabel, textLabel: UILabel, exitButton: UIButton, sidePadding: CGFloat, topPadding: CGFloat, lineSpacing: CGFloat) {
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profilePicture)
        view.addSubview(nameLabel)
        view.addSubview(tagLabel)
        view.addSubview(textLabel)
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            profilePicture.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: sidePadding),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: sidePadding),
            tagLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: sidePadding),
            textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: sidePadding),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -sidePadding),
            
            profilePicture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topPadding),
            nameLabel.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: lineSpacing),
            tagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: lineSpacing),
            textLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: lineSpacing),
            exitButton.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor)
        ])
    }
    
}
