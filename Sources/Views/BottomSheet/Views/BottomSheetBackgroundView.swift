//
//  BottomSheetBackgroundView.swift
//  ForwardLeasing
//

import UIKit

class BottomSheetBackgroundView: UIView {
  var onViewDidReceiveTap: (() -> Void)?
  
  init(frame: CGRect, sheetType: SheetType) {
    super.init(frame: frame)
    alpha = 0
    backgroundColor = UIColor.black.withAlphaComponent(0.4)
    
    guard sheetType == .hiding else { return }
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onViewDidReceIveTap(_ :)))
    addGestureRecognizer(tapGesture)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func remove(completion: (() -> Void)?) {
    UIView.animate(withDuration: 0.3, animations: {
      self.alpha = 0
    }, completion: { _ in
      completion?()
    })
  }
}

extension BottomSheetBackgroundView {
  @objc private func onViewDidReceIveTap(_ sender: UITapGestureRecognizer) {
    onViewDidReceiveTap?()
  }
}
