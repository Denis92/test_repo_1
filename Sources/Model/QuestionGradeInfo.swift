//
//  QuestionGradeInfo.swift
//  ForwardLeasing
//

import Foundation

enum GradeType: String, Codable {
  case great = "A"
  case good = "B"
  case ok = "C"
  case none = "NONE"
  
  var rating: Int {
    switch self {
    case .great:
      return 5
    case .good:
      return 3
    case .ok:
      return 1
    case .none:
      return 0
    }
  }
}

struct QuestionGradeInfo: Codable {
  let gradeType: GradeType
  let title: String
  let subtitle: String?
  let upgradePrice: Int
  let gradeValue: Int
}
