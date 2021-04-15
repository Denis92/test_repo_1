//
//  NetworkService+PersonalDataRegistration.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: PersonalDataRegistrationProtocol {
  private struct Keys {
    static let otp = "otp"
    static let basketID = "basketId"
    static let type = "type"
    static let email = "email"
    static let phone = "mobilePhone"
    static let previousApplicationID = "previousApplicationId"
    static let agreementSimpleSign = "agreementSimpleSign"
  }
  
  func createLeasingApplication(basketID: String, type: LeasingApplicationType,
                                email: String, phone: String, previousApplicationID: String?) -> Promise<LeasingEntity> {
    var parameters: [String: Any] = [Keys.basketID: basketID,
                                     Keys.type: type.rawValue,
                                     Keys.email: email,
                                     Keys.phone: phone,
                                     Keys.agreementSimpleSign: true,
                                     Keys.previousApplicationID: previousApplicationID]
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.LeasingApplication.create, parameters: parameters)
  }
  
  func resendSmsCode(applicationID: String) -> Promise<EmptyResponse> {
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.LeasingApplication.resendCode(applicationID: applicationID))
  }
  
  func checkCode(code: String, applicationID: String) -> Promise<CheckCodeResult> {
    let parameters: [String: Any] = [Keys.otp: code]
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.LeasingApplication.checkCode(applicationID: applicationID),
                       parameters: parameters)
  }
  
  func refreshToken(applicationID: String) -> Promise<EmptyResponse> {
    let url = URLFactory.LeasingApplication.sendCodeWhenRefreshingToken(applicationID: applicationID)
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: url)
  }
  
  func checkRefreshTokenOTPCode(code: String, applicationID: String) -> Promise<CheckCodeResult> {
    let url = URLFactory.LeasingApplication.checkCodeWhenRefreshingToken(applicationID: applicationID)
    let parameters: [String: Any] = [Keys.otp: code]
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: url, parameters: parameters)
  }
}
