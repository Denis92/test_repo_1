//
//  PlistConfigurationManager.swift
//  ForwardLeasing
//

import Foundation

class PlistConfigurationManager {
  static func makeValue(from key: String) -> Any? {
    let bundle = Bundle.main
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
    
    return currentEnvironment[key]
  }
}
