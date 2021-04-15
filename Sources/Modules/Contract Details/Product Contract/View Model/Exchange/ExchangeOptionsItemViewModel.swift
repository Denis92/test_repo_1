//
//  ExchangeOptionsItemViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ExchangeOptionsItemViewModelDelegate: class {
  func exchangeOptionsItemViewModel(_ viewModel: ExchangeOptionsItemViewModel, didSelectModel model: ModelInfo)
}

class ExchangeOptionsItemViewModel {
  weak var delegate: ExchangeOptionsItemViewModelDelegate?
  
  var title: String {
    return model.name
  }
  
  var imageURL: URL? {
    return model.images.first { $0.type == .primary }?.imageURL
  }
  
  var monthPriceDifference: String? {
    guard let productMonthPrice = model.favoriteProducts.first?.monthPay else { return nil }
    if currentMonthPrice == productMonthPrice {
      return R.string.contractDetails.exchangeMonthPriceSameText()
    } else if currentMonthPrice > productMonthPrice {
      guard let priceString = (currentMonthPrice - productMonthPrice).priceString() else { return nil }
      return R.string.contractDetails.exchangeMonthPriceLowerText(priceString)
    } else {
      guard let priceString = (productMonthPrice - currentMonthPrice).priceString() else { return nil }
      return R.string.contractDetails.exchangeMonthPriceGreaterText(priceString)
    }
  }
  
  private let model: ModelInfo
  private let currentMonthPrice: Decimal
  
  init(model: ModelInfo, currentMonthPrice: Decimal) {
    self.model = model
    self.currentMonthPrice = currentMonthPrice
  }
  
  func selectCollectionCell() {
    delegate?.exchangeOptionsItemViewModel(self, didSelectModel: model)
  }
}

// MARK: - CommonCollectionCellViewModel

extension ExchangeOptionsItemViewModel: CommonCollectionCellViewModel {
  var collectionCellIdentifier: String {
    return CommonConfigurableCollectionViewCell<ExchangeOptionsItemView>.reuseIdentifier
  }
}
