//
//  ImageViewController.swift
//  AVCapturingAndPlayer
//
//  Created by Andrii Sulimenko on 05.10.2023.
//

import Foundation
import UIKit
import Photos

class ImageViewController: UIViewController {
    var fileURL: URL?
    
    private let imageView = UIImageView()
    private let saveButton = UIButton()
    private let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(fileURL?.lastPathComponent ?? "No description")"
        
        setupImageView()
        setupSaveButton()
        setupConstraints()
    }
    
    func setupSaveButton() {
        view.addSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        
        let image = UIImage(systemName: "square.and.arrow.down", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)

        saveButton.setImage(image, for: .normal)
        saveButton.setTitle("Save", for: .normal)
        saveButton.tintColor = .systemBlue

        saveButton.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    }
    
    func setupImageView() {
        view.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        
        guard let file = fileURL else {
            print("Filepath is unreachable")
            return
        }
        
        if let imageData = try? Data(contentsOf: file), let image = UIImage(data: imageData) {
            imageView.image = image
        }
    }
    
    func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc func didTapSaveButton() {
        guard let image = self.imageView.image else { return }
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                do {
                    try PHPhotoLibrary.shared().performChangesAndWait {
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                        print("Photo was saved to photos")
                    }
                } catch let error {
                    print("Failed to save photo to photos: ", error)
                }
            } else {
                print("Error occured while saving photo")
            }
        }
    }
}
