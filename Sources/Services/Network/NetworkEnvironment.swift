//
//  NetworkEnvironment.swift
//  ForwardLeasing
//

import Foundation

struct NetworkEnvironment {
  private let host: String
  private let scheme: String

  var baseRestURLString: String {
    var urlComponents = URLComponents()
    urlComponents.scheme = scheme
    urlComponents.host = host
    return urlComponents.url?.absoluteString ?? ""
  }

  static var current: NetworkEnvironment {
    return NetworkEnvironment()
  }

  private init(bundle: Bundle = Bundle.main) {
    guard let configuration = bundle.infoDictionary?["Configuration"] as? String else {
      fatalError("Can't find value for 'Configuration' in the main bundle info dictionary")
    }

    guard let environmentsPlistPath = bundle.path(forResource: "Environments", ofType: "plist") else {
      fatalError("Can't find Environments.plist in the project resources")
    }

    guard let environments = NSDictionary(contentsOfFile: environmentsPlistPath) as? [String: Any] else {
      fatalError("Environments.plist is in incorrect format")
    }

    guard var currentEnvironment = environments[configuration] as? [String: Any] else {
      fatalError("Can't find environment for the configuration \(configuration)")
    }

    if let otherConfiguration = currentEnvironment["configuration"] as? String {
      guard let otherEnvironment = environments[otherConfiguration] as? [String: Any] else {
        fatalError("Can't find environment for the configuration \(otherConfiguration)")
      }
      currentEnvironment = otherEnvironment
    }

    guard let hostString = currentEnvironment["host"] as? String,
      let schemeString = currentEnvironment["scheme"] as? String else {
        fatalError("\(configuration) environment dictionary is in incorrect format")
    }

    host = hostString
    scheme = schemeString
  }
}
