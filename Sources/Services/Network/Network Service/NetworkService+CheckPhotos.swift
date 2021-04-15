//
//  NetworkService+CheckPhotos.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: CheckPhotosProtocol {
  func checkPhotos(applicationID: String) -> Promise<CheckPhotosResult> {
    return baseRequest(requestType: .authNotRequired,
                       method: .get,
                       url: URLFactory.LeasingApplication.checkPhotos(applicationID: applicationID))
  }
}
