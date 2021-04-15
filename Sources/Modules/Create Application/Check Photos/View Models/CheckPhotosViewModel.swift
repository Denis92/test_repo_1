//
//  CheckPhotosViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

protocol CheckPhotosViewModelDelegate: class {
  func checkPhotosViewModelDidRequestSelfie(_ viewModel: CheckPhotosViewModel)
  func checkPhotosViewModel(_ viewModel: CheckPhotosViewModel, didFinishSuccessfullyWithApplication
                              application: LeasingEntity)
}

private enum CheckPhotosViewModelError: Error {
  case wrongPhotoComparisonStatus, comparisonPending
}

class CheckPhotosViewModel {
  // MARK: - Types
  enum State {
    case pending
    case success
    case fail
    case error
    case applicationInfoError
    case noInternetError
  }
  
  typealias Dependency = HasCheckPhotosService & HasApplicationService
  
  // MARK: - Properties
  var onDidStartRequest: (() -> Void)?
  var onDidReceiveSuccessResult: (() -> Void)?
  var onDidReceiveFailResult: (() -> Void)?
  var onDidReceiveServerError: ((Error) -> Void)?
  var onDidReceiveNoInternetError: ((Error) -> Void)?

  weak var delegate: CheckPhotosViewModelDelegate?

  private var state: State = .pending

  private let application: LeasingEntity
  private let dependency: Dependency
  
  // MARK: - Init
  init(dependency: Dependency,
       application: LeasingEntity) {
    self.dependency = dependency
    self.application = application
  }
  
  // MARK: - Public
  
  func load() {
    state = .pending
    self.onDidStartRequest?()
    firstly {
      dependency.applicationService.checkLivenessPhoto(applicationID: application.applicationID)
    }.then { _ in
      self.checkPhotos()
    }.cauterize()
  }
  
  func didTapBottomButton() {
    switch state {
    case .error:
      delegate?.checkPhotosViewModelDidRequestSelfie(self)
    case .fail:
      load()
    default:
      break
    }
  }
  
  // MARK: - Private
  @discardableResult
  private func checkPhotos() -> Guarantee<LeasingEntity> {
    // swiftlint:disable:next closure_body_length
    return Guarantee { seal in
      firstly {
        self.dependency.checkPhotosService.checkPhotos(applicationID: self.application.applicationID)
      }.then { result in
        self.handle(result)
      }.then { _ in
        self.dependency.applicationService.getApplicationData(applicationID: self.application.applicationID)
      }.done { application in
        self.onDidReceiveSuccessResult?()
        seal(application)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          self.delegate?.checkPhotosViewModel(self, didFinishSuccessfullyWithApplication: application)
        }
      }.catch { error in
        if error is CheckPhotosViewModelError {
          DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.checkPhotos()
          }
          return
        }
        
        if self.state == .success { // getting application info failed
          self.delegate?.checkPhotosViewModel(self, didFinishSuccessfullyWithApplication: self.application)
          return
        }
        
        if NetworkErrorService.isOfflineError(error) {
          self.state = .noInternetError
          self.onDidReceiveNoInternetError?(error)
        } else {
          self.state = .error
          self.onDidReceiveServerError?(error)
        }
      }
    }
  }
  
  private func handle(_ result: CheckPhotosResult) -> Promise<Void> {
    switch result.status {
    case .rejected, .notChecked:
      state = .fail
      onDidReceiveFailResult?()
      return Promise(error: CheckPhotosViewModelError.wrongPhotoComparisonStatus)
    case .pending:
      return Promise(error: CheckPhotosViewModelError.comparisonPending)
    case .checkOff, .checkedSuccess:
      state = .success
      return Promise.value(())
    }
  }
}
