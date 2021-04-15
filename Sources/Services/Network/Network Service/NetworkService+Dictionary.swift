//
//  NetworkService+Dictionary.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit
import Alamofire

extension NetworkService: DictionaryNetworkProtocol {
  private struct Keys {
    static let searchText = "searchText"
  }

  func searchAddress(text: String) -> Promise<AddressResponse> {
    let parameters = [Keys.searchText: text]
    return baseRequest(requestType: .authNotRequired, method: .get,
                       url: URLFactory.Dictionary.searchAddress, parameters: parameters, encoding: URLEncoding.queryString)
  }
}
