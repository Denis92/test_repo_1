//
//  ProfileSettingsViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

protocol ProfileSettingsViewModelDelegate: class {
  func profileSettingsViewModelDidRequestLogout(_ viewModel: ProfileSettingsViewModel)
  func profileSettingsViewModel(_ viewModel: ProfileSettingsViewModel,
                                didRequestUpdatePinCodeWithSessionID sessionID: String)
  func profileSettingsViewModelDidRequestAboutApp(_ viewModel: ProfileSettingsViewModel)
  func profileSettingsViewModel(_ viewModel: ProfileSettingsViewModel,
                                didRequestShowDocumentWithURL url: URL)
  func profileSettingsViewModel(_ viewModel: ProfileSettingsViewModel,
                                didRequestContactViaEmailWithTheme theme: String,
                                body: String, to email: String)
}

class ProfileSettingsViewModel: CommonTableViewModel, PhoneCalling {
  // MARK: - Types
  typealias Dependencies = HasCardsService & HasAuthService & HasUserDataStore
  
  // MARK: - Properties
  weak var delegate: ProfileSettingsViewModelDelegate?
  
  var onDidUpdateViewModels: (() -> Void)?
  var onDidStartCardsRequest: (() -> Void)?
  var onDidFinishCardsRequest: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?
  var onNeedsDeleteRowAtIndexPath: ((IndexPath) -> Void)?
  var onDidRequestLogout: (() -> Void)?
  var onDidStartRecoveryPinCodeRequest: (() -> Void)?
  var onDidFinishSuccess: (() -> Void)?
  var onDidFinishRecoveryPinCodeRequest: (() -> Void)?
  var onDidRequestContactWithUs: ((AlertViewModel) -> Void)?
  
  var sectionViewModels: [TableSectionViewModel] = []
  var showHeaderAndFooterForEmptySection: Bool {
    return false
  }
  
  var isHiddenLogoutButton: Bool {
    return flow == .notAuthorized
  }
  
  private let dependencies: Dependencies
  private let factory = ProfileSettingsViewModelFactory()
  private var cardSection: CreditCardsSectionViewModel?
  private(set) lazy var alertLogoutActions: [AlertAction] = makeAlertLogoutActions()
  private let flow: ProfileSettingsFlow
  
  // MARK: - Init
  init(dependencies: Dependencies, flow: ProfileSettingsFlow) {
    self.dependencies = dependencies
    self.flow = flow
  }
  
  // MARK: - Public
  func loadCards() {
    guard flow == .authorized else {
      updateViewModels()
      return
    }
    onDidStartCardsRequest?()
    firstly {
      dependencies.cardsService.getCards()
    }.ensure {
      self.onDidFinishCardsRequest?()
    }.done { cards in
      self.cardSection = self.factory.makeCreditCardsSection(from: cards, delegate: self)
      self.updateViewModels()
    }.catch { error in
      self.onDidReceiveError?(error)
    }
  }
  
  func finish() {
    onDidFinishSuccess?()
  }
  
  // MARK: - Private Methods
  private func deleteCard(_ card: Card, completion: ((Bool) -> Void)?) {
    firstly {
      dependencies.cardsService.deleteCard(with: card.id)
    }.done { _ in
      completion?(true)
    }.catch { error in
      completion?(false)
      self.onDidReceiveError?(error)
    }
  }
  
  private func updatePinCode() {
    onDidFinishSuccess = nil
    guard let phoneNumber = dependencies.userDataStore.phoneNumber else { return }
    onDidStartRecoveryPinCodeRequest?()
    firstly {
      dependencies.authService.recoveryPin(phone: phoneNumber)
    }.done { sessionResponse in
      self.onDidFinishSuccess = { [weak self] in
        guard let self = self else { return }
        self.delegate?.profileSettingsViewModel(self, didRequestUpdatePinCodeWithSessionID: sessionResponse.sessionID)
      }
      self.onDidFinishRecoveryPinCodeRequest?()
    }.catch { error in
      self.onDidReceiveError?(error)
      self.onDidFinishRecoveryPinCodeRequest?()
    }
  }
  
  private func updateViewModels() {
    switch flow {
    case .authorized:
      updateViewModelsWithAuthorizedFlow()
    case .notAuthorized:
      updateViewModelsWithNotAuthorizedFlow()
    }
  }
  
  private func updateViewModelsWithAuthorizedFlow() {
    var sections: [TableSectionViewModel] = []
    var accessTopOffset: CGFloat = 0
    if let cardSection = cardSection {
      sections.append(cardSection)
      accessTopOffset = 32
    }
    
    let accessSection = factory.makeAccessSection(topOffset: accessTopOffset) { [weak self] in
      self?.updatePinCode()
    }
    sections.append(accessSection)
    
    let informationSection = factory.makeInformationSection(delegate: self)
    sections.append(informationSection)
    
    self.sectionViewModels = sections
    onDidUpdateViewModels?()
  }
  
  private func updateViewModelsWithNotAuthorizedFlow() {
    let informationSection = factory.makeInformationSection(delegate: self, withHeader: false)
    self.sectionViewModels = [informationSection]
    onDidUpdateViewModels?()
  }
  
  private func makeAlertLogoutActions() -> [AlertAction] {
    let yesAction = AlertAction(title: R.string.common.yes(), buttonType: .primary) { [weak self] in
      guard let self = self else { return }
      self.delegate?.profileSettingsViewModelDidRequestLogout(self)
    }
    let cancelAction = AlertAction(title: R.string.common.cancel(), buttonType: .secondary, action: nil)
    return [yesAction, cancelAction]
  }
  
  private func showContactActionSheet() {
    let phoneNumberAction = AlertActionViewModel(title: R.string.profileSettings.contactViaCallTitle()) { [weak self] in
      self?.callIfCan(phoneNumber: Constants.supportPhoneNumber)
    }
    let emailAction = AlertActionViewModel(title: R.string.profileSettings.contactViaEmailTitle()) { [weak self] in
      guard let self = self else { return }
      let theme = R.string.profileSettings.emailSupportTheme(Constants.deviceType)
      let body = SupportMessageBodyFactory.makeMessageBody(phoneNumber: self.dependencies.userDataStore.phoneNumber)
      self.delegate?.profileSettingsViewModel(self, didRequestContactViaEmailWithTheme: theme,
                                              body: body, to: Constants.supportEmail)
    }
    let cancel = AlertActionViewModel(title: R.string.common.cancel(), style: .cancel)
    let alertViewModel = AlertViewModel(prefferedStyle: .actionSheet, actions: [phoneNumberAction, emailAction, cancel])
    onDidRequestContactWithUs?(alertViewModel)
  }
}

// MARK: - ProfileCardItemViewModelDelegate
extension ProfileSettingsViewModel: CreditCardsSectionViewModelDelegate {
  func creditCardsSectionViewModel(_ viewModel: CreditCardsSectionViewModel,
                                   didRequestDeleteCard card: Card, completion: ((Bool) -> Void)?) {
    deleteCard(card, completion: completion)
  }
  
  func creditCardsSectionViewModel(_ viewModel: CreditCardsSectionViewModel, didRemoveCardAtIndex index: Int) {
    guard let cardsSectionIndex = sectionViewModels.firstIndex(where: { $0 === cardSection }) else { return }
    onNeedsDeleteRowAtIndexPath?(IndexPath(row: index, section: cardsSectionIndex))
  }
}

// MARK: - NotAuthorizedSectionViewModelDelegate
extension ProfileSettingsViewModel: InformationSectionViewModelDelegate {
  func informationSectionViewModelDidRequestContactWithUs(_ viewModel: InformationSectionViewModel) {
    showContactActionSheet()
  }
  
  func informationSectionViewModelDidRequestAboutApp(_ viewModel: InformationSectionViewModel) {
    delegate?.profileSettingsViewModelDidRequestAboutApp(self)
  }
  
  func informationSectionViewModel(_ viewModel: InformationSectionViewModel,
                                   didRequestDocumentWithURL url: URL) {
    delegate?.profileSettingsViewModel(self, didRequestShowDocumentWithURL: url)
  }
}
