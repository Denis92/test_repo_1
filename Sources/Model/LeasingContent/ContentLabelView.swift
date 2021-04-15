//
//  ContentLabelView.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct ContentLabelView: Codable {
  enum ContentLabelViewType: String, Codable {
    case catalogView = "catalog_view"
    case catalogViewCharacteristics = "catalog_view_characteristics"
    case cardLeasingOptions = "card_leasing_options"
    case cardFormulaTip = "card_formula_tip"
    case feature = "feature"
    case characteristicsMain = "characteristics_main"
    case charateristicsSecondary = "charateristics_secondary"
  }
  
  let type: ContentLabelViewType
  let code: String
  let preview: ContentLabel
}
