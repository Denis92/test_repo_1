//
//  NetworkService+Contract.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

enum ContractCacheInfo: CacheInfo {
  case contract(applicationID: String)
  
  var key: String {
    switch self {
    case .contract(let applicationID):
      return URLFactory.Cabinet.contract(applicationID: applicationID).md5
    }
  }
  
  var cacheTime: TimeInterval {
    return 15 * 60
  }
}

extension NetworkService: ContractNetworkProtocol {
  private struct Keys {
    static let otp = "otp"
  }
  
  func getContract(applicationID: String, useCache: Bool) -> Promise<LeasingEntityResponse> {
    if useCache {
      return cachedRequest(method: .get, url: URLFactory.Cabinet.contract(applicationID: applicationID),
                           cacheInfo: ContractCacheInfo.contract(applicationID: applicationID))
    } else {
      return baseRequest(method: .get, url: URLFactory.Cabinet.contract(applicationID: applicationID))
    }
  }
  
  func createContract(applicationID: String) -> Promise<EmptyResponse> {
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(method: .post, url: URLFactory.Cabinet.createContract(applicationID: applicationID))
  }
  
  func sendContractCode(applicationID: String) -> Promise<EmptyResponse> {
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.Cabinet.sendContractOTP(applicationID: applicationID))
  }
  
  func checkContractCode(code: String, applicationID: String) -> Promise<CheckCodeResult> {
    let parameters: [String: Any] = [Keys.otp: code]
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.Cabinet.validateContractOTP(applicationID: applicationID),
                       parameters: parameters)
  }
  
  func resendContractSmsCode(applicationID: String) -> Promise<EmptyResponse> {
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.Cabinet.resendContractOTP(applicationID: applicationID))
  }
  
  func cancelContract(applicationID: String) -> Promise<EmptyResponse> {
    return baseRequest(method: .post, url: URLFactory.Cabinet.cancelContract(applicationID: applicationID))
  }
  
  func getExchangeOffers(applicationID: String) -> Promise<ExchangeOffersResponse> {
    return baseRequest(method: .get,
                       url: URLFactory.Cabinet.contractExchangeOffers(applicationID: applicationID))
  }
  
  func getQuestionnaire(applicationID: String) -> Promise<QuestionnaireResponse> {
    return baseRequest(method: .get,
                       url: URLFactory.Cabinet.getQuestionnaire(applicationID: applicationID))
  }

  func returnContract(applicationID: String) -> Promise<LeasingEntityResponse> {
    return baseRequest(method: .post,
                       url: URLFactory.Cabinet.returnContract(applicationID: applicationID),
                       parameters: [:])
  }
  
  func cancelReturn(applicationID: String) -> Promise<EmptyResponse> {
    return baseRequest(method: .post, url: URLFactory.Cabinet.cancelReturn(applicationID: applicationID))
  }
  
  // TODO: - Add caching to device return method when it will be created
}
