//
//  NetworkService+CreateApplication.swift
//  ForwardLeasing
//

import Alamofire
import PromiseKit

private enum ApplicationType: String {
  case new = "NEW", upgrade = "UPGRADE"
}

extension NetworkService: CreateApplicationNetworkProtocol {
  private struct CreateApplicationRequestKeys {
    static let basketID = "basketId"
    static let type = "type"
    static let email = "email"
    static let phone = "mobilePhone"
    static let previousApplicationID = "previousApplicationId"
    static let agreementSimpleSign = "agreementSimpleSign"
  }

  func createBasket() -> Promise<EmptyResponse> {
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(requestType: .authNotRequired, method: .post, url: URLFactory.LeasingBasket.create)
  }

  func createNewApplication(basketID: String, email: String, phone: String, previousApplicationID: String?) -> Promise<EmptyResponse> {
    var parameters: Parameters = [CreateApplicationRequestKeys.basketID: basketID,
                                  CreateApplicationRequestKeys.type: ApplicationType.new.rawValue,
                                  CreateApplicationRequestKeys.email: email,
                                  CreateApplicationRequestKeys.phone: phone,
                                  CreateApplicationRequestKeys.previousApplicationID: previousApplicationID]
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(requestType: .authNotRequired, method: .post, url: URLFactory.LeasingApplication.create,
                       parameters: parameters)
  }
}
