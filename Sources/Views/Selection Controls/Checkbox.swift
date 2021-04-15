//
//  Checkbox.swift
//  ForwardLeasing
//

import UIKit

enum CheckboxType {
  case square, rounded
  
  var checkedImage: UIImage? {
    switch self {
    case .square:
      return R.image.checkboxSquareOn()
    case .rounded:
      return R.image.checkboxRoundOn()
    }
  }
  
  var uncheckedImage: UIImage? {
    switch self {
    case .square:
      return R.image.checkboxSquareOff()
    case .rounded:
      return R.image.checkboxRoundOff()
    }
  }
}

class Checkbox: UIControl {
  override var intrinsicContentSize: CGSize {
    return CGSize(width: 44, height: 44)
  }
  
  override var isSelected: Bool {
    didSet {
      sendActions(for: .valueChanged)
      updateImageView()
    }
  }
  
  override var isEnabled: Bool {
    didSet {
      alpha = isEnabled ? 1 : 0.4
    }
  }
  
  private let type: CheckboxType
  private let imageView = UIImageView()
  
  // MARK: - Init
  
  init(type: CheckboxType) {
    self.type = type
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Actions
  
  @objc private func didTapView() {
    isSelected.toggle()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupImageView()
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
  }
  
  private func setupImageView() {
    addSubview(imageView)
    updateImageView()
    imageView.snp.makeConstraints { make in
      make.width.height.equalTo(24)
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Private methods
  
  private func updateImageView() {
    UIView.transition(with: imageView, duration: 0.15, options: .transitionCrossDissolve, animations: {
      self.imageView.image = self.isSelected ? self.type.checkedImage : self.type.uncheckedImage
    }, completion: nil)
  }
}
