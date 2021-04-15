//
//  NetworkService+Orders.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: OrdersNetworkProtocol {
  private struct Keys {
    static let subscriptionID = "subscriptionId"
    static let deviceType = "deviceType"
    static let email = "email"
    static let createTemplate = "createTemplate"
    static let phone = "phone"
    static let cardID = "token"
  }
  
  func makeOrder(subscriptionID: String, card: PaymentCard, saveCard: Bool, email: String) -> Promise<PaymentResponse> {
    let parameters = makeParameters(subscriptionID: subscriptionID, email: email,
                                    card: card, saveCard: saveCard, phoneNumber: nil)
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(method: .post, url: URLFactory.Orders.make, parameters: parameters)
  }
  
  func makeOrderUnathorized(subscriptionID: String, card: PaymentCard,
                            email: String, phoneNumber: String) -> Promise<PaymentResponse> {
    let parameters = makeParameters(subscriptionID: subscriptionID, email: email, card: card, saveCard: false, phoneNumber: phoneNumber)
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.Orders.makeUnauthorized, parameters: parameters)
  }
  
  private func makeParameters(subscriptionID: String, email: String,
                              card: PaymentCard, saveCard: Bool, phoneNumber: String?) -> [String: Any] {
    var parameters: [String: Any] = [:]
    parameters[Keys.subscriptionID] = subscriptionID
    parameters[Keys.deviceType] = Constants.deviceType
    parameters[Keys.email] = email
    parameters[Keys.createTemplate] = saveCard
    if case let .card(paymentCard) = card {
      parameters[Keys.cardID] = paymentCard.id
    }
    if let phoneNumber = phoneNumber {
      parameters[Keys.phone] = phoneNumber
    }
    return parameters
  }
}
