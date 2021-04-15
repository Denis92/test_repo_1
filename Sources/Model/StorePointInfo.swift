//
//  StorePointInfo.swift
//  ForwardLeasing
//

import UIKit

struct StorePointInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case code, cityID = "cityId", retailerCode, name,
         address, metros = "metrosStations", description, latitude, longitude,
         phone, phoneExtension, workInfo, goods
  }
  
  enum AdditionalKeys: String, CodingKey {
    case retailerStoreCode, displayName, phoneNumber, phoneExt, workDescription, goodsAvailability
  }
  
  let code: String
  let cityID: Int
  let retailerCode: String
  let name: String
  let address: String
  let metros: [MetroStation]?
  let description: String?
  let latitude: Double
  let longitude: Double
  let phone: String?
  let phoneExtension: String?
  let workInfo: String
  let goods: [AvailabilityInfo]?
  var hasRequiredGood: Bool
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let additionalContainer = try decoder.container(keyedBy: AdditionalKeys.self)
    if let code = try container.decodeIfPresent(String.self, forKey: .code) {
      self.code = code
    } else {
      self.code = try additionalContainer.decode(String.self, forKey: .retailerStoreCode)
    }
    cityID = try container.decode(Int.self, forKey: .cityID)
    retailerCode = try container.decode(String.self, forKey: .retailerCode)
    
    if let name = try container.decodeIfPresent(String.self, forKey: .name) {
      self.name = name
    } else {
      self.name = try additionalContainer.decode(String.self, forKey: .displayName)
    }
    
    address = try container.decode(String.self, forKey: .address)
    metros = try container.decodeIfPresent([MetroStation].self, forKey: .metros)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    latitude = try container.decode(Double.self, forKey: .latitude)
    longitude = try container.decode(Double.self, forKey: .longitude)
    
    if let phone = try container.decodeIfPresent(String.self, forKey: .phone) {
      self.phone = phone
    } else {
      phone = try additionalContainer.decodeIfPresent(String.self, forKey: .phoneNumber)
    }
    
    if let phoneExtension = try additionalContainer.decodeIfPresent(String.self, forKey: .phoneExt) {
      self.phoneExtension = phoneExtension
    } else {
      phoneExtension = try container.decodeIfPresent(String.self, forKey: .phoneExtension)
    }
    
    if let workInfo = try container.decodeIfPresent(String.self, forKey: .workInfo) {
      self.workInfo = workInfo
    } else {
      workInfo = try additionalContainer.decode(String.self, forKey: .workDescription)
    }
    
    if let goods = try container.decodeIfPresent([AvailabilityInfo].self, forKey: .goods) {
      self.goods = goods
    } else {
      goods = try additionalContainer.decodeIfPresent([AvailabilityInfo].self, forKey: .goodsAvailability)
    }
    hasRequiredGood = false
  }
}

struct MetroStation: Codable {
  enum CodingKeys: String, CodingKey {
    case name, lineColorHex = "lineColor", lineName
  }
  
  let name: String
  let lineColorHex: String
  let lineName: String
  
  var lineColor: UIColor? {
    return UIColor(hexString: lineColorHex)
  }
}

struct AvailabilityInfo: Codable {
  let goodCode: String
  let info: String?
  let amount: Int
}

// MARK: - Equatable
extension StorePointInfo: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.code == rhs.code && lhs.cityID == rhs.cityID &&
      lhs.retailerCode == rhs.retailerCode && lhs.name == rhs.name &&
      lhs.address == rhs.address
  }
}

// MARK: - Hashable
extension StorePointInfo: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(code)
    hasher.combine(cityID)
    hasher.combine(retailerCode)
    hasher.combine(name)
    hasher.combine(address)
  }
}
