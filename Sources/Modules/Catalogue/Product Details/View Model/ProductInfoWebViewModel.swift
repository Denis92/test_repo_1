//
//  ProductInfoWebViewModel.swift
//  ForwardLeasing
//

import Foundation

struct ProductInfoWebViewModel {
  let infoViewModel: SelfSizedWebViewModelProtocol
  let title: String

  init(title: String, htmlInfoType: HTMLInfoType) {
    self.title = title
    self.infoViewModel = SelfSizedWebViewModel(htmlInfoType: htmlInfoType)
  }
}
