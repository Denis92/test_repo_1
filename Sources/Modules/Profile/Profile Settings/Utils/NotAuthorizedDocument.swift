//
//  NotAuthorizedDocument.swift
//  ForwardLeasing
//

import Foundation

enum NotAuthorizedDocument: Int, CaseIterable {
  case policyOfPersonalDataProcessing
  case rulesOfLeasing
  
  var title: String {
    switch self {
    case .policyOfPersonalDataProcessing:
      return R.string.profileSettings.policyOfProcessingPersonalDataTitle()
    case .rulesOfLeasing:
      return R.string.profileSettings.leasingRulesTitle()
    }
  }
  
  var url: URL? {
    switch self {
    case .rulesOfLeasing:
      return URL(string: URLFactory.Documents.leasingRules)
    case .policyOfPersonalDataProcessing:
      return URL(string: URLFactory.Documents.personalDataPolicy)
    }
  }
}
