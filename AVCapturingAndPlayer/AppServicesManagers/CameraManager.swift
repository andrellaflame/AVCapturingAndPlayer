//
//  CameraController.swift
//  AVCapturingAndPlayer
//
//  Created by Andrii Sulimenko on 04.10.2023.
//

import Foundation
import AVFoundation
import UIKit

class CameraManager: NSObject {
    
    // MARK: Config properties
    var captureSession: AVCaptureSession?
        
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var videoOutput: AVCaptureMovieFileOutput?
    var videoRecordCompletionBlock: ((URL?, Error?) -> Void)?
    
    var audioDevice: AVCaptureDevice?
    var audioInput: AVCaptureDeviceInput?
    
    var currentCameraPosition: CameraPosition?
    var photoOutput: AVCapturePhotoOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
        
    // MARK: AVCaptureSession config & error handling
    // Nested function for AVCaptureSession config and error handling
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
            
            let cameras = session.devices.compactMap { $0 }
            guard !cameras.isEmpty else {
                throw CameraControllerError.noCamerasAvailable
            }
            
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
            
            self.audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { 
                    captureSession.addInput(self.rearCameraInput!)
                }
                
                self.currentCameraPosition = .rear
            } else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)
                }
                else {
                    throw CameraControllerError.inputsAreInvalid
                }
                self.currentCameraPosition = .front
            } else {
                throw CameraControllerError.noCamerasAvailable
            }
            
            if let audioDevice = self.audioDevice {
                self.audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if captureSession.canAddInput(self.audioInput!) {
                    captureSession.addInput(self.audioInput!)
                } else {
                    throw CameraControllerError.inputsAreInvalid
                }
            }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.addOutput(self.photoOutput!)
            }
            captureSession.startRunning()
        }
        
        func configureVideoOutput() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            self.videoOutput = AVCaptureMovieFileOutput()
            if captureSession.canAddOutput(self.videoOutput!) {
                captureSession.addOutput(self.videoOutput!)
            }
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
                try configureVideoOutput()
            }
            
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(inside view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.previewLayer?.frame = view.bounds
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        CATransaction.commit()
    }
    
    func switchCameras() {
        captureSession?.beginConfiguration()
        
        let currentInput = captureSession?.inputs.first as? AVCaptureDeviceInput
        captureSession?.removeInput(currentInput!)
        
        let newCameraDevice = currentInput?.device.position == .back ? getCamera(with: .front) : getCamera(with: .back)
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        
        captureSession?.addInput(newVideoInput!)
        
        if let audioInput = self.audioInput {
            captureSession?.removeInput(audioInput)
        }
        
        if let audioDevice = self.audioDevice {
            self.audioInput = try? AVCaptureDeviceInput(device: audioDevice)
            if captureSession?.canAddInput(self.audioInput!) == true {
                captureSession?.addInput(self.audioInput!)
            }
        }
        
        captureSession?.commitConfiguration()
    }
    
    func getCamera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .builtInTelephotoCamera]
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: position)
        
        return discoverySession.devices.first
    }
    
    // MARK: Picture capture
    func takePicture() {
        let settings = AVCapturePhotoSettings(
            format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        
        settings.isPortraitEffectsMatteDeliveryEnabled = false
        settings.photoQualityPrioritization = .balanced
        
        if let previewPhotoPixelFormatType = settings.availablePreviewPhotoPixelFormatTypes.first {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
        
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: Video recording
    func startRecording(completion: @escaping (URL?, Error?) -> Void) {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var fileUrl = paths[0].appendingPathComponent("recording.mp4")

        var version = 0
        while FileManager.default.fileExists(atPath: fileUrl.path) {
            version += 1
            let fileName = "recording\(version).mp4"
            fileUrl = paths[0].appendingPathComponent(fileName)
        }

        videoOutput?.startRecording(to: fileUrl, recordingDelegate: self)
        self.videoRecordCompletionBlock = completion
    }

    func stopRecording(completion: @escaping (Error?) -> Void) {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            completion(CameraControllerError.captureSessionIsMissing)
            return
        }

        self.videoOutput?.stopRecording()
    }
}

// MARK: Extensions
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var fileUrl = paths[0].appendingPathComponent("picture.jpeg")
        
        
        var version = 0
        while FileManager.default.fileExists(atPath: fileUrl.path) {
            version += 1
            let fileName = "picture\(version).jpeg"
            fileUrl = paths[0].appendingPathComponent(fileName)
        }
        
        try! imageData.write(to: fileUrl)
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            self.videoRecordCompletionBlock?(outputFileURL, nil)
        } else {
            self.videoRecordCompletionBlock?(nil, error)
        }
    }
}


extension CameraManager {
    // MARK: Error cases
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    // MARK: Camera positions
    public enum CameraPosition {
        case front
        case rear
    }
}
