//
//  ClientPersonalData.swift
//  ForwardLeasing
//

import Foundation

struct ClientPersonalData: Codable, EncodableToDictionary {
  enum CodingKeys: String, CodingKey {
    case firstName, middleName, lastName, hasMiddleName, sex,
         birthDate, birthPlace, ident, issueDate, issuer, issuerCode,
         documentType, registrationAddress, salary, clientInfo, monthlySalary, occupation
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
  let monthlySalary: Int
  let occupation: String
  let registrationAddress: Address?
  let passportNumber: String?

  var passportData: DocumentData {
    return DocumentData(clientPersonalData: self)
  }
  
  private var clientInfo: ClientInfo {
    return ClientInfo(data: self)
  }

  init(firstName: String, middleName: String?, lastName: String,
       birthDate: String, birthPlace: String, issueDate: String,
       issuer: String, issuerCode: String, sex: Sex, documentType: DocumentType,
       monthlySalary: Int, occupation: String, registrationAddress: Address) {
    self.firstName = firstName
    self.middleName = middleName
    self.lastName = lastName
    self.birthDate = birthDate
    self.birthPlace = birthPlace
    self.issueDate = issueDate
    self.issuer = issuer
    self.issuerCode = issuerCode
    self.sex = sex
    self.documentType = documentType
    self.monthlySalary = monthlySalary
    self.occupation = occupation
    self.registrationAddress = registrationAddress
    self.passportNumber = nil
    hasMiddleName = !middleName.isEmptyOrNil
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    firstName = try container.decode(String.self, forKey: .firstName)
    middleName = try container.decode(String.self, forKey: .middleName)
    lastName = try container.decode(String.self, forKey: .lastName)
    hasMiddleName = try container.decode(Bool.self, forKey: .hasMiddleName)
    sex = try container.decode(Sex.self, forKey: .sex)
    birthDate = try container.decode(String.self, forKey: .birthDate)
    birthPlace = try container.decode(String.self, forKey: .birthPlace)
    issueDate = try container.decode(String.self, forKey: .issueDate)
    issuer = try container.decode(String.self, forKey: .issuer)
    issuerCode = try container.decode(String.self, forKey: .issuerCode)
    documentType = try container.decode(DocumentType.self, forKey: .documentType)
    monthlySalary = try container.decode(Int.self, forKey: .salary)
    registrationAddress = try container.decodeIfPresent(Address.self, forKey: .registrationAddress)
    occupation = try container.decode(String.self, forKey: .occupation)
    passportNumber = try container.decodeIfPresent(String.self, forKey: .ident)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(clientInfo, forKey: .clientInfo)
    try container.encode(monthlySalary, forKey: .monthlySalary)
    try container.encode(occupation, forKey: .occupation)
  }
}
