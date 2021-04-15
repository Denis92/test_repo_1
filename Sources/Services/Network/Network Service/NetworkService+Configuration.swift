//
//  NetworkService+Configuration.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: ConfigurationNetworkProtocol {
  func getConfiguration() -> Promise<ConfigurationReponse> {
    return baseRequest(requestType: .authNotRequired, method: .get, url: URLFactory.Configuration.configuration)
  }
}
