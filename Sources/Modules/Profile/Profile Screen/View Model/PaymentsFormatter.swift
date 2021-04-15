//
//  PaymentsFormatter.swift
//  ForwardLeasing
//

import Foundation

struct PaymentsFormatter {
  func monthPaymentString(for monthPayment: Decimal?) -> String {
    guard let monthPayment = monthPayment else {
      return ""
    }
    let formatter = NumberFormatter.currencyFormatter(withSymbol: true)
    return formatter.string(from: Amount(decimal: monthPayment)) ?? ""
  }
  
  func paidTotalString(payedSum: Decimal?, remainsSum: Decimal?) -> String {
    guard let payedSum = payedSum, let remainsSum = remainsSum else {
      return ""
    }
    let formatter = NumberFormatter.currencyFormatter(withSymbol: true)
    let payedSumString = formatter.string(from: Amount(decimal: payedSum)) ?? ""
    let remainsSumString = formatter.string(from: Amount(decimal: remainsSum)) ?? ""
    if payedSumString.isEmpty || remainsSumString.isEmpty {
      return ""
    } else {
      let summString = [payedSumString, remainsSumString].joined(separator: " / ")
      return R.string.productCard.alreadyPaidTitle(summString)
    }
  }
  
  func paymentDateString(with date: Date?) -> String {
    guard let date = date else {
      return ""
    }
    let formatter = DateFormatter.dayMonthDisplayable
    let dateString = formatter.string(from: date)
    return R.string.productCard.nextPaymentDateTitle(dateString)
  }
}
