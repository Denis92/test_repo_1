//
//  RadioButton.swift
//  ForwardLeasing
//

import UIKit

class RadioButton: UIControl {
  override var intrinsicContentSize: CGSize {
    return CGSize(width: 44, height: 44)
  }
  
  override var isSelected: Bool {
    didSet {
      onDidChangeValue?(self)
      sendActions(for: .valueChanged)
      updateRadioButtonAppearance()
    }
  }
  
  override var isEnabled: Bool {
    didSet {
      alpha = isEnabled ? 1 : 0.4
    }
  }
  
  var allowDeselection: Bool = false
  
  var onDidChangeValue: ((RadioButton) -> Void)?
  
  private let outlineView = UIView()
  private let checkmarkView = UIView()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Actions
  
  @objc private func didTapView() {
    guard !isSelected || allowDeselection else { return }
    isSelected.toggle()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupOutline()
    setupCheckmark()
  }
  
  private func setupContainer() {
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
  }
  
  private func setupOutline() {
    addSubview(outlineView)
    
    outlineView.layer.borderWidth = 2
    outlineView.layer.borderColor = UIColor.shade60.cgColor
    outlineView.layer.cornerRadius = 11
    
    outlineView.snp.makeConstraints { make in
      make.width.height.equalTo(22)
      make.center.equalToSuperview()
    }
  }
  
  private func setupCheckmark() {
    addSubview(checkmarkView)
    
    checkmarkView.backgroundColor = .accent
    checkmarkView.layer.cornerRadius = 7
    
    checkmarkView.snp.makeConstraints { make in
      make.width.height.equalTo(0)
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Private methods
  
  private func updateRadioButtonAppearance() {
    UIView.transition(with: outlineView, duration: 0.15, options: .transitionCrossDissolve, animations: {
      self.outlineView.layer.borderColor = self.isSelected ? UIColor.accent.cgColor : UIColor.shade60.cgColor
    }, completion: nil)
    
    UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 5,
                   options: .curveEaseInOut, animations: {
                    self.checkmarkView.snp.remakeConstraints { make in
                      make.width.height.equalTo(self.isSelected ? 14 : 0)
                      make.center.equalToSuperview()
                    }
                    self.layoutIfNeeded()
    }, completion: nil)
  }
}
