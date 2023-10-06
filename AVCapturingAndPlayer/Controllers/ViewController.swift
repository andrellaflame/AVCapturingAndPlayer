//
//  ViewController.swift
//  AVCapturingAndPlayer
//
//  Created by Andrii Sulimenko on 04.10.2023.
//

import UIKit
class ViewController: UIViewController {
        private let button: UIButton = {
        let button = UIButton(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 200,
                height: 52)
        )
        button.setTitle("Preview", for: .normal)
        button.backgroundColor = .secondarySystemFill
        button.setTitleColor(.label, for: .normal)
        
        button.layer.cornerRadius = 8
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.center = view.center
    }
    
    @objc func didTapButton() {
        let tabBarVC = UITabBarController()
        
        let cameraVC = UINavigationController(rootViewController: CameraViewController())
        let savedFilesVC = UINavigationController(rootViewController: SavedFilesViewController())
        
        cameraVC.title = "Camera"
        savedFilesVC.title = "Saved files"
        
        tabBarVC.setViewControllers([cameraVC, savedFilesVC], animated: false)
        
        guard let items = tabBarVC.tabBar.items else { return }
        
        let images = ["camera", "doc"]
        
        for index in 0..<items.count {
            items[index].image = UIImage(systemName: images[index])
        }
        
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true)
    }
}
