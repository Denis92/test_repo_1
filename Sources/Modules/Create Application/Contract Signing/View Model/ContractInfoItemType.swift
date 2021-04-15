//
//  ContractInfoItemType.swift
//  ForwardLeasing
//

import UIKit

enum ContractInfoItemType {
  case monthlyPayment(payment: Decimal), monthsCount(count: Int), earlyExchange(price: Decimal, paymentsCount: Int),
       freeExchange(paymentsCount: Int), residualSum(sum: Decimal), earlyRedemption, noOverpayment,
       leasingServicePayment(payment: Decimal)
  
  var image: UIImage? {
    switch self {
    case .monthlyPayment:
      return R.image.contractInfoPaymentIcon()
    case .monthsCount:
      return R.image.contractInfoMontsCountIcon()
    case .earlyExchange:
      return R.image.contractInfoEarlyExchangeIcon()
    case .freeExchange:
      return R.image.contractInfoFreeExchangeIcon()
    case .residualSum:
      return R.image.contractInfoResidualSumIcon()
    case .earlyRedemption:
      return R.image.contractInfoEarlyRedemptionIcon()
    case .noOverpayment:
      return R.image.contractInfoNoOverpaymentIcon()
    case .leasingServicePayment:
      return R.image.contractInfoPaymentIcon()
    }
  }
  
  var title: String? {
    switch self {
    case .monthlyPayment(let payment):
      return payment.priceString()
    case .monthsCount(let count):
      return R.string.plurals.months(count: count)
    case .earlyExchange:
      return R.string.contractSigning.contractInfoEarlyExchangeTitle()
    case .freeExchange:
      return R.string.contractSigning.contractInfoFreeExchangeTitle()
    case .residualSum(let sum):
      return sum.priceString()
    case .earlyRedemption:
      return R.string.contractSigning.contractInfoEarlyRedemptionTitle()
    case .noOverpayment:
      return R.string.contractSigning.contractInfoNoOverpaymentTitle()
    case .leasingServicePayment(let payment):
      return payment.priceString()
    }
  }
  
  var description: String? {
    switch self {
    case .monthlyPayment:
      return R.string.contractSigning.contractInfoMonthlyPaymentDecription()
    case .monthsCount:
      return R.string.contractSigning.contractInfoMonthsCountDescription()
    case .earlyExchange(let payment, let paymentsCount):
      return R.string.contractSigning.contractInfoEarlyExchangeDescription(payment.priceString() ?? "",
                                                                           R.string.plurals.payments(count: paymentsCount))
    case .freeExchange(let paymentsCount):
      return R.string.contractSigning.contractInfoFreeExchangeDescription(R.string.plurals.payments(count: paymentsCount))
    case .residualSum:
      return R.string.contractSigning.contractInfoResidualSumDescription()
    case .earlyRedemption:
      return R.string.contractSigning.contractInfoEarlyRedemptionDescription()
    case .noOverpayment:
      return R.string.contractSigning.contractInfoNoOverpaymentDescription()
    case .leasingServicePayment:
      return R.string.contractSigning.contractInfoLeasingServicePaymentDescription()
    }
  }
}
