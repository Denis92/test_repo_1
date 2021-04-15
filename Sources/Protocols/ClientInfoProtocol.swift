//
//  ClientInfoProtocol.swift
//  ForwardLeasing
//

import Foundation

protocol ClientInfoProtocol {
  var firstName: String { get }
  var middleName: String? { get }
  var lastName: String { get }
  var birthDate: String { get }
  var birthPlace: String { get }
  var issueDate: String { get }
  var issuer: String { get }
  var issuerCode: String { get }
}
