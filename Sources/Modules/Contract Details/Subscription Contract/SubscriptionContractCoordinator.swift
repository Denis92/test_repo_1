//
//  SubscriptionContractCoordinator.swift
//  ForwardLeasing
//

import UIKit

class SubscriptionContractCoordinator: ConfigurableNavigationFlowCoordinator {
  typealias Configuration = BoughtSubscription
  // MARK: - Properties
  let appDependency: AppDependency
  var navigationObserver: NavigationObserver
  let navigationController: NavigationController
  var childCoordinators: [BaseCoordinator] = []
  var onDidFinish: (() -> Void)?

  private var onDidSelectCard: ((_ card: PaymentCard?, _ saveCard: Bool) -> Void)?
  private var onDidRequestHideBottomSheet: (() -> Void)?

  private let subscription: BoughtSubscription

  // MARK: - Init

  required init(appDependency: AppDependency,
                navigationController: NavigationController,
                navigationObserver: NavigationObserver,
                configuration: Configuration) {
    self.navigationController = navigationController
    self.navigationObserver = navigationObserver
    self.appDependency = appDependency
    subscription = configuration
  }

  // MARK: - Navigation

  func start(animated: Bool) {
    showSubscriptionContractScreen(animated: animated)
  }

  private func showSubscriptionContractScreen(animated: Bool) {
    let viewModel = SubscriptionContractViewModel(subscription: subscription, dependencies: appDependency)
    onDidSelectCard = { [weak viewModel] card, saveCard in
      viewModel?.update(selectedCard: card, saveCard: saveCard)
    }
    viewModel.delegate = self
    let viewController = SubscriptionContractViewController(viewModel: viewModel)
    viewController.delegate = self
    navigationObserver.addObserver(self, forPopOf: viewController)
    navigationController.pushViewController(viewController, animated: animated)
  }
  
  private func showBottomSheetCardList(with cards: [PaymentCard], selectedCard: PaymentCard?) {
    let viewModel = CreditCardBottomSheetViewModel(cards: cards, selectedCard: selectedCard)
    viewModel.delegate = self
    let controller = BottomSheetListViewController(viewModel: viewModel)
    let footerView = CardsBottomSheetFooterView(viewModel: viewModel)
    controller.setFooterView(footerView)
    onDidRequestHideBottomSheet = { [weak controller] in
      controller?.removeBottomSheetViewController(animated: true)
    }
    navigationController.addBottomSheetViewController(withDarkView: true, viewController: controller,
                                                      animated: true)
  }
  
  private func showPayment(with card: PaymentCard, saveCard: Bool) {
    let configuration = BuySubscriptionConfiguration(name: subscription.name, subscriptionItemID: subscription.id.description,
                                                     selectedCard: card, saveCard: saveCard, flow: .profile)
    let coordinator = show(BuySubscriptionCoordinator.self, configuration: configuration, animated: true)
    coordinator.delegate = self
  }
}

// MARK: - SubscriptionContractViewModelDelegate
extension SubscriptionContractCoordinator: SubscriptionContractViewModelDelegate {
  func subscriptionContractViewModel(_ viewModel: SubscriptionContractViewModel,
                                     didRequestRenewSubscription subscription: BoughtSubscription,
                                     withCard card: PaymentCard, saveCard: Bool) {
    showPayment(with: card, saveCard: saveCard)
  }

  func subscriptionContractViewModel(_ viewModel: SubscriptionContractViewModel,
                                     didRequestSelectCardFromList cardList: [PaymentCard], selectedCard: PaymentCard) {
    showBottomSheetCardList(with: cardList, selectedCard: selectedCard)
  }
}

// MARK: - SubscriptionContractViewControllerDelegate
extension SubscriptionContractCoordinator: SubscriptionContractViewControllerDelegate {
  func subscriptionContractViewControllerDidRequestGoBack(_ viewController: SubscriptionContractViewController) {
    navigationController.popViewController(animated: true)
  }
}

// MARK: - CreditCardBottomSheetViewModelDelegate
extension SubscriptionContractCoordinator: CreditCardBottomSheetViewModelDelegate {
  func creditCardBottomSheetViewModelDidRequestHide(_ viewModel: CreditCardBottomSheetViewModel) {
    onDidRequestHideBottomSheet?()
  }
  
  func creditCardBottomSheetViewModel(_ viewModel: CreditCardBottomSheetViewModel,
                                      didFinishWithSelectedCard selectedCard: PaymentCard,
                                      saveCard: Bool) {
    onDidSelectCard?(selectedCard, saveCard)
  }
  
  func creditCardBottomSheetViewModel(_ viewModel: CreditCardBottomSheetViewModel,
                                      didRequestShowPaymentWithCard card: PaymentCard) {
    showPayment(with: card, saveCard: false)
  }
}

// MARK: - BuySubscriptionCoordinatorDelegate
extension SubscriptionContractCoordinator: BuySubscriptionCoordinatorDelegate {
  func buySubscriptionCoordinatorDidRequestPopToProfile(_ coordinator: BuySubscriptionCoordinator) {
    popToController(ProfileViewController.self)
  }
}
