//
//  ProfileSubscriptionsCellViewModelsFactory.swift
//  ForwardLeasing
//

import Foundation

class ProfileSubscriptionsCellViewModelsFactory {
  // MARK: - Properties
  private let subscriptions: [BoughtSubscription]
  private let cellDelegate: ProfileCellViewModelsDelegate
  private let paymentsFormatter = PaymentsFormatter()
  private let dateFormatter = DateFormatter.dayMonthYearDocument

  // MARK: - Init
  init(subscriptions: [BoughtSubscription],
       cellDelegate: ProfileCellViewModelsDelegate) {
    self.subscriptions = subscriptions
    self.cellDelegate = cellDelegate
  }

  // MARK: - Public methods
  func makeCellViewModels() -> [CommonTableCellViewModel] {
    let viewModels = subscriptions.map {
      return makeCellViewModel(with: $0)
    }
    return viewModels
  }

  private func makeCellViewModel(with subscription: BoughtSubscription) -> CommonTableCellViewModel {
    let infoViewModel = makeProductInfoViewModel(subscription: subscription)
    let buttonsViewModel = ProductButtonsViewModel(buttonsActions: [.buyAgain])
    let viewModel = SubscriptionViewModel(subscription: subscription,
                                          infoViewModel: infoViewModel,
                                          buttonsViewModel: buttonsViewModel)
    viewModel.delegate = cellDelegate
    return SubscriptionCellViewModel(subscriptionViewModel: viewModel)
  }

  private func makeProductInfoViewModel(subscription: BoughtSubscription) -> ProductInfoViewModel {
    let productName = subscription.name
    let monthPayTitle = paymentsFormatter.monthPaymentString(for: subscription.price)
    let productImageViewModel = ProductImageViewModel(imageURL: try? subscription.imageURLString?.asURL(),
                                                      type: .service)
    let imageViewType = ImageViewType.simple(productImageViewModel)
    let descriptions: [ProductDescriptionConfiguration]
    if  let date = subscription.date {
      let description = ProductDescriptionConfiguration(title: R.string.productCard.buyAtTitle(dateFormatter.string(from: date)),
                                                        color: .shade70)
      descriptions = [description]
    } else {
      descriptions = []
    }

    let productDescriptionViewModel = ProductDescriptionViewModel(descriptions: descriptions,
                                                                  nameTitle: productName,
                                                                  paymentTitle: monthPayTitle)
    return ProductInfoViewModel(descriptionViewModel: productDescriptionViewModel,
                                imageViewType: imageViewType)
  }

}
