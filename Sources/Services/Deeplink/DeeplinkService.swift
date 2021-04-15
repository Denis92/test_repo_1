//
//  DeeplinkService.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  // Hosts
  static let catalogueHost = "catalog"
  static let contractsHost = "contracts"
  static let allHosts = [catalogueHost, contractsHost]
  
  // Regex
  static let productDetailsRegex = "\\/models\\/\\w"
  static let categoryRegex = "\\/category\\/\\w"
  static let contractDetailsRegex = "\\/\\w"
}

protocol DeeplinkServiceDelegate: class {
  func deeplinkService(_ service: DeeplinkService, didRequestOpenDeeplink deeplink: DeeplinkType)
}

class DeeplinkService {
  weak var delegate: DeeplinkServiceDelegate?
  
  func parseLink(_ url: URL?) {
    guard let url = url, url.scheme == Constants.urlScheme, let host = url.host,
          Constants.allHosts.contains(host) else { return }
    switch host {
    case Constants.catalogueHost:
      parseCatalogueHost(with: url.path)
    case Constants.contractsHost:
      parseContractHost(with: url.path)
    default:
      break
    }
  }
  
  private func parseCatalogueHost(with path: String) {
    if path.matches(regularExpression: Constants.productDetailsRegex) {
      let goodCode = path.replacingOccurrences(of: Constants.productDetailsRegex,
                                               with: "", options: .regularExpression)
      delegate?.deeplinkService(self, didRequestOpenDeeplink: .productDetails(goodCode: goodCode.sanitizedSlash()))
    } else if path.matches(regularExpression: Constants.categoryRegex) {
      let categoryCode = path.replacingOccurrences(of: Constants.categoryRegex, with: "", options: .regularExpression)
      delegate?.deeplinkService(self, didRequestOpenDeeplink: .category(categoryCode: categoryCode.sanitizedSlash()))
    }
  }
  
  private func parseContractHost(with path: String) {
    if path.isEmpty {
      delegate?.deeplinkService(self, didRequestOpenDeeplink: .profile)
    } else if path.matches(regularExpression: Constants.contractDetailsRegex) {
      delegate?.deeplinkService(self, didRequestOpenDeeplink: .contractDetails(contractID: path.sanitizedSlash()))
    }
  }
}
