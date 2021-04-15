//
//  ConfigurationReponse.swift
//  ForwardLeasing
//

import Foundation

struct ConfigurationReponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case configInfo, infoMessage, versionInfo, occupationOptions = "occupationDict"
  }
  
  let configInfo: ConfigInfo
  let infoMessage: InfoData?
  let versionInfo: VersionData?
  let occupationOptions: [OccupationData]
}
