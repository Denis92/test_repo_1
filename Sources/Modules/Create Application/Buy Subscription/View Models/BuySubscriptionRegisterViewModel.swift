//
//  BuySubscriptionRegisterViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol BuySubscriptionRegisterViewModelDelegate: RegisterViewModelDelegate {
  func buySubscriptionRegisterViewModel(_ viewModel: BuySubscriptionRegisterViewModel,
                                        didRequestShowPaymentWithURL url: URL)
}

struct BuySubscriptionRegisterViewModelInput {
  let name: String
  let subscriptionItemID: String
  let card: PaymentCard
  let saveCard: Bool
}

class BuySubscriptionRegisterViewModel: RegisterViewModel, UserInfoTextFieldUpdating {
  // MARK: - Types
  typealias Dependencies = HasAuthService & HasPersonalDataRegisterService & HasUserDataStore &
    HasOrdersService & HasApplicationService

  // MARK: - Properties
  override var allAgreements: [AgreementType] {
    return [.personalDataAndSubscrptionRules]
  }
  
  override var fields: [AnyFieldType<RegisterFieldType>] {
    return RegisterViewModelFieldsFactory
      .makeFields(hasPhoneNumber: dependencies.userDataStore.phoneNumber != nil)
  }
  
  var applicationService: ApplicationNetworkProtocol {
    return dependencies.applicationService
  }
  
  var onDidFailPayment: (() -> Void)?
  
  override var title: String? {
    return input.name
  }
  
  private var buySubsriptionDelegate: BuySubscriptionRegisterViewModelDelegate? {
    return delegate as? BuySubscriptionRegisterViewModelDelegate
  }
  
  private var isLoggedIn: Bool {
    return dependencies.userDataStore.isLoggedIn
  }
  
  private var subscriptionID: String {
    return input.subscriptionItemID
  }
  
  private let dependencies: Dependencies
  private let input: BuySubscriptionRegisterViewModelInput
   
  init(dependencies: Dependencies,
       input: BuySubscriptionRegisterViewModelInput) {
    self.dependencies = dependencies
    self.input = input
    super.init(dependencies: dependencies)
  }
  
  override func didTapConfirm() {
    guard let phone = phone, let email = email else { return }
    onDidStartRequest?()
    firstly {
      isLoggedIn ?
        dependencies.ordersService.makeOrder(subscriptionID: subscriptionID, card: input.card, saveCard: input.saveCard, email: email) :
        dependencies.ordersService.makeOrderUnathorized(subscriptionID: subscriptionID, card: input.card,
                                                        email: email, phoneNumber: phone)
    }.done { response in
      self.dependencies.userDataStore.phoneNumber = phone
      self.onDidFinishRequest? { [weak self, response] in
        guard let self = self else { return }
        self.buySubsriptionDelegate?.buySubscriptionRegisterViewModel(self, didRequestShowPaymentWithURL: response.paymentURL)
      }
    }.catch { _ in
      self.onDidFailPayment?()
    }
  }
}
