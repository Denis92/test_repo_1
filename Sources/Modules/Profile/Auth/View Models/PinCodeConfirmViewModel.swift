//
//  PinCodeViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

protocol PinCodeConfirmViewModelDelegate: class {
  func pinCodeConfirmViewModelDidFinish(_ viewModel: PinCodeConfirmViewModel)
}

class PinCodeConfirmViewModel {
  // MARK: - Types
  typealias Dependency = HasAuthService & HasTokenStorage
  
  // MARK: - Properties
  var onDidRequestResetPin: (() -> Void)?
  var onDidFailPinTry: ((String) -> Void)?
  var onDidUpdateFirstTry: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?
  var onDidUpdateCodeViewModel: (() -> Void)?
  
  var title: String {
    switch type {
    case .pinRecovery:
      return R.string.auth.pinCodeRecoveryTitle()
    case .registration:
      return R.string.auth.registrationTitle()
    case .pinUpdate:
      return R.string.profileSettings.updatePinCodeTitle()
    }
  }
  
  var pincodeTitle: String {
    return isFirstTry ? R.string.auth.pinCodeCreateTitle() : R.string.auth.pinCodeRepeatTitle()
  }
  
  weak var delegate: PinCodeConfirmViewModelDelegate?
  
  private let sessionID: String
  private let dependency: Dependency
  private var pin: String? {
    didSet {
      filled = pin?.count ?? 0
    }
  }
  private var isEnabledEditing: Bool = true
  
  private var filled: Int = 0 {
    didSet {
      updatePinTryIfNeeded()
      codeViewModel = makeCodeViewModel()
      onDidUpdateCodeViewModel?()
    }
  }
  private var firstPin: String?
  private let count = 4
  private var isFirstTry: Bool = true {
    didSet {
      if isFirstTry != oldValue {
        onDidUpdateFirstTry?()
      }
    }
  }
  private(set) lazy var codeViewModel = makeCodeViewModel()
  private let type: PinCodeConfirmationType
  
  // MARK: - Init
  init(dependency: Dependency,
       sessionID: String, type: PinCodeConfirmationType) {
    self.dependency = dependency
    self.sessionID = sessionID
    self.type = type
  }
  
  // MARK: - Public Methods
  func updatePin(_ pin: String?) {
    guard isEnabledEditing else { return }
    self.pin = pin
  }
  
  // MARK: - Private Methods
  private func savePinCode() {
    guard let pin = pin else { return }
    firstly {
      dependency.authService.savePin(pinCode: pin, sessionID: sessionID)
    }.done { response in
      self.dependency.tokenStorage.accessToken = response.token
      self.delegate?.pinCodeConfirmViewModelDidFinish(self)
    }.catch { error in
      self.onDidReceiveError?(error)
    }
  }
  
  private func updatePinTryIfNeeded() {
    guard filled == count else { return }
    if isFirstTry {
      self.firstPin = self.pin
      self.isFirstTry = false
      self.resetPin()
    } else if firstPin == pin {
      savePinCode()
    } else {
      self.onDidFailPinTry?(R.string.auth.pinCodeAlertMessage())
      resetPin()
    }
  }
  
  private func resetPin() {
    isEnabledEditing = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // to make last filled number visible
      self.pin = nil
      self.onDidRequestResetPin?()
      self.isEnabledEditing = true
    }
  }
  
  private func makeCodeViewModel() -> CodeViewModel {
    return CodeViewModel(filled: filled, count: count)
  }
}
