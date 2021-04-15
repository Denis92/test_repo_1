//
//  TitleHeaderViewModel.swift
//  ForwardLeasing
//

import UIKit

struct TitleHeaderViewModel: CommonTableHeaderFooterViewModel {
  let headerFooterReuseIdentifier = TitleHeader.reuseIdentifier
  
  let title: String?
  let topOffset: CGFloat?
  
  init(title: String?, topOffset: CGFloat? = nil) {
    self.title = title
    self.topOffset = topOffset
  }
}
