//
//  MaskedClientInfo.swift
//  ForwardLeasing
//

import Foundation

struct MaskedClientInfo: Decodable, ClientInfoProtocol {
  enum CodingKeys: String, CodingKey {
    case firstName, middleName = "patronymicNameMasked", lastName = "lastNameMasked",
         birthDate = "birthDateMasked", birthPlace = "birthPlaceMasked", email,
         issueDate = "issueDateMasked", issuer = "issuerMasked", issuerCode = "issuerCodeMasked",
         sex, registrationAddress = "registrationAddressMasked", passport = "identMasked", occupation
  }
  
  let firstName: String
  let middleName: String?
  let lastName: String
  let email: String
  let birthDate: String
  let birthPlace: String
  let issueDate: String
  let issuer: String
  let issuerCode: String
  let sex: Sex
  let registrationAddress: String
  let passport: String
  let occupation: String
}
