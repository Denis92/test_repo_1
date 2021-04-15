//
//  RegisterViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol RegisterViewModelDelegate: class {
  func registerViewModel(_ viewModel: RegisterViewModel, didFinishWithSessionID sessionID: String)
  func registerViewModel(_ viewModel: RegisterViewModel, didRequestOpeURL url: URL)
}

extension RegisterViewModelDelegate {
  func registerViewModel(_ viewModel: RegisterViewModel, didFinishWithSessionID sessionID: String) {}
}

class RegisterViewModel {
  // MARK: - Type
  typealias ContainerFieldType = RegisterFieldType
  typealias Dependencies = HasAuthService & HasPersonalDataRegisterService & HasUserDataStore
  
  // MARK: - Properties
  var shouldUseSavedPhoneNumber: Bool {
    return false
  }
  
  var isValid: Bool {
    return isValidPhone && isValidMail && isValidAgreements
  }
  
  var title: String? {
    return R.string.auth.registrationTitle()
  }
  
  var allAgreements: [AgreementType] {
    return [.registerPersonalData]
  }
  
  var defaultPhoneNumber: String? {
    var phone = Constants.phoneInitialValue
    if shouldUseSavedPhoneNumber {
      return phone
    }
    if let userPhone = dependencies.userDataStore.phoneNumber {
      phone += userPhone
    }
    return phone
  }
  
  var fields: [AnyFieldType<RegisterFieldType>] {
    return RegisterFieldType.allCases.map { AnyFieldType(type: $0, isEnabled: true) }
  }
  
  var onDidFinishRequest: ((_ completion: (() -> Void)?) -> Void)?
  var onDidStartRequest: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?
  var onValidityUpdate: (() -> Void)?
  var onDidRequestUpdateEmail: ((String) -> Void)?
  
  weak var delegate: RegisterViewModelDelegate?
  
  private(set) lazy var agreements = makeCheckboxAgreementViewModels()
  private var selectedAgreements: Set<AgreementType> = [] {
    didSet {
      onValidityUpdate?()
    }
  }
  
  private var isValidAgreements: Bool {
    return allAgreements.allSatisfy { selectedAgreements.contains($0) }
  }
  
  private var isValidPhone: Bool = false {
    didSet {
      onValidityUpdate?()
    }
  }
  
  private var isValidMail: Bool = false {
    didSet {
      onValidityUpdate?()
    }
  }
  
  private let dependencies: Dependencies
  
  private(set) lazy var fieldConfigurators = makeFieldConfigurators()
  private(set) var phone: String?
  private(set) var email: String?
  
  // MARK: - Init
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
 }
  
  // MARK: - Public
  func didTapConfirm() {
    guard let phone = phone, let email = email else { return }
    onDidStartRequest?()
    firstly {
      dependencies.authService.register(email: email, phone: phone)
    }.done { response in
      self.dependencies.userDataStore.phoneNumber = phone
      self.onDidFinishRequest? { [weak self, response] in
        guard let self = self else { return }
        self.delegate?.registerViewModel(self, didFinishWithSessionID: response.sessionID)
      }
    }.catch { error in
      self.onDidReceiveError?(error)
    }
  }
  
  // MARK: - Private
  private func makeCheckboxAgreementViewModels() -> [AgreementCheckboxViewModel] {
    return allAgreements
      .map { AgreementCheckboxViewModel(type: $0,
                                        isSelected: selectedAgreements.contains($0),
                                        onDidToggleCheckbox: makeOnDidToggleCheckboxClosure(for: $0),
                                        onDidSelectURL: makeOnDidSelectURLClosure())
      }

  }
  
  private func makeOnDidToggleCheckboxClosure(for agreementType: AgreementType) -> ((Bool) -> Void) {
    return { [weak self] isSelected in
      guard let self = self else { return }
      if isSelected {
        self.selectedAgreements.insert(agreementType)
      } else {
        self.selectedAgreements.remove(agreementType)
      }
    }
  }
  
  private func makeOnDidSelectURLClosure() -> ((URL) -> Void) {
    return { [weak self] url in
      guard let self = self else { return }
      guard UIApplication.shared.canOpenURL(url) else { return }
      self.delegate?.registerViewModel(self, didRequestOpeURL: url)
    }
  }
  
  private func makeFieldConfigurators() -> [FieldConfigurator<AnyFieldType<RegisterFieldType>>] {
      return fields.map { fieldType in
        let configurator = FieldConfigurator(fieldType: fieldType)
        configurator.onValidityUpdated = { [weak self] isValid in
          if fieldType.wrapped == .phoneNumber {
            self?.isValidPhone = isValid
          } else {
            self?.isValidMail = isValid
          }
        }
        configurator.onDidChangeText = { [weak configurator, weak self] text in
          if configurator?.type.wrapped == .email {
            self?.email = text
          } else {
            self?.phone = text?.sanitizedPhoneNumber()
          }
          configurator?.validate(silent: true)
        }
        return configurator
      }
  }
}
