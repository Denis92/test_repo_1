//
//  IdentityConfirmationEditViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

enum IdentityConfirmationError: Error {
  case notAllFieldsValid, notEnoughData, hasOtherApplications
}

protocol IdentityConfirmationEditViewModelDelegate: class {
  func identityConfirmationEditViewModel(_ viewModel: IdentityConfirmationEditViewModel,
                                         didRequestSelectApplicationFromList applicationList: [LeasingEntity],
                                         activeApplicationData: (LeasingEntity, ClientPersonalData)?)
  func identityConfirmationEditViewModel(_ viewModel: IdentityConfirmationEditViewModel,
                                         didFinishWithApplication application: LeasingEntity)
  func identityConfirmationEditViewModelDidRequestToForceFinish(_ viewModel: IdentityConfirmationEditViewModel)
}

struct IdentityConfirmationEditViewModelInput {
  let application: LeasingEntity
  var passportData: DocumentData?
  let passportImage: UIImage?
}

class IdentityConfirmationEditViewModel {
  // MARK: - Type
  typealias Dependencies = HasDictionaryService & HasApplicationService & HasUserDataStore
  
  // MARK: - Properties
  var isEnabledCheckButton: Bool {
    return isValid
  }
  
  var hasUserPhoto: Bool {
    return userPhotoURL != nil
  }
  
  var hasPassportPhoto: Bool {
    return passportImage != nil || leasingEntity.hasPassportImage
  }
  
  var isHiddenApartmentNumberField: Bool {
    return !addressListViewModel.shouldShowApartmentNumber
  }

  var needsResizeSuggestions: Bool {
    return addressListViewModel.needsResize && !isHiddenSuggestions
  }

  var title: String? {
    return leasingEntity.productInfo.productName
  }
  
  var passportPhoto: UIImage? {
    return passportImage
  }

  weak var delegate: IdentityConfirmationEditViewModelDelegate?
  
  var onDidUpdateValidity: (() -> Void)?
  var onDidRequestShowAddresses: (() -> Void)?
  var onDidRequestHideAddresses: (() -> Void)?
  var onNeedsResizeSuggestionList: (() -> Void)?
  var onDidRequestUpdateApartmentNumberField: (() -> Void)?
  var onDidRequestToShowEmptyErrorView: ((Error) -> Void)?
  var onDidRequestToShowErrorBanner: ((Error) -> Void)?
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidStartInitialRequest: (() -> Void)?
  var onDidFinishInitialRequest: (() -> Void)?
  var onDidUpdateData: (() -> Void)?
  var onNeedsToHideErrorView: (() -> Void)?
  var onDidRequestToShowHardcheckerError: ((_ message: String?) -> Void)?

  let addressListViewModel: AddressListViewModel
  
  private var onDidUpdateRegisterAddress: ((String) -> Void)?

  private var isHiddenSuggestions: Bool = true {
    didSet {
      isHiddenSuggestions ? onDidRequestHideAddresses?() : onDidRequestShowAddresses?()
    }
  }
  private var isValid: Bool = false
  private var shouldHandleText: Bool = true

  private var applicationID: String {
    return leasingEntity.applicationID
  }
  
  private var isValidAddress: Bool {
    guard let address = address else {
      return false
    }
    return address.address.isFullAddress
  }

  var userPhotoURL: URL? {
    guard let imageLink = (leasingEntity.clientImages.first(where: { $0.imageType == .selfie })?.imageURL ??
                            leasingEntity.clientImages.first(where: { $0.imageType == .passport })?.imageURL) else {
      return nil
    }
    return URLFactory.imageURL(imagePath: imageLink)
  }

  private(set) lazy var textEditConfigurators = makeTextEditConfigurators()
  
  private let dependencies: Dependencies
  private var address: AddressResult?
  private var onDidUpdateAddressValidity: ((Bool) -> Void)?
  private var leasingEntity: LeasingEntity
  private var passportData: DocumentData?
  private let passportImage: UIImage?
  
//  private let input: IdentityConfirmationEditViewModelInput
  
  // MARK: - Init
  init(input: IdentityConfirmationEditViewModelInput, dependencies: Dependencies) {
    self.dependencies = dependencies
    self.leasingEntity = input.application
    self.passportData = input.passportData ?? input.application.clientPersonalData?.passportData
    self.passportImage = input.passportImage

    addressListViewModel = AddressListViewModel(dependencies: dependencies)
    addressListViewModel.delegate = self
  }

  func setup() {
    guard passportData == nil, leasingEntity.clientPersonalData == nil else {
      onDidUpdateData?()
      try? validate()
      return
    }
    load()
  }

  func retry() {
    if passportData == nil {
      load()
    } else {
      finish()
    }
  }

  private func load() {
    onDidStartInitialRequest?()
    firstly {
      dependencies.applicationService.getApplicationData(applicationID: applicationID)
    }.ensure {
      self.onDidFinishInitialRequest?()
    }.done { leasingEntity in
      self.leasingEntity = leasingEntity
      self.passportData = leasingEntity.clientPersonalData?.passportData
      self.updateTextConfigurators()
      self.onDidUpdateData?()
      try? self.validate()
    }.catch { error in
      self.onDidRequestToShowEmptyErrorView?(error)
    }
  }

  // MARK: - Public
  func beginEditingRegistrationAddress() {
    isHiddenSuggestions = false
  }

  func finish() {
    guard let data = try? self.createPersonalData() else {
      return
    }

    onDidStartRequest?()

    firstly {
      checkOtherApplications(clientData: data)
    }.then { _ in
      self.dependencies.applicationService.saveClientData(data: data, applicationID: self.applicationID)
    }.ensure {
      self.onDidFinishRequest?()
    }.done { response in
      self.onNeedsToHideErrorView?()
      
      if response.applicationInfo.status == .pending, response.applicationInfo.hasHardcheckerError {
        self.onDidRequestToShowHardcheckerError?(response.applicationInfo.hardCheckText)
        return
      }
      
      self.delegate?.identityConfirmationEditViewModel(self, didFinishWithApplication: self.leasingEntity)
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
  
  func forceFinishFlow() {
    delegate?.identityConfirmationEditViewModelDidRequestToForceFinish(self)
  }
  
  // MARK: - Private
  private func makeTextEditConfigurators() -> [FieldConfigurator<IdentityConfirmationEditFieldType>] {
    return IdentityConfirmationEditFieldType.allCases.map {
      var pickerOptions: [String] = []
      if $0 == .typeOfEmployment {
        pickerOptions = dependencies.userDataStore.occupationOptions.map { $0.value }
      }
      let configurator = FieldConfigurator(fieldType: $0, text: initialText(for: $0), pickerOptions: pickerOptions)
      if configurator.type == .registrationAddress {
        onDidUpdateRegisterAddress = { [weak self, weak configurator] address in
          self?.shouldHandleText = false
          configurator?.update(text: address)
        }
        onDidUpdateAddressValidity = { [weak configurator] isValid in
          if !isValid {
            configurator?.handle(error: ValidationError.invalidRegistrationAddress)
          } else {
            configurator?.resetToDefaultState()
          }
        }
        configurator.onDidEndEditing = { [weak self, weak configurator] _ in
          guard let self = self else { return }
          self.isHiddenSuggestions = true
          let isValid = !(self.address == nil && configurator?.text != nil) &&
            self.isValidAddress
          self.isValid = isValid
          self.onDidUpdateAddressValidity?(isValid)
        }
      }
      configurator.onDidEndEditing = { [weak self, weak configurator] _ in
        guard let self = self else { return }
        if configurator?.type == .apartmentNumber, let text = configurator?.text {
          self.address?.address.flatNum = text
          self.onDidUpdateAddressValidity?(self.isValidAddress)
          try? self.validate()
        }
      }
      configurator.onDidChangeText = { [weak self, unowned configurator] text in
        guard let self = self else { return }
        if configurator.type == .registrationAddress {
          self.handleAddressTextUpdated(text: text)
          self.shouldHandleText = true
          guard let text = configurator.text, !text.isEmpty else {
            try? self.validate()
            return
          }
          let isValid = !(self.address == nil && configurator.text != nil) &&
            self.isValidAddress
          self.onDidUpdateAddressValidity?(isValid)
        }
        try? self.validate()
      }
      return configurator
    }
  }

  private func updateTextConfigurators() {
    textEditConfigurators.forEach {
      $0.update(text: self.initialText(for: $0.type))
    }
  }

  private func handleAddressTextUpdated(text: String?) {
    if isHiddenSuggestions, shouldHandleText {
      isHiddenSuggestions = false
    }
    if let address = address, text?.trimmingCharacters(in: .whitespacesAndNewlines) != address.addressString {
      self.address = nil
    }
    addressListViewModel.updateAddress(text ?? "")
  }

  private func initialText(for fieldType: IdentityConfirmationEditFieldType) -> String? {
    switch fieldType {
    case .lastname:
      return passportData?.surname
    case .middlename:
      return passportData?.patronymic
    case .firstname:
      return passportData?.name
    case .dateOfBirth:
      return passportData?.birthdate.map { DateFormatter.dayMonthYearDisplayable.string(from: $0) }
    case .placeOfBirth:
      return passportData?.birthplace
    case .passport:
      return passportData?.passportNumber
    case .dateOfReceiving:
      return passportData?.issueDate.map { DateFormatter.dayMonthYearDisplayable.string(from: $0) }
    case .issuedBy:
      return passportData?.passportIssuedBy
    case .divisionCode:
      return passportData?.passportIssuedByCode
    default:
      return nil
    }
  }

  private func createPersonalData() throws -> ClientPersonalData {
    let occupation = dependencies.userDataStore.occupationOptions
      .first { $0.value == textEditConfigurators.first { $0.type == .typeOfEmployment }?.text }?.key
    let dateOfBirth = textEditConfigurators.first { $0.type == .dateOfBirth }?.text
    let dateOfReceiving = textEditConfigurators.first { $0.type == .dateOfReceiving }?.text

    guard let firstName = textEditConfigurators.first(where: { $0.type == .firstname })?.text,
          let lastName = textEditConfigurators.first(where: { $0.type == .lastname })?.text,
          let birthDate = dateOfBirth.map({ DateFormatter.dayMonthYearDisplayable.date(from: $0) }) ?? nil,
          let placeOfBirth = textEditConfigurators.first(where: { $0.type == .placeOfBirth })?.text,
          let issuedDate = dateOfReceiving.map({ DateFormatter.dayMonthYearDisplayable.date(from: $0) }) ?? nil,
          let issuedBy = textEditConfigurators.first(where: { $0.type == .issuedBy })?.text,
          let divisionCode = textEditConfigurators.first(where: { $0.type == .divisionCode })?.text,
          let sex = passportData?.sex,
          let typeOfEmployment = occupation,
          let salaryText = textEditConfigurators.first(where: { $0.type == .salary })?.sanitizedText,
          let salary = Int(salaryText) else {
      throw IdentityConfirmationError.notEnoughData
    }

    guard var address = address?.address else {
      if let configurator = textEditConfigurators.first(where: { $0.type == .registrationAddress }) {
        configurator.handle(error: ValidationError.invalidRegistrationAddress)
      }
      throw IdentityConfirmationError.notEnoughData
    }
    
    if let apartmentConfigurator = textEditConfigurators.first(where: { $0.type == .apartmentNumber }),
       !apartmentConfigurator.isHidden, let text = apartmentConfigurator.text {
      address.flatNum = text
    }

    let middleName = textEditConfigurators.first { $0.type == .middlename }?.text
    
    return ClientPersonalData(firstName: firstName, middleName: middleName, lastName: lastName,
                              birthDate: DateFormatter.dayMonthYearBackend.string(from: birthDate), birthPlace: placeOfBirth,
                              issueDate: DateFormatter.dayMonthYearBackend.string(from: issuedDate),
                              issuer: issuedBy, issuerCode: divisionCode, sex: sex, documentType: .passport,
                              monthlySalary: salary, occupation: typeOfEmployment, registrationAddress: address)
  }
  
  private func updateRegistrationAddress(_ address: String, addressObject: AddressResult) {
    let flatNum = self.address?.address.flatNum
    self.address = addressObject
    if addressObject.address.flatNum == nil {
      self.address?.address.flatNum = flatNum
    }
    isHiddenSuggestions = true
    onDidUpdateRegisterAddress?(address)
    onNeedsResizeSuggestionList?()
  }

  private func validate(isSilent: Bool = true) throws {
    var isValid = true
    for configurator in textEditConfigurators {
      if !configurator.validate(silent: isSilent) {
        isValid = false
      }
      if configurator.type == .registrationAddress, !isValidAddress {
        if !isSilent {
          configurator.handle(error: ValidationError.invalidRegistrationAddress)
        }
        isValid = false
      }
    }
    self.isValid = isValid
    onDidUpdateValidity?()
    if !isValid {
      throw IdentityConfirmationError.notAllFieldsValid
    }
  }

  private func checkOtherApplications(clientData: ClientPersonalData) -> Promise<Void> {
    return Promise { seal in
      firstly {
        self.dependencies.applicationService.checkOtherApplications(applicationID: applicationID)
      }.done { applications in
        if !applications.isEmpty {
          var list = [self.leasingEntity]
          list.append(contentsOf: applications)
          self.delegate?.identityConfirmationEditViewModel(self, didRequestSelectApplicationFromList: list,
                                                           activeApplicationData: (self.leasingEntity, clientData))
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

// MARK: - RegAddressListViewModelDelegate
extension IdentityConfirmationEditViewModel: AddressListViewModelDelegate {
  func addressListViewModel(_ viewModel: AddressListViewModel,
                            shouldShowApartmentNumber shouldShow: Bool) {
    onDidRequestUpdateApartmentNumberField?()
  }
  
  func addressListViewModelDidUpdate(_ viewModel: AddressListViewModel) {
    onNeedsResizeSuggestionList?()
  }
  
  func addressListViewModel(_ viewModel: AddressListViewModel, didSelectAddress address: String,
                            addressObject: AddressResult) {
    updateRegistrationAddress(address, addressObject: addressObject)
  }
}
