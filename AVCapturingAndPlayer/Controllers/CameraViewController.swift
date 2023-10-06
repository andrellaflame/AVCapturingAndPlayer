//
//  CameraViewController.swift
//  AVCapturingAndPlayer
//
//  Created by Andrii Sulimenko on 04.10.2023.
//

import Foundation
import UIKit

class CameraViewController: UIViewController {
    
    // MARK: UI elements
    private let captureButton = UIButton()
    private let pictureModeButton = UIButton()
    private let videoModeButton = UIButton()
    private let flipCameraButton = UIButton()
    private let previewView = UIView()
    private var loadingView: LoadingView?
    
    private let cameraManager = CameraManager()
    private var pictureModeIsOn = true
    private var videoRecordingStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        title = "Camera"
        
        view.addSubview(previewView)
        previewView.backgroundColor = .clear
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        setupCaptureButton()
        setupPictureModeButton()
        setupVideoModeButton()
        setupFlipCameraButton()
        setupConstraints()
        
        configureAVCaptureSession()
        
        self.loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.addSubview(self.loadingView!)
        self.loadingView?.center = view.center
    }
    
    // MARK: AVCaptureSession config
    func configureAVCaptureSession() {
        cameraManager.prepare {(error) in
            if let error = error {
                print(error)
            }
            try? self.cameraManager.displayPreview(inside: self.previewView)
            self.loadingView?.removeFromSuperview()
        }
    }

    // MARK: UI elements setups
    func setupCaptureButton() {
        view.addSubview(captureButton)
        
        captureButton.addTarget(self, action: #selector(didTapCaptureButton), for: .touchUpInside)
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        let image = UIImage(systemName: "circle.fill", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)

        captureButton.setImage(image, for: .normal)
        captureButton.tintColor = .label

        captureButton.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    }
    
    func setupPictureModeButton() {
        view.addSubview(pictureModeButton)
        
        pictureModeButton.addTarget(self, action: #selector(didTapPictureModeButton), for: .touchUpInside)
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "camera.circle", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)

        pictureModeButton.setImage(image, for: .normal)
        pictureModeButton.tintColor = .systemYellow

        pictureModeButton.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    }
    
    func setupVideoModeButton() {
        view.addSubview(videoModeButton)
        
        videoModeButton.addTarget(self, action: #selector(didTapVideoModeButton), for: .touchUpInside)
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "video.circle", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)

        videoModeButton.setImage(image, for: .normal)
        videoModeButton.tintColor = .label

        videoModeButton.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    }
    
    func setupFlipCameraButton() {
        view.addSubview(flipCameraButton)
        
        flipCameraButton.addTarget(self, action: #selector(didTapFlipCameraButton), for: .touchUpInside)
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let image = UIImage(systemName: "arrow.triangle.2.circlepath.camera", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)

        flipCameraButton.setImage(image, for: .normal)
        flipCameraButton.tintColor = .label

        flipCameraButton.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    }
    
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        pictureModeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pictureModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pictureModeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        videoModeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            videoModeButton.topAnchor.constraint(equalTo: pictureModeButton.bottomAnchor, constant: 16)
        ])
        
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            flipCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            flipCameraButton.topAnchor.constraint(equalTo: videoModeButton.bottomAnchor, constant: 16)
        ])
    }
    
    // MARK: Targets
    
    @objc func didTapCaptureButton() {
        print("didTapCaptureButton")
        if pictureModeIsOn {
            cameraManager.takePicture()
            print("Picture was taken")
        } else {
            
            if videoRecordingStarted {
                // stop recording
                print("Recording stopped")
                self.cameraManager.stopRecording { (error) in
                    print("Error occured while stopping recording: \(error?.localizedDescription ?? "unknown error")")
                }
                
                self.captureButton.tintColor = .label
            } else {
                // start recording
                print("Recording started")
                self.cameraManager.startRecording { (url, error)  in
                    guard let url = url else {
                        print("Error occured while starting recording: \(error?.localizedDescription ?? "unknown error")")
                        return
                    }
                    
                    print("Video saved in: \(url)")
                }
                self.captureButton.tintColor = .systemRed
            }
            self.videoRecordingStarted.toggle()
        }
    }
    
    @objc func didTapPictureModeButton() {
        if !pictureModeIsOn {
            self.pictureModeIsOn = true
            self.videoModeButton.tintColor = .label
            self.pictureModeButton.tintColor = .systemYellow
        }
        
        if videoRecordingStarted {
            self.videoRecordingStarted = false
            self.captureButton.tintColor = .label
            // stop recording
            
            print("Recording stopped")
            self.cameraManager.stopRecording { (error) in
                print("Error occured while stopping recording: \(error?.localizedDescription ?? "unknown error")")
            }
        }
        print("didTapPictureModeButton: pictureModeIsOn equals to \(pictureModeIsOn)")
    }
    
    @objc func didTapVideoModeButton() {
        if pictureModeIsOn {
            self.pictureModeIsOn = false
            self.pictureModeButton.tintColor = .label
            self.videoModeButton.tintColor = .systemYellow
        }

        print("didTapPictureModeButton: pictureModeIsOn equals to \(pictureModeIsOn)")
    }
    
    @objc func didTapFlipCameraButton() {
        print("didTapFlipCameraButton")
        if videoRecordingStarted {
            self.videoRecordingStarted = false
            self.captureButton.tintColor = .label
            // stop recording
            
            print("Recording stopped")
            self.cameraManager.stopRecording { (error) in
                print("Error occured while stopping recording: \(error?.localizedDescription ?? "unknown error")")
            }
        }
        
        cameraManager.switchCameras()
    }
}
