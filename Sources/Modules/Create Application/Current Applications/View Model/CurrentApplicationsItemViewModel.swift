//
//  CurrentApplicationsItemViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol CurrentApplicationsItemViewModelDelegate: class {
  func currentApplicationsItemViewModel(_ viewModel: CurrentApplicationsItemViewModel,
                                        didRequestToContinueWith application: LeasingEntity)
  func currentApplicationsItemViewModel(_ viewModel: CurrentApplicationsItemViewModel,
                                        didRequestToCancel application: LeasingEntity)
  func currentApplicationsItemViewModelDidRequestCreateNewApplication(_ viewModel: CurrentApplicationsItemViewModel)
}

struct CurrentApplicationButtonConfiguration {
  let title: String
  let type: StandardButtonType
}

class CurrentApplicationsItemViewModel {
  // MARK: - Properties
  
  weak var delegate: CurrentApplicationsItemViewModelDelegate?
  
  var title: String? {
    let date = application?.createDate ?? Date()
    guard let name = applicationProduct.productName else { return nil }
    let dateString = DateFormatter.dateAndTimeDisplayable.string(from: date)
    return R.string.currentApplications.applicationItemTitle(dateString, name)
  }
  
  var price: String? {
    if let priceString = applicationProduct.monthPay?.priceString() {
      return R.string.currentApplications.applicationItemPrice(priceString)
    } else {
      return nil
    }
  }
  
  var imageURL: URL? {
    (applicationProduct.productImage ?? application?.productImage)?.toURL()
  }

  var buttonConfiguration: CurrentApplicationButtonConfiguration {
    return isUpgrade
      ? CurrentApplicationButtonConfiguration(title: R.string.currentApplications.cancelApplicationButtonTitle(), type: .secondary)
      : CurrentApplicationButtonConfiguration(title: R.string.currentApplications.continueApplicationButtonTitle(), type: .primary)
  }

  private let application: LeasingEntity?
  private let applicationProduct: LeasingProductInfo
  private let isUpgrade: Bool
  
  // MARK: - Init
  
  init(applicationProduct: LeasingProductInfo, application: LeasingEntity?, isUpgrade: Bool) {
    self.application = application
    self.applicationProduct = applicationProduct
    self.isUpgrade = isUpgrade
  }
  
  // MARK: - Public methods
  
  func continueApplication() {
    guard let application = application else {
      delegate?.currentApplicationsItemViewModelDidRequestCreateNewApplication(self)
      return 
    }
    isUpgrade
      ? delegate?.currentApplicationsItemViewModel(self, didRequestToCancel: application)
      : delegate?.currentApplicationsItemViewModel(self, didRequestToContinueWith: application)
  }
}

// MARK: - CommonTableCellViewModel

extension CurrentApplicationsItemViewModel: CommonTableCellViewModel {
  var tableCellIdentifier: String {
    return CommonContainerTableViewCell<CurrentApplicationsItemView>.reuseIdentifier
  }
}
