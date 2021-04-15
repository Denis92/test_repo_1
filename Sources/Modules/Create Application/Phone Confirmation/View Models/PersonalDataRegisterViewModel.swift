//
//  PersonalDataRegisterViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

protocol PersonalDataRegisterViewModelDelegate: RegisterViewModelDelegate {
  func personalDataRegViewModel(_ viewModel: PersonalDataRegisterViewModel,
                                didRequestConfirmWithApplication application: LeasingEntity)
  func personalDataRegViewModel(_ viewModel: PersonalDataRegisterViewModel,
                                didRequestShowApplicationList applicationList: [LeasingEntity],
                                applicationCreationInfo: ApplicationCreationInfo)
  func personalDataRegViewModelDidRequestPopToProfile(_ viewModel: PersonalDataRegisterViewModel)
  func personalDataRegViewModelDidEncounterCriticalError(_ viewModel: PersonalDataRegisterViewModel)
}

enum ActiveApplicationsError: LocalizedError {
  case activeApplicationsLoggedOut
  var errorDescription: String? {
    return R.string.networkErrors.errorApplicationCreationPleaseLogIn()
  }
}

class PersonalDataRegisterViewModel: RegisterViewModel, UserInfoTextFieldUpdating {
  // MARK: - Type
  typealias Dependencies = HasAuthService & HasPersonalDataRegisterService &
    HasUserDataStore & HasApplicationService & HasUserDataStore & HasProfileService
  
  // MARK: - Properties
  override var title: String? {
    return input.product?.productName
  }
  
  var applicationService: ApplicationNetworkProtocol {
    return dependencies.applicationService
  }
  
  override var allAgreements: [AgreementType] {
    return [
      .electronicSignature(basketID: input.basketID),
      .leasingPersonalData(basketID: input.basketID)
    ]
  }
  
  override var fields: [AnyFieldType<RegisterFieldType>] {
    return RegisterViewModelFieldsFactory.makeFields(hasPhoneNumber: hasPhoneNumber)
  }
  
  override var onDidRequestUpdateEmail: ((String) -> Void)? {
    didSet {
      getClientInfo()
    }
  }
    
  private var hasPhoneNumber: Bool {
    return dependencies.userDataStore.phoneNumber != nil
  }

  private let dependencies: Dependencies
  private var input: ApplicationCreationInfo
  private var personalDataRegDelegate: PersonalDataRegisterViewModelDelegate? {
    return delegate as? PersonalDataRegisterViewModelDelegate
  }
  
  // MARK: - Init
  init(dependencies: Dependencies,
       input: ApplicationCreationInfo) {
    self.dependencies = dependencies
    self.input = input
    super.init(dependencies: dependencies)
  }
  
  // MARK: - Public
  override func didTapConfirm() {
    guard let phone = phone, let email = email else { return }
    onDidStartRequest?()
    firstly { () -> Promise<LeasingEntity> in
      let sanitizedPhone = phone.sanitizedPhoneNumber()
      return dependencies.personalDataRegistrationService.createLeasingApplication(basketID: input.basketID,
                                                                                   type: input.leasingType,
                                                                                   email: email,
                                                                                   phone: sanitizedPhone,
                                                                                   previousApplicationID: input.previousApplicationID)
    }.done { leasingApplication in
      self.handle(response: leasingApplication)
    }.catch { error in
      self.handle(error: error)
    }
  }
  
  private func handle(response: LeasingEntity) {
    self.onDidFinishRequest? { [weak self] in
      guard let self = self else { return }
      var application = response
      application.productImage = self.input.product?.productImage
      self.personalDataRegDelegate?.personalDataRegViewModel(self, didRequestConfirmWithApplication: application)
    }
  }
  
  private func handle(error: Error) {
    if (error as? CustomServerError)?.errorType == .otherApplicationActive {
      self.input.email = email
      self.input.phone = phone
      if self.dependencies.userDataStore.isLoggedIn {
        self.checkAllApplications()
      } else {
        self.onDidReceiveError?(ActiveApplicationsError.activeApplicationsLoggedOut)
        self.personalDataRegDelegate?.personalDataRegViewModelDidRequestPopToProfile(self)
      }
    } else {
      self.onDidFinishRequest? {
        self.onDidReceiveError?(error)
        if (error as? CustomServerError)?.errorType == .basketInvalid {
          self.personalDataRegDelegate?.personalDataRegViewModelDidEncounterCriticalError(self)
        }
      }
    }
  }
  
  private func checkAllApplications() {
    firstly {
      dependencies.applicationService.checkAllApplications()
    }.done { notIssued in
      self.onDidFinishRequest? {
        if !notIssued.isEmpty {
          self.personalDataRegDelegate?.personalDataRegViewModel(self, didRequestShowApplicationList: notIssued,
                                                                 applicationCreationInfo: self.input)
        } else {
          self.onDidReceiveError?(ActiveApplicationsError.activeApplicationsLoggedOut)
          self.personalDataRegDelegate?.personalDataRegViewModelDidRequestPopToProfile(self)
        }
      }
    }.catch { _ in
      self.onDidReceiveError?(ActiveApplicationsError.activeApplicationsLoggedOut)
      self.personalDataRegDelegate?.personalDataRegViewModelDidRequestPopToProfile(self)
    }
  }
}
