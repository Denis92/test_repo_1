//
//  IdentityConfirmationCheckViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

protocol IdentityConfirmationCheckViewModelDelegate: class {
  func identityConfirmationCheckViewModel(_ viewModel: IdentityConfirmationCheckViewModel,
                                          didRequestRepeatScanWithApplication application: LeasingEntity)
  func identityConfirmationCheckViewModel(_ viewModel: IdentityConfirmationCheckViewModel,
                                          didFinishWithApplication application: LeasingEntity)
  func identityConfirmationCheckViewModel(_ viewModel: IdentityConfirmationCheckViewModel,
                                          didRequestSelectApplicationFromList applicationList: [LeasingEntity],
                                          activeApplicationData: (LeasingEntity, ClientPersonalData)?)
}

class IdentityConfirmationCheckViewModel {
  // MARK: - Types
  typealias Dependencies = HasAuthService & HasTokenStorage & HasApplicationService & HasUserDataStore
  
  // MARK: - Properties
  var isEnabledCheckButton: Bool {
    return isValid
  }

  var title: String? {
    return application.productInfo.productName
  }
  
  var hasUserPhoto: Bool {
    return userPhotoURL != nil
  }

  var userPhotoURL: URL? {
    guard let imagePath = (application.clientImages.first(where: { $0.imageType == .selfie })?.imageURL ??
                            application.clientImages.first(where: { $0.imageType == .passport })?.imageURL) else {
      return nil
    }
    return URLFactory.imageURL(imagePath: imagePath)
  }
  
  var accessToken: String? {
    return dependencies.tokenStorage.accessToken
  }
  
  var hasPassportImage: Bool {
    return application.hasPassportImage
  }
  
  weak var delegate: IdentityConfirmationCheckViewModelDelegate?
  
  private(set) var items: [UserDataItemViewModel] = []
  private(set) var textEditConfigurators: [FieldConfigurator<IdentityConfirmationEditFieldType>] = []

  var onDidUpdateValidity: (() -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidUpdateItems: (() -> Void)?
  var onNeedsToHideErrorView: (() -> Void)?

  private var isValid: Bool = false
  private var application: LeasingEntity
  private let dependencies: Dependencies
  
  // MARK: - Init
  init(dependencies: Dependencies,
       application: LeasingEntity) {
    self.dependencies = dependencies
    self.application = application
    getClientInfo()
  }
  
  // MARK: - Public
  func confirmCheck() {
    guard let occupation = dependencies.userDataStore.occupationOptions
            .first(where: { $0.value == textEditConfigurators.first { $0.type == .typeOfEmployment }?.text })?.key,
          let salaryText = textEditConfigurators.first(where: { $0.type == .salary })?.sanitizedText,
          let salary = Int(salaryText) else {
      return
    }

    onDidStartRequest?()

    firstly {
      checkOtherApplications()
    }.then {
      // TODO: - remove stub
      self.dependencies.applicationService.saveClientData(monthlySalary: salary,
                                                          occupation: occupation,
                                                          applicationID: self.application.applicationID)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { _ in
      self.onNeedsToHideErrorView?()
      self.delegate?.identityConfirmationCheckViewModel(self, didFinishWithApplication: self.application)
    }.catch { error in
      if case IdentityConfirmationError.hasOtherApplications = error {
        return
      }
      if let customError = error as? CustomServerError, customError.errorType == .passportDataInvalid {
        self.onDidRequestToShowErrorBanner?(error)
        return
      }
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }
  
  func repeatScan() {
    delegate?.identityConfirmationCheckViewModel(self, didRequestRepeatScanWithApplication: application)
  }
  
  // MARK: - Private
  private func makeTextEditConfigurators(from clientInfo: MaskedClientInfo) -> [FieldConfigurator<IdentityConfirmationEditFieldType>] {
    let textEditConfigurators: [IdentityConfirmationEditFieldType] = [.typeOfEmployment, .salary]
    return textEditConfigurators.map {
      var pickerOptions: [String] = []
      if $0 == .typeOfEmployment {
        pickerOptions = dependencies.userDataStore.occupationOptions.map { $0.value }
      }
      let configurator = FieldConfigurator(fieldType: $0,
                                           text: initialText(for: $0, clientInfo: clientInfo),
                                           pickerOptions: pickerOptions)
      configurator.onDidChangeText = { [weak self, unowned configurator] text in
        guard let self = self else { return }
        try? self.validate()
      }
      return configurator
    }
  }

  private func initialText(for fieldType: IdentityConfirmationEditFieldType, clientInfo: MaskedClientInfo) -> String? {
    switch fieldType {
    case .typeOfEmployment:
      return dependencies.userDataStore.occupationOptions.first { $0.key == clientInfo.occupation  }?.value
    default:
      return nil
    }
  }

  private func getClientInfo() {
    firstly {
      dependencies.applicationService.getClientInfo()
    }.done { [weak self] response in
      self?.handle(response)
    }.catch { [weak self] error in
      self?.onDidRequestToShowEmptyErrorView?(error)
    }
  }
  
  private func handle(_ response: MaskedClientInfo) {
    self.items = makeUserDataItems(from: response)
    self.textEditConfigurators = makeTextEditConfigurators(from: response)
    onDidUpdateItems?()
  }
  
  private func makeUserDataItems(from clientInfo: MaskedClientInfo) -> [UserDataItemViewModel] {
    return IdentityConfirmationEditFieldType.allCases.filter {
      $0 != .apartmentNumber && $0 != .typeOfEmployment && $0 != .salary
    }.map { return makeUserDataItem(from: $0, clientInfo: clientInfo) }
  }
  
  // swiftlint:disable:next cyclomatic_complexity
  private func makeUserDataItem(from field: IdentityConfirmationEditFieldType,
                                clientInfo: MaskedClientInfo) -> UserDataItemViewModel {
    var value: String?
    switch field {
    case .lastname:
      value = clientInfo.lastName
    case .firstname:
      value = clientInfo.firstName
    case .middlename:
      value = clientInfo.middleName
    case .dateOfBirth:
      value = clientInfo.birthDate
    case .placeOfBirth:
      value = clientInfo.birthPlace
    case .passport:
      value = clientInfo.passport
    case .dateOfReceiving:
      value = clientInfo.issueDate
    case .issuedBy:
      value = clientInfo.issuer
    case .divisionCode:
      value = clientInfo.issuerCode
    case .registrationAddress:
      value = clientInfo.registrationAddress
    default:
      break
    }
    return UserDataItemViewModel(title: field.title, value: value, style: .textField)
  }

  private func validate(isSilent: Bool = true) throws {
    var isValid = true
    for configurator in textEditConfigurators {
      if !configurator.validate(silent: isSilent) {
        isValid = false
      }
    }
    self.isValid = isValid
    onDidUpdateValidity?()
    if !isValid {
      throw IdentityConfirmationError.notAllFieldsValid
    }
  }

  private func checkOtherApplications() -> Promise<Void> {
    return Promise { seal in
      firstly {
        self.dependencies.applicationService.checkOtherApplications(applicationID: application.applicationID)
      }.done { applications in
        if !applications.isEmpty {
          var list = [self.application]
          list.append(contentsOf: applications)
          // TODO - activeApplicationData: nil - remove when actual logic is known
          self.delegate?.identityConfirmationCheckViewModel(self,
                                                            didRequestSelectApplicationFromList: list,
                                                            activeApplicationData: nil)
          seal.reject(IdentityConfirmationError.hasOtherApplications)
        } else {
          seal.fulfill(())
        }
      }.catch { error in
        self.onDidRequestToShowEmptyErrorView?(error)
        seal.reject(IdentityConfirmationError.hasOtherApplications)
      }
    }
  }
}
