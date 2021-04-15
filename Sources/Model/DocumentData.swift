//
//  DocumentData.swift
//  ForwardLeasing
//

import Foundation

struct DocumentData: Codable {
  let success: Bool

  var name: String? {
    return documentFields.first { $0.fieldName == .name }?.fieldValue
  }

  var patronymic: String? {
    return documentFields.first { $0.fieldName == .patronymic }?.fieldValue
  }

  var surname: String? {
    return documentFields.first { $0.fieldName == .surname }?.fieldValue
  }

  var birthdate: Date? {
    guard let string = documentFields.first(where: { $0.fieldName == .birthdate })?.fieldValue else {
      return nil
    }
    return DateFormatter.dayMonthYearDocument.date(from: string) ?? DateFormatter.dayMonthYearISO.date(from: string)
  }

  var birthplace: String? {
    return documentFields.first { $0.fieldName == .birthplace }?.fieldValue
  }

  let passportNumber: String?

  var issueDate: Date? {
    guard let string = documentFields.first(where: { $0.fieldName == .issueDate })?.fieldValue else {
      return nil
    }
    return DateFormatter.dayMonthYearDocument.date(from: string) ?? DateFormatter.dayMonthYearISO.date(from: string)
  }

  var passportIssuedBy: String? {
    return documentFields.first { $0.fieldName == .passportIssuedBy }?.fieldValue
  }

  var passportIssuedByCode: String? {
    return documentFields.first { $0.fieldName == .passportIssuedByCode }?.fieldValue
  }

  var sex: Sex? {
    guard let fieldValue = documentFields.first { $0.fieldName == .sex }?.fieldValue else {
      return nil
    }
    return Sex(passportString: fieldValue) ?? Sex(rawValue: fieldValue)
  }

  private let documentFields: [DocumentField]

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let fieldOptionals = (try? container.decodeIfPresent([FailableDecodable<DocumentField>].self,
                                                         forKey: .documentFields)) ?? []
    success = try container.decode(Bool.self, forKey: .success)
    documentFields = fieldOptionals.compactMap { $0.value }
    guard let series = documentFields.first(where: { $0.fieldName == .passportSeries })?.fieldValue,
          let number = documentFields.first(where: { $0.fieldName == .passportNumber })?.fieldValue else {
      passportNumber = nil
      return
    }
    passportNumber = [series, number].joined(separator: " ")
  }
  
  init(clientPersonalData: ClientPersonalData) {
    let fields: [DocumentFieldType] = [
      .surname, .patronymic, .name, .birthdate, .birthplace, .issueDate,
      .passportIssuedBy, .passportIssuedByCode, .sex
    ]
    documentFields = fields.compactMap {
      var value: String?
      switch $0 {
      case .surname:
        value = clientPersonalData.lastName
      case .patronymic:
        value = clientPersonalData.middleName
      case .name:
        value = clientPersonalData.firstName
      case .birthdate:
        value = clientPersonalData.birthDate
      case .birthplace:
        value = clientPersonalData.birthPlace
      case .issueDate:
        value = clientPersonalData.issueDate
      case .passportIssuedBy:
        value = clientPersonalData.issuer
      case .passportIssuedByCode:
        value = clientPersonalData.issuerCode
      case .sex:
        value = clientPersonalData.sex.rawValue
      default:
        break
      }
      guard let fieldValue = value else {
        return nil
      }
      return DocumentField(fieldName: $0, fieldValue: fieldValue)
    }
    passportNumber = clientPersonalData.passportNumber
    success = true
  }
}

private struct FailableDecodable<Value: Decodable>: Decodable {
  let value: Value?

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.value = try? container.decode(Value.self)
  }
}

private enum DocumentFieldType: String, Codable {
  case surname, patronymic, name, birthdate, birthplace, passportSeries = "series",
       passportNumber = "number_page2", issueDate = "issue_date", passportIssuedBy = "authority",
       passportIssuedByCode = "authority_code",
       sex = "gender"
}

private struct DocumentField: Codable {
  let fieldName: DocumentFieldType
  let fieldValue: String
}
