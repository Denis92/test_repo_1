//
//  ExpandableHeaderView.swift
//  ForwardLeasing
//

import UIKit

class ExpandableHeaderView: UIView {
  // MARK: - Private properties
  
  var isDividerHidden: Bool = false {
    didSet {
      dividerView.isHidden = isDividerHidden
    }
  }
  
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let iconContainerView = UIView()
  private let iconFirstLine = UIView()
  private let iconSecondLine = UIView()
  private let dividerView = UIView()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(withTitle title: String?) {
    titleLabel.text = title
  }
  
  // MARK: - Public methods
  
  func updateState(isExpanded: Bool, animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.3, animations: {
        self.iconFirstLine.transform = CGAffineTransform(rotationAngle: isExpanded ? -0.999 * CGFloat.pi : -CGFloat.pi * 0.5)
        self.iconSecondLine.transform = CGAffineTransform(rotationAngle: -0.999 * CGFloat.pi)
      }, completion: { _ in
        self.setIconState(isExpanded: isExpanded)
      })
    } else {
      self.setIconState(isExpanded: isExpanded)
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupTitle()
    setupIcon()
    setupDividerView()
  }
  
  private func setupTitle() {
    addSubview(titleLabel)
    
    titleLabel.textColor = .base1
    titleLabel.numberOfLines = 0
    
    titleLabel.snp.makeConstraints { make in
      make.leading.top.bottom.equalToSuperview().inset(20)
    }
  }
  
  private func setupIcon() {
    addSubview(iconContainerView)
    iconContainerView.snp.makeConstraints { make in
      make.width.height.equalTo(24)
      make.leading.equalTo(titleLabel.snp.trailing).offset(10)
      make.trailing.equalToSuperview().inset(20)
      make.centerY.equalToSuperview()
    }
    
    [iconFirstLine, iconSecondLine].forEach { view in
      iconContainerView.addSubview(view)
      view.backgroundColor = .base1
      view.snp.makeConstraints { make in
        make.width.equalTo(16)
        make.height.equalTo(4)
        make.center.equalToSuperview()
      }
    }
  }
  
  private func setupDividerView() {
    addSubview(dividerView)
    dividerView.backgroundColor = .shade40
    dividerView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(0.5)
    }
  }
  
  // MARK: - Private methods
  
  private func setIconState(isExpanded: Bool) {
    self.iconFirstLine.transform = CGAffineTransform(rotationAngle: isExpanded ? 0 : -CGFloat.pi * 0.5)
    self.iconSecondLine.transform = CGAffineTransform(rotationAngle: 0)
  }
}
