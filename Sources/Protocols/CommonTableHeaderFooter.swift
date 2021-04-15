//
//  CommonTableHeaderFooter.swift
//  ForwardLeasing
//

import UIKit

protocol CommonTableHeaderFooterViewModel {
  var headerFooterReuseIdentifier: String { get }
}

protocol CommonTableHeaderFooter {
  func configure(with viewModel: CommonTableHeaderFooterViewModel)
}
