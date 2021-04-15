//
//  ExchangeReturnPaymentInfoStrategy.swift
//  ForwardLeasing
//

import Foundation

protocol ExchangeReturnPaymentInfoStrategy {
  func makePaymentInfo(with leasingEntity: LeasingEntity) -> PaymentInfo?
}

extension ExchangeReturnPaymentInfoStrategy {
  func makePaymentInfo(with contractNumber: String, paymentSumm: Decimal) -> PaymentInfo {
    return PaymentInfo(contractNumber: contractNumber,
                       paymentSum: paymentSumm,
                       cardID: nil,
                       shouldCreateTemplate: false,
                       paymentType: .commision)
  }
}
