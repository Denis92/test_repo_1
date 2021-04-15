//
//  SendingApplicationViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol SendingApplicationViewModelDelegate: class {
  func sendingApplicationViewModel(_ viewModel: SendingApplicationViewModel,
                                   didFinishWithApplication application: LeasingEntity)
  func sendingApplicationViewModelDidRequestCheckLater(_ viewModel: SendingApplicationViewModel)
  func sendingApplicationViewModelDidCancelApplication(_ viewModel: SendingApplicationViewModel)
  func sendingApplicationViewModelDidRequestClose(_ viewModel: SendingApplicationViewModel)
}

class SendingApplicationViewModel {
  // MARK: - Types
  typealias Dependencies = HasApplicationService & HasContractService
  
  // MARK: - Delegate
  weak var delegate: SendingApplicationViewModelDelegate?
  
  // MARK: - Properties
  let longerThanNecessaryViewModel = LongerThanNecessaryViewModel()
  let timerViewModel = TimerViewModel(title: R.string.sendingApplication.ringViewTitle(),
                                      subtitle: R.string.sendingApplication.ringViewSubtitle())
  
  var onDidChangeState: ((SendingApplicationState) -> Void)?
  var onDidContinueLongerThanNeccessary: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidRequestToCancelLeasingEntity: ((_ callback: @escaping () -> Void) -> Void)?
  var onDidRequestToPresentActivityIndicator: (() -> Void)?
  var onDidRequestToHideActivityIndicator: (() -> Void)?
  
  private(set) var isFinishedTimer: Bool = false
  private(set) lazy var deniedViewModel = makeDeniedViewModel()
  private let dependencies: Dependencies
  private let application: LeasingEntity
  private var state: SendingApplicationState = .sending {
    didSet {
      handleState()
    }
  }
  
  // MARK: - Init
  init(dependencies: Dependencies,
       application: LeasingEntity) {
    self.dependencies = dependencies
    self.application = application
    self.timerViewModel.delegate = self
    self.longerThanNecessaryViewModel.delegate = self
  }
  
  // MARK: - Public
  func sendApplicationForScoring() {
    state = .sending
    firstly {
      dependencies.applicationService.sendApplicationForScoring(applicationID: application.applicationID)
    }.done { _ in
      self.state = .timer
      self.checkApplicationStatus()
    }.catch { _ in
      self.state = .notSent
    }
  }
  
  func close() {
    delegate?.sendingApplicationViewModelDidRequestClose(self)
  }
  
  func finish() {
    onDidStartRequest?()
    dependencies.contractService.createContract(applicationID: application.applicationID).ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      self.delegate?.sendingApplicationViewModel(self, didFinishWithApplication: self.application)
    }.catch { error in
      self.onDidReceiveError?(error)
    }
  }
  
  // MARK: - Private
  private func checkApplicationStatus() {
    firstly {
      dependencies.applicationService.checkApplicationStatus(applicationID: application.applicationID)
    }.done { leasingEntity in
      self.state = self.makeSendingStatus(for: leasingEntity.status)
    }.catch { _ in
      self.state = .notSent
    }
  }
  
  private func handleState() {
    if state != .timer {
      timerViewModel.stopTimer()
    }
    switch state {
    case .timer where !timerViewModel.isActive:
      if !timerViewModel.isActive {
        timerViewModel.startTimer()
      }
    case .notSent, .denied, .isImpossible:
      deniedViewModel = makeDeniedViewModel()
    case .longerThanNecessary:
      if !longerThanNecessaryViewModel.isActive {
        longerThanNecessaryViewModel.start()
      }
    default:
      break
    }
    if state == .timer || state == .longerThanNecessary {
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        self.checkApplicationStatus()
      }
    }
    onDidChangeState?(state)
  }
  
  private func cancelApplication() {
    onDidRequestToPresentActivityIndicator?()
    firstly {
      dependencies.applicationService.cancelApplication(applicationID: application.applicationID)
    }.ensure {
      self.onDidRequestToHideActivityIndicator?()
    }.done { _ in
      self.delegate?.sendingApplicationViewModelDidCancelApplication(self)
    }.catch { error in
      self.onDidReceiveError?(error)
    }
  }
  
  private func makeDeniedViewModel() -> DeniedViewModel {
    switch state {
    case .notSent:
      return DeniedViewModel(title: R.string.sendingApplication.failViewTitleDidNotSent(),
                             buttonTitle: R.string.sendingApplication.failViewButtonRepeat()) { [weak self] in
        self?.sendApplicationForScoring()
      }
    case .denied:
      return DeniedViewModel(title: R.string.sendingApplication.failViewTitleDenied(),
                             buttonTitle: R.string.common.close()) { [weak self] in
        guard let self = self else { return }
        self.delegate?.sendingApplicationViewModelDidRequestClose(self)
      }
    default:
      return DeniedViewModel(title: R.string.sendingApplication.failViewTitleIsImpossible(),
                             buttonTitle: R.string.common.close()) { [weak self] in
        guard let self = self else { return }
        self.delegate?.sendingApplicationViewModelDidRequestClose(self)
      }
    }
  }
  
  private func makeSendingStatus(for applicationStatus: LeasingEntityStatus) -> SendingApplicationState {
    switch applicationStatus {
    case .approved:
      return .approved
    case .confirmed, .draft, .dataSaved:
      return .notSent
    case .cancelled, .rejected, .error:
      return .denied
    default:
      if isFinishedTimer {
        return .longerThanNecessary
      } else {
        return .timer
      }
    }
  }
}

// MARK: - TimerViewModelDelegate
extension SendingApplicationViewModel: TimerViewModelDelegate {
  func timerViewModelDidFinish(_ viewModel: TimerViewModel) {
    if state == .timer {
      isFinishedTimer = true
      state = .longerThanNecessary
    }
  }
}

// MARK: - LongerThanNecessaryViewModelDelegate
extension SendingApplicationViewModel: LongerThanNecessaryViewModelDelegate {
  func longerThanNecessaryViewModelDidTapCheckLater(_ viewModel: LongerThanNecessaryViewModel) {
    delegate?.sendingApplicationViewModelDidRequestCheckLater(self)
  }
  
  func longerThanNecessaryViewModelDidTapCancel(_ viewModel: LongerThanNecessaryViewModel) {
    onDidRequestToCancelLeasingEntity? { [weak self] in
      self?.cancelApplication()
    }
  }
}
