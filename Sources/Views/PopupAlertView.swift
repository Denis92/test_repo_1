//
//  PopupAlertView.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

class PopupAlertView: UIView {
  // MARK: - Subviews
    
  private let alertView = UIView()
  private let stackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .title3Semibold)
  
  private var stackViewHeightConstraint: Constraint?
    
  // MARK: - Init
    
  init(_ title: String?) {
    super.init(frame: .zero)
    titleLabel.text = title
    setup()
  }

  required init?(coder aCoder: NSCoder) {
    super.init(coder: aCoder)
    setup()
  }

  // MARK: - Setup

  private func setup() {
    setupAlertView()
    setupTitle()
    setupStackView()
  }

  private func setupAlertView() {
    addSubview(alertView)
    alertView.layer.masksToBounds = true
    alertView.layer.cornerRadius = 15
    alertView.backgroundColor = .base2
    alertView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.greaterThanOrEqualTo(226)
      make.width.equalTo(300).priority(250)
    }
  }
    
  private func setupTitle() {
    alertView.addSubview(titleLabel)
    titleLabel.numberOfLines = 15
    titleLabel.textAlignment = .center
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.height.greaterThanOrEqualTo(30)
      make.leading.equalTo(20)
      make.trailing.equalTo(-20)
    }
  }
    
  private func setupStackView() {
    alertView.addSubview(stackView)
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    stackView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(5)
      make.bottom.equalToSuperview().offset(-20)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      stackViewHeightConstraint = make.height.equalTo(0).constraint
    }
  }
    
  public func addButton(_ button: StandardButton) {
    stackViewHeightConstraint?.deactivate()
    
    if stackView.arrangedSubviews.count < 2 {
      stackView.axis = .horizontal
    } else {
      stackView.axis = .vertical
    }
    stackView.addArrangedSubview(button)
  }
}
