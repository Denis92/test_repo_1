//
//  IntrinsicTableView.swift
//  ForwardLeasing
//

import UIKit

class IntrinsicTableView: UITableView {
  // MARK: - Properties
  
  override var contentSize: CGSize {
    didSet {
      invalidateIntrinsicContentSize()
    }
  }
  
  override var intrinsicContentSize: CGSize {
    layoutIfNeeded()
    return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
  }
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero, style: .plain)
    backgroundColor = .clear
    separatorStyle = .none
    isScrollEnabled = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
