//
//  ProductMonthlyPaymentViewModel.swift
//  ForwardLeasing
//

import UIKit

class ProductMonthlyPaymentViewModel: ProductDetailsItemViewModel {
  // MARK: - Types
  
  struct MonthlyPaymentProperties {
    let value: String
    let description: String
  }
  
  // MARK: - Properties
  
  var onDidUpdate: (() -> Void)?
  
  var monthlySumText: String? {
    if let priceString = monthlySum.rounded(precision: 0).priceString() {
      return R.string.productDetails.monthlySumText(priceString)
    } else {
      return nil
    }
  }
  
  var equationText: String? {
    if let leasingSumText = leasingSum.priceString(withSymbol: false),
       let residualSumText = residualSum.priceString(withSymbol: false),
       let monthlySumText = monthlySum.rounded(precision: 0).priceString(withSymbol: false) {
      if residualSum == 0 {
        return "\(leasingSumText) / \(paymentsCount) = \(monthlySumText)"
      } else {
        return "(\(leasingSumText) – \(residualSumText)) / \(paymentsCount) = \(monthlySumText)"
      }
    } else {
      return nil
    }
  }
  
  var properties: [MonthlyPaymentProperties] {
    var properties: [MonthlyPaymentProperties] = []
    if let leasingSumText = leasingSum.priceString() {
      properties.append(MonthlyPaymentProperties(value: leasingSumText,
                                                 description: R.string.productDetails.leasingSumPropertyText()))
    }
    if residualSum != 0, let residualSumText = residualSum.priceString() {
      properties.append(MonthlyPaymentProperties(value: residualSumText,
                                                 description: R.string.productDetails.residualSumPropertyText()))
    }
    properties.append(MonthlyPaymentProperties(value: String(paymentsCount),
                                               description: R.string.productDetails.paymentsCountPropertyText()))
    return properties
  }
  
  let type: ProductDetailsItemType = .monthlyPayment
  let customSpacing: CGFloat? = 44

  private var leasingSum: Decimal
  private var residualSum: Decimal
  private var paymentsCount: Int
  
  private var monthlySum: Decimal {
    return (leasingSum - residualSum) / Decimal(paymentsCount)
  }
  
  // MARK: - Init
  
  init(leasingSum: Decimal, residualSum: Decimal, paymentsCount: Int) {
    self.leasingSum = leasingSum
    self.residualSum = residualSum
    self.paymentsCount = paymentsCount
  }
  
  // MARK: - Public methods
  
  func update(leasingSum: Decimal, residualSum: Decimal, paymentsCount: Int) {
    self.leasingSum = leasingSum
    self.residualSum = residualSum
    self.paymentsCount = paymentsCount
    onDidUpdate?()
  }
}
