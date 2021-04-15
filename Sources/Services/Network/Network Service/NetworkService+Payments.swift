//
//  NetworkService+Payments.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: PaymentsNetworkProtocol {
  func pay(paymentInfo: PaymentInfo) -> Promise<PaymentRegistrationResponse> {
    let parameters = try? paymentInfo.asDictionary()
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(method: .post, url: URLFactory.Payments.payments,
                       parameters: parameters)
  }
}
