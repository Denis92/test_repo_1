//
//  ClientInfo.swift
//  ForwardLeasing
//

import Foundation

struct ClientInfo: Codable, ClientInfoProtocol {
  enum CodingKeys: String, CodingKey {
    case firstName, middleName = "patronymicName", lastName,
         documentType, issueDate, birthDate, birthPlace, sex, registrationAddress, issuer,
         issuerCode, hasMiddleName
  }

  let firstName: String
  let middleName: String?
  let lastName: String
  let hasMiddleName: Bool
  let birthDate: String
  let birthPlace: String
  let issueDate: String
  let issuer: String
  let issuerCode: String
  let sex: Sex
  let documentType: DocumentType
  let registrationAddress: Address?
  
  init(data: ClientPersonalData) {
    self.firstName = data.firstName
    self.middleName = data.middleName
    self.lastName = data.lastName
    self.hasMiddleName = data.hasMiddleName
    self.birthDate = data.birthDate
    self.birthPlace = data.birthPlace
    self.issueDate = data.issueDate
    self.issuer = data.issuer
    self.issuerCode = data.issuerCode
    self.sex = data.sex
    self.documentType = data.documentType
    self.registrationAddress = data.registrationAddress
  }
}
