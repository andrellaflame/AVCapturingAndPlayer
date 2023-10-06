//
//  FileStorageManager.swift
//  AVCapturingAndPlayer
//
//  Created by Andrii Sulimenko on 04.10.2023.
//

import Foundation

class FileStorageManager {
    // MARK: Data receiving
    func getAllFiles() -> [URL] {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return []
        }
        
        let fileManager = FileManager.default
       
        do {
            let items = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)

            for item in items {
                print("Found \(String(describing: item.pathComponents.last))")
            }
            
            let sortedItems = items.sorted { (url1, url2) -> Bool in
                url1.lastPathComponent < url2.lastPathComponent
            }
            
            return sortedItems
        } catch {
            print("Error while retrieving data from FileManager: \(error.localizedDescription)")
            return []
        }
    }
    
    func getAllMP4Files() -> [URL] {
        let allFiles = getAllFiles()
        return allFiles.filter { $0.pathExtension == "mp4" }
    }
    
    func getCurrentMP4Index(current url: URL) -> Int {
        let allMP4Files = getAllMP4Files()
        if let index = allMP4Files.firstIndex(of: url) {
            return index
        } else {
            return 0
        }
    }
    
    // MARK: Sample data functions
    func createSampleData(){
        guard let file = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let array = [1,2,3,4,5]
        let json = JSONEncoder()

        for item in array {
            var fileName = "picture.txt"
            var version = 0
            
            while FileManager.default.fileExists(atPath: file.appendingPathComponent(fileName).path) {
                version += 1
                fileName = "picture\(version).txt"
            }
            
            let data = try! json.encode(item)
            try! data.write(to: file.appendingPathComponent(fileName))
        }
    }

    func deleteSampleData() {
        guard let file = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
                
        var version = 0
        var fileName = "picture.txt"
        
        while FileManager.default.fileExists(atPath: file.appendingPathComponent(fileName).path) {
            do {
                try FileManager.default.removeItem(at: file.appendingPathComponent(fileName))
                print("Deleted: \(fileName)")
            } catch {
                print("Error deleting: \(fileName)")
            }
            
            version += 1
            fileName = "picture\(version).txt"
        }
    }
    
    func deleteAllData() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileManager = FileManager.default
        
        do {
            let items = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            
            for item in items {
                do {
                    try fileManager.removeItem(at: item)
                    print("Deleted: \(item.lastPathComponent)")
                } catch {
                    print("Error deleting: \(item.lastPathComponent)")
                }
            }
        } catch {
            print("Error while retrieving data from FileManager: \(error.localizedDescription)")
        }
    }
}
