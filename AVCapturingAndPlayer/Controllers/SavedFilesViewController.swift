//
//  SavedFilesViewController.swift
//  AVCapturingAndPlayer
//
//  Created by Andrii Sulimenko on 04.10.2023.
//

import Foundation
import UIKit

class SavedFilesViewController: UIViewController {
    
    // MARK: Class variables
    let tableView = UITableView()
    
    private let fileStorageManager = FileStorageManager()
    private var allFiles: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved Files"
        
        // Remove comment to delete sample or unnecessary data
        
//        fileStorageManager.createSampleData()
//        fileStorageManager.deleteSampleData()
//        fileStorageManager.deleteAllData()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        allFiles = fileStorageManager.getAllFiles()
        tableView.reloadData()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "custom_cell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: Extensions
extension SavedFilesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "custom_cell", for: indexPath)
        cell.textLabel?.text = allFiles[indexPath.row].pathComponents.last
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFileURL = allFiles[indexPath.row]
        
        if (selectedFileURL.pathExtension == "mp4") {
            let playerViewController = PlayerViewController()
            playerViewController.allMP4FilesURLs = fileStorageManager.getAllMP4Files()
            playerViewController.currentFileURLIndex = fileStorageManager.getCurrentMP4Index(current: selectedFileURL)
            navigationController?.pushViewController(playerViewController, animated: true)
        } else {
            let imageViewController = ImageViewController()
            imageViewController.fileURL = selectedFileURL
            navigationController?.pushViewController(imageViewController, animated: true)
        }
    }
}
