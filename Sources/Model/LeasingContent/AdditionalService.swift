//
//  AdditionalService.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct AdditionalService: Codable {
  enum AdditionalServiceType: String, Codable {
    case serviceProgram = "SERVICE_PROGRAM"
    case samsungCarePack = "SAMSUNG_CARE_PACK"
    case partnerService = "PARTNER_SERVICE"
    case xboxGamePassUltimate = "XBOX_GAME_PASS_ULTIMATE"
    case homeCreditInsuranceIphone = "HOME_CREDIT_INSURANCE_IPHONE"
  }
  
  let code: String
  let name: String
  let obligatory: Bool
  let price: Int
  let type: AdditionalServiceType
}
