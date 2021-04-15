//
//  PassportScanViewModel.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let maxImageSize = 2 * 1024 * 1024
  static let imageTargetSideLength: CGFloat = 1024
  static let flowFinishingServerErrorCodes: [Int] = [2110, 2115]
}

protocol PassportScanViewModelDelegate: class {
  func passportScanViewModelDidRequestToFinishFlow(_ viewModel: PassportScanViewModel)
  func passportScanViewModelDidRequestToTakePhoto(_ viewModel: PassportScanViewModel)
  func passportScanViewModelDidRequestToUploadFromLibrary(_ viewModel: PassportScanViewModel)
  func passportScanViewModel(_ viewModel: PassportScanViewModel, didFinishWithImage image: UIImage?, passportData: DocumentData,
                             application: LeasingEntity)
}

enum PassportUploadError: LocalizedError {
  case uploadFailed(errorText: String?)
  var errorDescription: String? {
    switch self {
    case .uploadFailed(let errorText):
      return errorText
    }
  }
}

class PassportScanViewModel {
  typealias Dependencies = HasApplicationService
  
  // MARK: - Properties

  weak var delegate: PassportScanViewModelDelegate?
  
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?
  
  private let application: LeasingEntity
  private let dependencies: Dependencies
  
  // MARK: - Init
  
  init(application: LeasingEntity, dependencies: Dependencies) {
    self.application = application
    self.dependencies = dependencies
  }
  
  // MARK: - Public methods
  
  func takePhoto() {
    delegate?.passportScanViewModelDidRequestToTakePhoto(self)
  }
  
  func uploadFromLibrary() {
    delegate?.passportScanViewModelDidRequestToUploadFromLibrary(self)
  }
  
  func uploadPhoto(data: Data) {
    self.onDidStartRequest?()
    let compressedData = compressedImageData(targetSize: Constants.maxImageSize, data: data)
    let image = UIImage(data: compressedData)
    dependencies.applicationService.uploadPassportScan(applicationID: application.applicationID,
                                                       imageData: compressedData).done { response in
      guard let data = response.documentData, data.success else {
        self.onDidReceiveError?(PassportUploadError.uploadFailed(errorText: response.checkResultText))
        return
      }
      self.getApplication(passportData: data, image: image)
    }.catch { error in
      self.onDidFinishRequest?()
      self.onDidReceiveError?(error)
    }
  }
  
  // MARK: - Private methods

  private func getApplication(passportData: DocumentData, image: UIImage?) {
    dependencies.applicationService.getApplicationData(applicationID: application.applicationID).ensure {
      self.onDidFinishRequest?()
    }.done { application in
      self.delegate?.passportScanViewModel(self, didFinishWithImage: image,
                                           passportData: passportData,
                                           application: application)
    }.catch { error in
      self.handleApplicationDataError(error)
    }
  }
  
  private func compressedImageData(targetSize: Int, data: Data) -> Data {
    if data.count <= targetSize { return data }
    let data = UIImage(data: data)?.resize(to: Constants.imageTargetSideLength).jpegData(compressionQuality: 1) ?? .empty
    if data.count <= targetSize { return data }
    
    let compressionStep: CGFloat = 0.1
    let minCompressionAmount: CGFloat = 0.1
    var currentCompression: CGFloat = 1
    var currentData = data
    
    while currentData.count > targetSize, currentCompression > minCompressionAmount {
      currentCompression -= compressionStep
      currentData = UIImage(data: data)?.jpegData(compressionQuality: currentCompression) ?? .empty
    }
    
    return currentData
  }
  
  private func handleApplicationDataError(_ error: Error) {
    onDidReceiveError?(error)
    if let errorCode = (error as? CustomServerError)?.code, Constants.flowFinishingServerErrorCodes.contains(errorCode) {
      delegate?.passportScanViewModelDidRequestToFinishFlow(self)
    }
  }
}
