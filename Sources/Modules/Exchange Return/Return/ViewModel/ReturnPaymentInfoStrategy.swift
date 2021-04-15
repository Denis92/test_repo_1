//
//  ReturnPaymentInfoStrategy.swift
//  ForwardLeasing
//

import Foundation

struct ReturnPaymentInfoStrategy: ExchangeReturnPaymentInfoStrategy {
  func makePaymentInfo(with leasingEntity: LeasingEntity) -> PaymentInfo? {
    guard let contractNumber = leasingEntity.contractNumber,
          let paymentSumm = leasingEntity.contractActionInfo?.upgradeReturnPaymentSum else {
      return nil
    }
    return makePaymentInfo(with: contractNumber,
                           paymentSumm: paymentSumm)
  }
}
