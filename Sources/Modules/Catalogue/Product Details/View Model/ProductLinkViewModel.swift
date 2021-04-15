//
//  ProductLinkViewModel.swift
//  ForwardLeasing
//

import Foundation

protocol ProductLinkViewModelDelegate: class {
  func productLinkViewModel(_ viewModel: ProductLinkViewModel, didTapLinkWithURL url: URL?,
                            title: String?)
}

class ProductLinkViewModel {
  weak var delegate: ProductLinkViewModelDelegate?
  
  let title: String?
  let url: URL?
  
  init(title: String?, url: URL?) {
    self.title = title
    self.url = url
  }
  
  func didTapView() {
    delegate?.productLinkViewModel(self, didTapLinkWithURL: url, title: title)
  }
}
