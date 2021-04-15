//
//  SelfieViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol SelfieViewModelDelegate: class {
  func selfieViewModel(_ viewModel: SelfieViewModel,
                       didRequestToShowMakeSelfieScreenWithCredentials credentials: LivenessCredentials)
}

class SelfieViewModel: BindableViewModel {
  typealias Dependencies = HasApplicationService
  
  // MARK: - Properties
  
  weak var delegate: SelfieViewModelDelegate?
  
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidLoadData: (() -> Void)?
  
  private let application: LeasingEntity
  private let dependencies: Dependencies
  
  private var credentials: LivenessCredentials?
  
  // MARK: - Init
  
  init(application: LeasingEntity, dependencies: Dependencies) {
    self.application = application
    self.dependencies = dependencies
  }
  
  // MARK: - Public methods
  
  func loadData() {
    onDidStartRequest?()
    dependencies.applicationService.startLivenessSession(applicationID: application.applicationID).ensure {
      self.onDidFinishRequest?()
    }.done { credentials in
      self.credentials = credentials
      self.onDidLoadData?()
    }.catch { error in
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }
  
  func takeSelfiePhoto() {
    guard let credentials = credentials else { return }
    delegate?.selfieViewModel(self, didRequestToShowMakeSelfieScreenWithCredentials: credentials)
  }
}
