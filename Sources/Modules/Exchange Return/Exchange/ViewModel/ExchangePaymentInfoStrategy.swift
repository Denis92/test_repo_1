//
//  ExchangePaymentInfoStrategy.swift
//  ForwardLeasing
//

import Foundation

struct ExchangePaymentInfoStrategy: ExchangeReturnPaymentInfoStrategy {
  func makePaymentInfo(with leasingEntity: LeasingEntity) -> PaymentInfo? {
    guard let contractNumber = leasingEntity.previousContractNumber,
          let paymentSumm = leasingEntity.contractActionInfo?.upgradeReturnPaymentSum else {
      return nil
    }
    return makePaymentInfo(with: contractNumber,
                           paymentSumm: paymentSumm)
  }
}
