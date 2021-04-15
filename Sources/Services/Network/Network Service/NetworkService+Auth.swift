//
//  NetworkService+Auth.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: AuthNetworkProtocol {
  private struct Keys {
    static let phone = "mobilePhone"
    static let pin = "pin"
  }

  private struct RegisterRequestKeys {
    static let email = "email"
    static let phone = "mobilePhone"
  }
  
  private struct CheckCodeRequestKeys {
    static let code = "smsCode"
  }
  
  private struct SavePinCodeRequestKeys {
    static let pin = "pin"
  }

  func signIn(phone: String, pin: String) -> Promise<CheckCodeResult> {
    let parameters = [
      Keys.phone: phone,
      Keys.pin: pin
    ]
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.Bouncer.token, parameters: parameters)
  }
  
  func register(email: String, phone: String) -> Promise<SessionResponse> {
    var parameters: [String: Any] = [:]
    parameters[RegisterRequestKeys.email] = email
    parameters[RegisterRequestKeys.phone] = phone
    return baseRequest(requestType: .authNotRequired,
                       method: .post,
                       url: URLFactory.Auth.register, parameters: parameters)
  }
  
  func recoveryPin(phone: String) -> Promise<SessionResponse> {
    var parameters: [String: Any] = [:]
    parameters[RegisterRequestKeys.phone] = phone
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.Auth.register,
                       parameters: parameters)
  }
  
  func checkCode(code: String, sessionID: String) -> Promise<CheckCodeResult> {
    let parameters: [String: Any] = [CheckCodeRequestKeys.code: code]
    return baseRequest(requestType: .authNotRequired,
                       method: .post, url: URLFactory.Auth.checkCode(sessionID: sessionID),
                       parameters: parameters)
  }
  
  func resendSmsCode(sessionID: String) -> Promise<EmptyResponse> {
    return baseRequest(requestType: .authNotRequired, method: .post, url: URLFactory.Auth.resendSMS(sessionID: sessionID))
  }
  
  func savePin(pinCode: String, sessionID: String) -> Promise<TokenResponse> {
    let parameters: [String: Any] = [SavePinCodeRequestKeys.pin: pinCode]
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.Auth.savePin(sessionID: sessionID), parameters: parameters)
  }
}
