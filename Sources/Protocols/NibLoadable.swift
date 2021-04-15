//
//  NibLoadable.swift
//  ForwardLeasing
//

import UIKit

protocol NibLoadable: class {
  var nibName: String? { get }
  var loadedView: UIView? { get set }
  func loadFromNib()
}

class NibView: UIView, NibLoadable {
  var loadedView: UIView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadFromNib()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    loadFromNib()
  }
}

extension NibLoadable where Self: UIView {
  var nibName: String? {
    return type(of: self).description().components(separatedBy: ".").last
  }
  
  func loadFromNib() {
    guard let nibName = nibName else { return }
    let bundle = Bundle(for: type(of: self))
    guard let loadedView = bundle.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView else { return }
    addSubview(loadedView)
    loadedView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    self.loadedView = loadedView
  }
}
