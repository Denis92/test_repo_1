//
//  NetworkService+Delivery.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: DeliveryNetworkProtocol {
  private struct DeliveryInfoKeys {
    static let deliveryAddressText = "deliveryAddressText"
    static let deliveryAddress = "deliveryAddress"
  }
  
  private struct GetStoresKeys {
    static let goodCode = "goodCode"
  }
  
  private struct SaveDeliveryTypeKeys {
    static let deliveryType = "deliveryType"
  }
  
  private struct PaymentKeys {
    static let deviceType = "deviceType"
    static let cancelPrevious = "cancelPrevious"
    static let createTemplate = "createTemplate"
  }

  private struct SetStoreKeys {
    static let retailerStoreCode = "retailerStoreCode"
    static let retailerCode = "retailerCode"
  }

  private struct ValidateOTPKeys {
    static let otp = "otp"
  }

  func getDeliveryTypes(applicationID: String) -> Promise<[ProductDeliveryOption]> {
    return baseRequest(method: .get, url: URLFactory.Cabinet.getDeliveryTypes(applicationID: applicationID))
  }
  
  func getStores(categoryCode: String, goodCode: String?) -> Promise<StoresResponse> {
    var url = URLFactory.LeasingStores.storesPoints(categoryCode: categoryCode)
    if let goodCode = goodCode {
      url = url.appendingQueryParameters([GetStoresKeys.goodCode: goodCode])
    }
    return baseRequest(method: .get,
                       url: url)
  }
  
  func getDeliveryInfo(applicationID: String, addressResult: AddressResult) -> Promise<ProductDeliveryInfo> {
    var parameters: [String: Any] = [:]
    parameters[DeliveryInfoKeys.deliveryAddressText] = addressResult.addressString
    if let address = try? addressResult.address.asDictionary() {
      parameters[DeliveryInfoKeys.deliveryAddress] = address
    }
    return baseRequest(method: .post,
                       url: URLFactory.DeliveryAct.deliveryInfo(applicationID: applicationID),
                       parameters: parameters)
  }
  
  func cancelDelivery(applicationID: String) -> Promise<EmptyResponse> {
    return baseRequest(method: .post,
                       url: URLFactory.DeliveryAct.deliveryCancel(applicationID: applicationID))
  }
  
  func saveDeliveryType(applicationID: String, deliveryType: DeliveryType) -> Promise<LeasingEntity> {
    var parameters: [String: Any] = [:]
    parameters[SaveDeliveryTypeKeys.deliveryType] = deliveryType.rawValue
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    let response: Promise<LeasingEntityResponse> = baseRequest(method: .post,
                                                               url: URLFactory.Cabinet.saveDeliveryType(applicationID: applicationID),
                                                               parameters: parameters)
    return response.map(\.clientLeasingEntity)
  }
  
  func saveApplicationDelivery(applicationID: String) -> Promise<OrderStatus> {
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    let response: Promise<SaveDeliveryResponse> = baseRequest(method: .post,
                                                              url: URLFactory.DeliveryAct.partnerOrder(applicationID: applicationID))
    return response.map(\.orderStatus)
  }
  
  func pay(applicationID: String, isCancelPrevious: Bool) -> Promise<PaymentResponse> {
    var parameters: [String: Any] = [:]
    parameters[PaymentKeys.deviceType] = Constants.deviceType
    parameters[PaymentKeys.cancelPrevious] = isCancelPrevious
    parameters[PaymentKeys.createTemplate] = true
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(method: .post, url: URLFactory.DeliveryAct.payment(applicationID: applicationID),
                       parameters: parameters)
  }
  
  func checkPayment(applicationID: String) -> Promise<CheckPaymentResponse> {
    return baseRequest(method: .get, url: URLFactory.DeliveryAct.checkPayment(applicationID: applicationID))
  }
  
  func confirmPayment(applicationID: String) -> Promise<EmptyResponse> {
    return baseRequest(method: .post, url: URLFactory.DeliveryAct.confirm(applicationID: applicationID))
  }

  func setStore(applicationID: String, storePoint: StorePointInfo) -> Promise<LeasingEntity> {
    var parameters: [String: Any] = [:]
    parameters[SetStoreKeys.retailerStoreCode] = storePoint.code
    parameters[SetStoreKeys.retailerCode] = storePoint.retailerCode
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    let response: Promise<LeasingEntityResponse> =  baseRequest(method: .post,
                                                                url: URLFactory.Cabinet.setStorePoint(applicationID: applicationID),
                                                                parameters: parameters)
    return response.map(\.clientLeasingEntity)
  }

  func signOTP(applicationID: String) -> Promise<EmptyResponse> {
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(method: .post,
                       url: URLFactory.DeliveryAct.signOTP(applicationID: applicationID))
  }

  func validateOTP(code: String, applicationID: String) -> Promise<CheckCodeResult> {
    let parameters: [String: Any] = [ValidateOTPKeys.otp: code]
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(method: .post,
                       url: URLFactory.DeliveryAct.validateOTP(applicationID: applicationID),
                       parameters: parameters)
  }
}
