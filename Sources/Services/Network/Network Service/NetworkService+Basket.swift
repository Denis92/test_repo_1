//
//  NetworkService+Basket.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: BasketNetworkProtocol {
  private struct Keys {
    static let channel = "channel"
    static let usid = "usid"
    static let basketData = "basketData"
    static let productCode = "goodCode"
    static let count = "count"
    static let lang = "lang"
    static let deliveryType = "deliveryType"
  }

  func createBasket(productCode: String, deliveryType: DeliveryType, userID: String) -> Promise<CreateBasketResponse> {
    let basketData: [[String: Any]] = [[Keys.productCode: productCode,
                                        Keys.count: 1]]
    let parameters: [String: Any] = [Keys.channel: Constants.defaultChannel,
                                     Keys.usid: userID,
                                     Keys.lang: Constants.backendLanguageIdentifier,
                                     Keys.basketData: basketData,
                                     Keys.deliveryType: deliveryType.rawValue]
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.LeasingBasket.create, parameters: parameters)
  }
}
