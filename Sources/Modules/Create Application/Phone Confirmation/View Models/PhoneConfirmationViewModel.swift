//
//  PhoneConfirmationViewModel.swift
//  ForwardLeasing
//

import PromiseKit
import UIKit

protocol PhoneConfirmationViewModelDelegate: class {
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didFinishWithApplication application: LeasingEntity)
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didFinishTokenRefreshWithCompletion completion: (() -> Void)?)
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didRequestShowApplicationList applicationList: [LeasingEntity])
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didConfirmRegisterOTPWithSessionID sessionID: String,
                                  withPinCodeConfirmationType type: PinCodeConfirmationType)
  func phoneConfirmationViewModelDidSignIn(_ viewModel: PhoneConfirmationViewModel)
  func phoneConfirmationViewModelDidRequestToFinishFlow(_ viewModel: PhoneConfirmationViewModel)
}

extension PhoneConfirmationViewModelDelegate {
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didFinishWithApplication application: LeasingEntity) {}
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didFinishTokenRefreshWithCompletion completion: (() -> Void)?) {}
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didConfirmRegisterOTPWithSessionID sessionID: String,
                                  withPinCodeConfirmationType type: PinCodeConfirmationType) {}
  func phoneConfirmationViewModel(_ viewModel: PhoneConfirmationViewModel,
                                  didRequestShowApplicationList applicationList: [LeasingEntity]) {}
  func phoneConfirmationViewModelDidSignIn(_ viewModel: PhoneConfirmationViewModel) {}
  func phoneConfirmationViewModelDidRequestToFinishFlow(_ viewModel: PhoneConfirmationViewModel) {}
}

private extension Constants {
  static let codeCount = 4
}

private enum PhoneConfirmationError: LocalizedError {
  case otherApplicationsActive(applications: [LeasingEntity]), wrongOTPCode
  var errorDescription: String? {
    switch self {
    case .wrongOTPCode:
      return R.string.networkErrors.errorMismatchOtpText()
    default:
      return nil
    }
  }
}

class PhoneConfirmationViewModel: SessionRefreshing {
  // MARK: - Types
  typealias Dependencies = HasPersonalDataRegisterService & HasTokenStorage & HasApplicationService & HasUserDataStore
  
  // MARK: - Properties
  var title: String? {
    return strategyType.strategy.title
  }
  
  var remainTimeTitle: String? {
    if remainTimeInterval == 0 {
      return nil
    }
    let phoneConfirmationText = strategyType.strategy.phoneConfirmationTitle
    let remainTimeString = remainTimeInterval.timerString()
    let fullTitle = "\(phoneConfirmationText) \(R.string.auth.codeConfirmationRemainTime(remainTimeString))"
    return timer == nil ? phoneConfirmationText : fullTitle
  }
  
  var isHiddenRemainTimeLabel: Bool {
    return remainTimeInterval == 0
  }
  
  var isEnabledRepeatCodeButton: Bool {
    return remainTimeInterval == 0
  }
  
  var codeCount: Int {
    return Constants.codeCount
  }
  
  var onDidReceiveError: ((Error) -> Void)?
  var onDidUpdateTime: (() -> Void)?
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: ((_ completion: (() -> Void)?) -> Void)?
  var onDidUpdateCode: (() -> Void)?
  var onDidResetCode: (() -> Void)?
  var onDidRequestToShowWrongCodeAlert: ((String) -> Void)?
  
  weak var delegate: PhoneConfirmationViewModelDelegate?
  
  private (set) lazy var codeViewModel = CodeViewModel(filled: filled, count: codeCount)
  private (set) var isRefreshingSession = false
  private var sessionRefreshPromiseResolver: (promise: Promise<Void>, resolver: Resolver<Void>)?
  
  private var timer: Timer?
  
  private var onDidFinish: (() -> Void)?
  
  private var remainTimeInterval: TimeInterval {
    didSet {
      if remainTimeInterval == 0 {
        timer?.invalidate()
        timer = nil
      }
      onDidUpdateTime?()
    }
  }
  
  private var filled: Int = 0 {
    didSet {
      codeViewModel = CodeViewModel(filled: filled, count: codeCount)
      onDidUpdateCode?()
      if filled == codeCount {
        checkCode()
      }
    }
  }
  private var code: String?
  private var codeIsValid: Int {
    return code?.count ?? 0
  }
  private var requestID: String
  
  private let dependencies: Dependencies
  private let strategyType: PhoneConfirmStrategyType
  private let showWrogCodeErrorAsAlert: Bool
  private var isLoading: Bool = false
  
  init(dependencies: Dependencies,
       strategyType: PhoneConfirmStrategyType,
       showWrogCodeErrorAsAlert: Bool = false) {
    self.strategyType = strategyType
    self.remainTimeInterval = TimeInterval(dependencies.userDataStore.smsRepeatTimeout)
    self.showWrogCodeErrorAsAlert = showWrogCodeErrorAsAlert
    self.requestID = strategyType.requestID
    self.dependencies = dependencies
    onDidFinish = { [weak self] in
      self?.handleFinish()
    }
    if strategyType.strategy.shouldImmediatelySendOTPRequest {
      repeatCode()
    }
  }
  
  deinit {
    sessionRefreshPromiseResolver?.resolver.reject(NetworkErrorService.requestCreationError)
  }
  
  // MARK: - Public Methods
  func finishTokenRefeshIfNeeded() {
    if sessionRefreshPromiseResolver != nil {
      dependencies.tokenStorage.accessToken = nil
    }
    sessionRefreshPromiseResolver?.resolver.reject(NetworkErrorService.requestCreationError)
    sessionRefreshPromiseResolver = nil
  }
  
  func updateCode(_ code: String?) {
    self.code = code
    filled = code?.count ?? 0
  }
  
  func startTimer() {
    let timer = Timer(timeInterval: 1, target: self,
                      selector: #selector(handleTime), userInfo: nil, repeats: true)
    self.timer = timer
    RunLoop.main.add(timer, forMode: .default)
    onDidUpdateTime?()
  }
  
  func repeatCode() {
    stopTimer()
    reset()
    startTimer()
    firstly {
      strategyType.strategy.resendSMS(id: requestID)
    }.catch { error in
      self.handleError(error)
    }
  }
  
  func finish() {
    onDidFinish?()
  }
  
  func refreshSession() -> Promise<Void> {
    let sessionRefreshPromiseResolver = Promise<Void>.pending()
    self.sessionRefreshPromiseResolver = sessionRefreshPromiseResolver
    return sessionRefreshPromiseResolver.promise
  }
  
  // MARK: - Private Methods
  @objc private func handleTime() {
    remainTimeInterval -= 1
  }
  
  private func stopTimer() {
    timer?.invalidate()
    timer = nil
    remainTimeInterval = TimeInterval(dependencies.userDataStore.smsRepeatTimeout)
  }
  
  private func checkCode() {
    guard let code = code, !isLoading else { return }
    isLoading = true
    onDidStartRequest?()
    firstly {
      strategyType.strategy.checkOTP(code: code, id: requestID)
    }.ensure {
      self.isLoading = false
    }.then { response -> Promise<Void> in
      self.handleResponse(response)
    }.done { _ in
      self.onDidFinishRequest? {
        self.finish()
      }
    }.catch { error in
      if case PhoneConfirmationError.otherApplicationsActive(let applications) = error {
        self.onDidFinishRequest? {
          self.delegate?.phoneConfirmationViewModel(self, didRequestShowApplicationList: applications)
        }
      } else {
        self.onDidFinishRequest? {
          self.handleError(error)
        }
      }
    }
  }
  
  private func handleResponse(_ response: CheckCodeResult) -> Promise<Void> {
    guard response.resultCode == .ok else {
      return Promise(error: PhoneConfirmationError.wrongOTPCode)
    }
    
    stopTimer()
    
    if let token = response.token {
      dependencies.tokenStorage.accessToken = token
      delegate?.phoneConfirmationViewModelDidSignIn(self)
    }
    switch strategyType {
    case .leasingApplication(_, let application):
      return Promise { seal in
        firstly {
          checkOtherApplications(application: application)
        }.done { _ in
          seal.fulfill(())
        }.catch { error in
          seal.reject(error)
        }
      }
    case .pin, .tokenRefresh, .leasingContract, .signDelivery:
      return Promise.value(())
    }
  }
  
  private func handleError(_ error: Error) {
    if (error as? CustomServerError)?.errorType == .numberOfRequestsExceeded {
      onDidReceiveError?(error)
      delegate?.phoneConfirmationViewModelDidRequestToFinishFlow(self)
      return
    }
    
    if case PhoneConfirmationError.wrongOTPCode = error, showWrogCodeErrorAsAlert {
      if strategyType.isPinRecovery {
        onDidRequestToShowWrongCodeAlert?(R.string.auth.wrongPinCodeAlertTitle())
      } else {
        onDidRequestToShowWrongCodeAlert?(R.string.auth.wrongCodeAlertTitle())
      }
    } else {
      onDidReceiveError?(error)
    }
    reset()
  }
  
  private func handleFinish() {
    reset()
    switch strategyType {
    case .leasingApplication(_, let leasingEntity), .leasingContract(_, let leasingEntity), .signDelivery(_, let leasingEntity):
      delegate?.phoneConfirmationViewModel(self, didFinishWithApplication: leasingEntity)
    case .tokenRefresh:
      delegate?.phoneConfirmationViewModel(self) {
        self.finishTokenRefreshFlow()
      }
    case .pin(_, let sessionID, let type):
      delegate?.phoneConfirmationViewModel(self, didConfirmRegisterOTPWithSessionID: sessionID,
                                           withPinCodeConfirmationType: type)
    }
  }
  
  private func reset() {
    code = nil
    filled = 0
    onDidResetCode?()
  }
  
  private func checkOtherApplications(application: LeasingEntity) -> Promise<[LeasingEntity]> {
    return Promise { seal in
      firstly {
        dependencies.applicationService.checkOtherApplications(applicationID: application.applicationID)
      }.done { applications in
        if !applications.isEmpty {
          var list = [application]
          list.append(contentsOf: applications)
          seal.reject(PhoneConfirmationError.otherApplicationsActive(applications: list))
        } else {
          seal.fulfill([])
        }
      }.catch { _ in
        seal.fulfill([])
      }
    }
  }
  
  private func finishTokenRefreshFlow() {
    sessionRefreshPromiseResolver?.resolver.fulfill(())
    sessionRefreshPromiseResolver = nil
  }
}
