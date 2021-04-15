//
//  QuestionnaireResultViewModelProtocol.swift
//  ForwardLeasing
//

import Foundation

protocol QuestionnaireResultViewModelProtocol: class {
  var onDidRequestToShowErrorBanner: ((Error) -> Void)? { get set }
  var onDidStartRequest: (() -> Void)? { get set }
  var onDidFinishRequest: (() -> Void)? { get set }

  var screenTitle: String { get }
  var questionnaireFormatter: QuestionnaireFormatter { get }
  var starsViewModel: StarsViewModel { get }
  var priceListViewModel: PriceListViewModel { get }

  func finish()
}
