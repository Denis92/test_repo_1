//
//  PassportScanCoordinator.swift
//  ForwardLeasing
//

import UIKit

struct PassportScanCoordinatorConfiguration {
  let application: LeasingEntity
}

struct ScannedPassportData {
  let passportImage: UIImage?
  let passportData: DocumentData
}

protocol PassportScanCoordinatorDelegate: class {
  func passportScanCoordinator(_ coordinator: PassportScanCoordinator, didFinishWithImage image: UIImage?,
                               passportData: DocumentData,
                               application: LeasingEntity)
  func passportScanCoordinatorDidRequestFinishFlow(_ coordinator: PassportScanCoordinator)
}

class PassportScanCoordinator: NSObject, ConfigurableNavigationFlowCoordinator {
  typealias Configuration = PassportScanCoordinatorConfiguration
  // MARK: - Properties
  
  weak var delegate: PassportScanCoordinatorDelegate?
  
  let appDependency: AppDependency
  let navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  private var onDidReceiveImageData: ((Data) -> Void)?
  private let configuration: Configuration
  
  // MARK: - Init
  
  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    self.configuration = configuration
  }
  
  // MARK: - Navigation
  
  func start(animated: Bool) {
    showPassportScanScreen(animated: animated)
  }
  
  private func showPassportScanScreen(animated: Bool) {
    let viewModel = PassportScanViewModel(application: configuration.application, dependencies: appDependency)
    viewModel.delegate = self
    onDidReceiveImageData = { [weak viewModel] data in
      viewModel?.uploadPhoto(data: data)
    }
    let viewController = PassportScanViewController(viewModel: viewModel)
    viewController.delegate = self
    viewController.title = configuration.application.productInfo.productName
    navigationController.pushViewController(viewController, animated: animated)
  }
  
  private func showPassportScanCameraScreen() {
    let viewModel = PassportScanCameraViewModel()
    viewModel.delegate = self
    let viewController = PassportScanCameraViewController(viewModel: viewModel)
    viewController.delegate = self
    viewController.modalPresentationStyle = .fullScreen
    navigationController.present(viewController, animated: true, completion: nil)
  }
  
  private func showImagePicker() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.allowsEditing = false
    imagePickerController.delegate = self
    DispatchQueue.main.async {
      self.navigationController.present(imagePickerController, animated: true, completion: nil)
    }
  }
}

// MARK: - PassportScanViewControllerDelegate

extension PassportScanCoordinator: PassportScanViewControllerDelegate {
  func passportScanViewControllerDidFinish(_ viewController: PassportScanViewController) {
    delegate?.passportScanCoordinatorDidRequestFinishFlow(self)
  }
}

// MARK: - PassportScanViewModelDelegate

extension PassportScanCoordinator: PassportScanViewModelDelegate {
  func passportScanViewModelDidRequestToTakePhoto(_ viewModel: PassportScanViewModel) {
    showPassportScanCameraScreen()
  }
  
  func passportScanViewModelDidRequestToUploadFromLibrary(_ viewModel: PassportScanViewModel) {
    showImagePicker()
  }
  
  func passportScanViewModel(_ viewModel: PassportScanViewModel, didFinishWithImage image: UIImage?, passportData: DocumentData,
                             application: LeasingEntity) {
    delegate?.passportScanCoordinator(self, didFinishWithImage: image, passportData: passportData, application: application)
  }
  
  func passportScanViewModelDidRequestToFinishFlow(_ viewModel: PassportScanViewModel) {
    delegate?.passportScanCoordinatorDidRequestFinishFlow(self)
  }
}

// MARK: - PassportScanCameraViewControllerDelegate

extension PassportScanCoordinator: PassportScanCameraViewControllerDelegate {
  func passportScanCameraViewControllerDidFinish(_ viewController: PassportScanCameraViewController) {
    navigationController.dismiss(animated: true, completion: nil)
  }
}

// MARK: - PassportScanCameraViewModelDelegate

extension PassportScanCoordinator: PassportScanCameraViewModelDelegate {
  func passportScanCameraViewModel(_ viewModel: PassportScanCameraViewModel,
                                   didTakePhotoWithImageData data: Data) {
    navigationController.dismiss(animated: true) { [weak self] in
      guard let self = self else { return }
      self.onDidReceiveImageData?(data)
    }
  }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension PassportScanCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    navigationController.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    navigationController.dismiss(animated: true) { [weak self] in
      guard let self = self, let data = (info[.originalImage] as? UIImage)?.jpegData(compressionQuality: 1) else { return }
      self.onDidReceiveImageData?(data)
    }
  }
}
