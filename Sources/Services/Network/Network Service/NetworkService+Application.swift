//
//  NetworkService+Application.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

private extension Constants {
  static let passportUploadImageType = "PASSPORT_RECOGNIZE"
}

extension NetworkService: ApplicationNetworkProtocol {
  private struct Keys {
    static let imageType = "imageType"
    static let imageData = "imageData"
    static let otp = "otp"
    static let monthlySalary = "monthlySalary"
    static let occupation = "occupation"
  }
  
  func checkApplicationStatus(applicationID: String) -> Promise<LeasingEntity> {
    return baseRequest(requestType: .common, method: .post,
                       url: URLFactory.LeasingApplication.checkStatus(applicationID: applicationID))
  }

  func sendApplicationForScoring(applicationID: String) -> Promise<LeasingEntity> {
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(requestType: .common, method: .post,
                       url: URLFactory.LeasingApplication.initiateScoring(applicationID: applicationID))
  }

  func getApplicationData(applicationID: String) -> Promise<LeasingEntity> {
    let url = URLFactory.LeasingApplication.applicationData(applicationID: applicationID)
    let response: Promise<ApplicationInfoResponse> = baseRequest(requestType: .common, method: .get,
                                                                 url: url)
    return response.map(\.applicationInfo)
  }

  func cancelApplication(applicationID: String) -> Promise<EmptyResponse> {
    return baseRequest(requestType: .authNotRequired, method: .post,
                       url: URLFactory.LeasingApplication.cancel(applicationID: applicationID))
  }

  func cancelReturnApplication(applicationID: String) -> Promise<EmptyResponse> {
    return baseRequest(method: .post, url: URLFactory.LeasingApplication.cancelReturn(applicationID: applicationID))
  }

  func saveClientData(data: ClientPersonalData, applicationID: String) -> Promise<ApplicationInfoResponse> {
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    let url = URLFactory.LeasingApplication.clientData(applicationID: applicationID)
    do {
      let parameters = try data.asDictionary()
      return baseRequest(requestType: .common, method: .post, url: url, parameters: parameters)
    } catch {
      return Promise(error: NetworkErrorService.requestCreationError)
    }
  }

  func saveClientData(monthlySalary: Int, occupation: String, applicationID: String) -> Promise<EmptyResponse> {
    let url = URLFactory.LeasingApplication.clientData(applicationID: applicationID)
    let parameters: [String: Any] = [Keys.monthlySalary: monthlySalary,
                                     Keys.occupation: occupation]
    return baseRequest(requestType: .common, method: .post, url: url, parameters: parameters)
  }

  func checkOtherApplications(applicationID: String) -> Promise<[LeasingEntity]> {
    let url = URLFactory.Cabinet.currentApplications(applicationID: applicationID)
    let response: Promise<ApplicationListResponse> = baseRequest(requestType: .common, method: .get, url: url)
    return response.map(\.clientLeasingEntities)
  }

  func checkAllApplications() -> Promise<[LeasingEntity]> {
    let url = URLFactory.Cabinet.allApplications
    let response: Promise<ApplicationListResponse> = baseRequest(requestType: .common, method: .get, url: url)
    return response.map(\.clientLeasingEntities)
  }

  func getClientInfo() -> Promise<MaskedClientInfo> {
    let response: Promise<ClientInfoResponse> = baseRequest(method: .get, url: URLFactory.Cabinet.clentInfo)
    return response.map(\.previousClientInfo)
  }

  func uploadPassportScan(applicationID: String, imageData: Data) -> Promise<PassportScanResponse> {
    let parameters = [
      Keys.imageType: Constants.passportUploadImageType,
      Keys.imageData: imageData.base64EncodedString()
    ]
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(method: .post,
                       url: URLFactory.LeasingApplication.uploadPhoto(applicationID: applicationID),
                       parameters: parameters)
  }
  
  func startLivenessSession(applicationID: String) -> Promise<LivenessCredentials> {
    return baseRequest(requestType: .common, method: .get,
                       url: URLFactory.LeasingApplication.livenessSession(applicationID: applicationID))
  }
  
  func checkLivenessPhoto(applicationID: String) -> Promise<EmptyResponse> {
    try? invalidateCaches(for: [ProfileCacheInfo.contracts], groups: [ProfileCacheInfo.group, ContractCacheInfo.group])
    return baseRequest(method: .post, url: URLFactory.LeasingApplication.livenessPhoto(applicationID: applicationID))
  }
}
