//
//  Address.swift
//  ForwardLeasing
//

import Foundation

struct AddressResult: Codable {
  let addressString: String
  var address: Address
}

struct Address: Codable, EncodableToDictionary {
  let region: String?
  let regionCode: String?
  let district: String?
  let districtCode: String?
  let town: String?
  let townCode: String?
  let locality: String?
  let localityCode: String?
  let taxCode: String?
  let street: String?
  let streetCode: String?
  let streetNum: String?
  let blockNum: String?
  let buildingNum: String?
  var flatNum: String?

  var isFullAddress: Bool {
    return !region.isEmptyOrNil && !town.isEmptyOrNil && !street.isEmptyOrNil && !streetNum.isEmptyOrNil && !flatNum.isEmptyOrNil
  }
}
