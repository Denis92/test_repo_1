//
//  DeliveryInfoViewModel.swift
//  ForwardLeasing
//

import UIKit

class DeliveryInfoViewModel: DeliveryInfoViewModelProtocol {
  // MARK: - Properties
  private(set) var userDataItems: [UserDataItemViewModel] = []
  private(set) var deliveryInfoItems: [UserDataItemViewModel] = []
  private(set) var state: DeliveryInfoViewState = .loading
  
  var onDidUpdate: (() -> Void)?
  
  // MARK: - Public
  func updateUserDataItems(postIndex: String?, mobilePhone: String?) {
    let indexUserData = UserDataItemViewModel(title: R.string.deliveryProduct.postIndexTitle(),
                                              value: postIndex,
                                              style: .normal)
    let mobilePhoneUserData = UserDataItemViewModel(title: R.string.deliveryProduct.phoneNumberTitle(),
                                                    value: mobilePhone,
                                                    style: .normal)
    userDataItems = [indexUserData, mobilePhoneUserData]
  }
  
  func updateDeliveryInfoItems(expectedDate: Date?, price: Decimal?) {
    let dateFormatter = DateFormatter.dayMonthDisplayable
    var expectedDateString: String?
    if let date = expectedDate {
      expectedDateString = dateFormatter.string(from: date)
    }
    let deliveryCost = UserDataItemViewModel(title: R.string.deliveryProduct.deliveryCostTitle(),
                                             value: price?.priceString(),
                                             style: .bold)
    let expectedDate = UserDataItemViewModel(title: R.string.deliveryProduct.expectedDeliveryDateTitle(),
                                             value: R.string.deliveryProduct.expectedDeliveryDate(expectedDateString ?? ""),
                                             style: .bold)
    deliveryInfoItems = [deliveryCost, expectedDate]
  }
  
  func updateState(_ state: DeliveryInfoViewState) {
    self.state = state
  }
  
  func invalidateUpdate() {
    onDidUpdate?()
  }
}
