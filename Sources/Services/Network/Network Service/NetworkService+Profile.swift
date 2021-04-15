//
//  NetworkService+Profile.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

enum ProfileCacheInfo: CacheInfo {
  case contracts
  
  var key: String {
    switch self {
    case .contracts:
      return URLFactory.Cabinet.contracts.md5
    }
  }
  
  var cacheTime: TimeInterval {
    return 15 * 60
  }
}

extension NetworkService: ProfileNetworkProtocol {
  func leasingContracts() -> Promise<[LeasingEntity]> {
    let response: Promise<LeasingEntitiesListResponse> = cachedRequest(method: .get, url: URLFactory.Cabinet.contracts,
                                                                       cacheInfo: ProfileCacheInfo.contracts)
    return response.map(\.clientLeasingEntities)
  }
}
