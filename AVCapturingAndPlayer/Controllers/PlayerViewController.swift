//
//  PlayerViewController.swift
//  AVCapturingAndPlayer
//
//  Created by Andrii Sulimenko on 05.10.2023.
//

import Foundation
import UIKit
import AVFoundation
import Photos


class PlayerViewController: UIViewController {
    
    // MARK: Class variables
    var currentFileURLIndex: Int = 0
    var allMP4FilesURLs: [URL?] = []
    
    private var player: AVPlayer?

    // MARK: UI elements
    private let playerView = UIView()
    private let playButton = UIButton()
    private let muteButton = UIButton()
    private let nextVideoButton = UIButton()
    private let previousVideoButton = UIButton()
    private let saveButton = UIButton()
    
    private var isMuted = false
    private var isPlaying = false
    
    private let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(allMP4FilesURLs[currentFileURLIndex]?.lastPathComponent ?? "No description")"
        
        view.addSubview(playerView)
        playerView.backgroundColor = .clear
        playerView.translatesAutoresizingMaskIntoConstraints = false
        
        setupPlayButton()
        setupMuteButton()
        setupNextPrevVideoButtons()
        setupSaveButton()
        setupConstraints()
        
        setupPlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let playerLayer = playerView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = playerView.bounds
        }
    }
    
    // MARK: UI elements setups
    func setupNextPrevVideoButtons() {
        view.addSubview(nextVideoButton)
        view.addSubview(previousVideoButton)
        
        nextVideoButton.addTarget(self, action: #selector(didTapNextVideoButton), for: .touchUpInside)
        previousVideoButton.addTarget(self, action: #selector(didTapPrevVideoButton), for: .touchUpInside)
        
        let imageNext = UIImage(systemName: "arrow.right.to.line", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        let imagePrev = UIImage(systemName: "arrow.left.to.line", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)

        nextVideoButton.setImage(imageNext, for: .normal)
        nextVideoButton.tintColor = .label
        nextVideoButton.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        
        previousVideoButton.setImage(imagePrev, for: .normal)
        previousVideoButton.tintColor = .label
        previousVideoButton.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    }
    
    func setupMuteButton() {
        view.addSubview(muteButton)
        
        muteButton.addTarget(self, action: #selector(didTapMuteButton), for: .touchUpInside)
        
        let image = UIImage(systemName: "speaker.fill", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)

        muteButton.setImage(image, for: .normal)
        muteButton.tintColor = .label

        muteButton.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    }
    
    func setupPlayButton() {
        view.addSubview(playButton)
        
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        
        let image = UIImage(systemName: "play.fill", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)

        playButton.setImage(image, for: .normal)
        playButton.tintColor = .label

        playButton.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    }
    
    func setupSaveButton() {
        view.addSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        
        let image = UIImage(systemName: "square.and.arrow.down", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)

        saveButton.setImage(image, for: .normal)
        saveButton.tintColor = .label

        saveButton.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    }
    
    func setupPlayer() {
        guard let url = allMP4FilesURLs[currentFileURLIndex] else {
            return
        }
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: item)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerLayer.videoGravity = .resizeAspect
        playerView.layer.addSublayer(playerLayer)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            muteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            muteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.topAnchor.constraint(equalTo: muteButton.bottomAnchor, constant: 16)
        ])
        
        previousVideoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previousVideoButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -64),
            previousVideoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        nextVideoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextVideoButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 64),
            nextVideoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: Targets
    @objc func didTapPlayButton() {
        print("didTapPlayButton")
        
        self.isPlaying.toggle()
        
        let image = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        self.playButton.setImage(image, for: .normal)
        
        if isPlaying {
            self.player?.play()
        } else {
            self.player?.pause()
        }
        
    }
    
    @objc func playerDidFinishPlaying() {
        if (currentFileURLIndex != allMP4FilesURLs.count - 1) {
            self.currentFileURLIndex += 1
            playVideo()
            player?.play()
            self.isPlaying = true
        } else {
            self.player?.pause()
            self.isPlaying = false
        }
        
        let image = UIImage(systemName: self.isPlaying ? "pause.fill" : "play.fill", withConfiguration: self.symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        self.playButton.setImage(image, for: .normal)
    }
    
    @objc func didTapMuteButton() {
        print("didTapMuteButton")
        
        self.isMuted.toggle()
        
        let image = UIImage(systemName: isMuted ? "speaker.slash.fill" : "speaker.fill", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        self.muteButton.setImage(image, for: .normal)
        
        self.player?.isMuted = isMuted
    }
    
    @objc func didTapNextVideoButton() {
        print("didTapNextVideoButton")
        
        self.player?.pause()
        self.isPlaying = false
        
        let image = UIImage(systemName: "play.fill", withConfiguration: self.symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        self.playButton.setImage(image, for: .normal)
        
        self.currentFileURLIndex += 1
        playVideo()
    }
    
    @objc func didTapPrevVideoButton() {
        print("didTapPrevVideoButton")
        
        self.player?.pause()
        self.isPlaying = false
        
        let image = UIImage(systemName: "play.fill", withConfiguration: self.symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        self.playButton.setImage(image, for: .normal)
    
        self.currentFileURLIndex -= 1
        playVideo()
    }
    
    @objc func didTapSaveButton() {
        guard let video = allMP4FilesURLs[currentFileURLIndex] else { return }
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                do {
                    try PHPhotoLibrary.shared().performChangesAndWait {
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: video)
                        print("Video was saved to Camera Roll")
                    }
                } catch let error {
                    print("Failed to save video to Camera Roll: ", error)
                }
            } else {
                print("Error occured while saving video")
            }
        }
    }
    
    func playVideo() {
        if currentFileURLIndex < 0 {
            self.currentFileURLIndex = allMP4FilesURLs.count - 1
        } else if currentFileURLIndex >= allMP4FilesURLs.count {
            self.currentFileURLIndex = 0
        }
        
        title = "\(allMP4FilesURLs[currentFileURLIndex]?.lastPathComponent ?? "No description")"
        setupPlayer()
    }
}

