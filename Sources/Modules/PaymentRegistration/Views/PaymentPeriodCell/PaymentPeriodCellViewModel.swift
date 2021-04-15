//
//  PaymentPeriodCellViewModel.swift
//  ForwardLeasing
//

import Foundation

struct PaymentPerionCellViewModel: CommonCollectionCellViewModel {
  var collectionCellIdentifier: String {
    return PaymentPeriodCell.reuseIdentifier
  }

  let dateString: String
  let sumString: String
  let paymentInformation: String
}
