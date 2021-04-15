//
//  PassportScanCameraViewModel.swift
//  ForwardLeasing
//

import AVFoundation

protocol PassportScanCameraViewModelDelegate: class {
  func passportScanCameraViewModel(_ viewModel: PassportScanCameraViewModel,
                                   didTakePhotoWithImageData data: Data)
}

enum PassportScanCameraError: Error, LocalizedError {
  case cameraNotSupported, captureFailed
  
  var errorDescription: String? {
    return localizedDescription
  }
  
  var localizedDescription: String {
    switch self {
    case .cameraNotSupported:
      return R.string.scanPassport.cameraNotSupportedErrorText()
    case .captureFailed:
      return R.string.scanPassport.captureFailedErrorText()
    }
  }
}

class PassportScanCameraViewModel: NSObject {
  weak var delegate: PassportScanCameraViewModelDelegate?
  
  var onDidStartCapturingPhoto: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?
  
  let captureSession = AVCaptureSession()
  let imageOutput = AVCapturePhotoOutput()
  
  func onViewIsReady() {
    DispatchQueue.main.async {
      self.setupCaptureSession()
    }
  }
  
  func takePhoto() {
    onDidStartCapturingPhoto?()
    let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    imageOutput.capturePhoto(with: settings, delegate: self)
  }
  
  private func setupCaptureSession() {
    captureSession.sessionPreset = .photo
    
    guard let camera = AVCaptureDevice.default(for: .video),
          let input = try? AVCaptureDeviceInput(device: camera),
          captureSession.canAddInput(input), captureSession.canAddOutput(imageOutput) else {
      onDidReceiveError?(PassportScanCameraError.cameraNotSupported)
      return
    }
    
    captureSession.addInput(input)
    captureSession.addOutput(imageOutput)
    
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.captureSession.startRunning()
    }
  }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension PassportScanCameraViewModel: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto,
                   error: Error?) {
    if let error = error {
      onDidReceiveError?(error)
      return
    }
    
    guard let imageData = photo.fileDataRepresentation() else {
      onDidReceiveError?(PassportScanCameraError.captureFailed)
      return
    }
    
    delegate?.passportScanCameraViewModel(self, didTakePhotoWithImageData: imageData)
  }
}
