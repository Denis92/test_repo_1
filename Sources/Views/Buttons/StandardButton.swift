//
//  StandardButton.swift
//  ForwardLeasing
//

import UIKit

struct StandardButtonConfiguration {
  let style: StandardButtonType
  let title: String?
}

enum StandardButtonType {
  case primary, secondary, outlined, clear
  
  var normalColor: UIColor {
    switch self {
    case .primary:
      return .accent
    case .secondary:
      return .shade20
    case .outlined:
      return .clear
    case .clear:
      return .clear
    }
  }
  
  var highlightColor: UIColor {
    switch self {
    case .primary:
      return .buttonOrangeTapped
    case .secondary:
      return .shade40
    case .outlined:
      return .shade30
    case .clear:
      return .clear
    }
  }
  
  var disabledColor: UIColor {
    switch self {
    case .primary, .secondary, .outlined:
      return .shade30
    case .clear:
      return normalColor
    }
  }
  
  var textColor: UIColor {
    switch self {
    case .primary:
      return .base2
    case .secondary:
      return .base1
    case .outlined:
      return .base1
    case .clear:
      return .accent
    }
  }
  
  var highlightTextColor: UIColor {
    switch self {
    case .clear:
      return .buttonOrangeTapped
    default:
      return textColor
    }
  }
  
  var disabledTextColor: UIColor {
    switch self {
    case .clear:
      return .shade40
    case .primary, .secondary, .outlined:
      return .base2
    }
  }
  
  var activityIndicatorColor: UIColor {
    switch self {
    case .primary:
      return .base2
    case .secondary, .outlined:
      return .base1
    case .clear:
      return .accent
    }
  }
}

class StandardButton: UIButton {
  // MARK: - Public properties
  
  override var intrinsicContentSize: CGSize {
    let width = titleLabel?.text?.size(withAttributes: [.font: titleLabel?.font ?? UIFont()]).width ?? 0
    return CGSize(width: width + 44, height: 56)
  }
  
  override var isHighlighted: Bool {
    didSet {
      configureHighlightedState(isHighlighted: isHighlighted)
    }
  }
  
  override var isEnabled: Bool {
    didSet {
      configureEnabledState(isEnabled: isEnabled)
    }
  }
  
  var actionHandler: (() -> Void)?
  
  // MARK: - Private properties
  
  private(set) var type: StandardButtonType
  private let activityIndicatorView = UIActivityIndicatorView()
  
  // MARK: - Init
  
  init(type: StandardButtonType) {
    self.type = type
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    self.type = .primary
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Public methods
  
  func startAnimating() {
    titleLabel?.alpha = 0
    isUserInteractionEnabled = false
    activityIndicatorView.startAnimating()
  }
  
  func stopAnimating() {
    titleLabel?.alpha = 1
    isUserInteractionEnabled = true
    activityIndicatorView.stopAnimating()
  }
  
  func actionHandler(controlEvents control: UIControl.Event, forAction action: @escaping (() -> Void)) {
    actionHandler = action
    addTarget(self, action: #selector(triggerActionHandler), for: control)
  }
  
  func updateType(_ type: StandardButtonType) {
    self.type = type
    setupAppearance()
  }

  func configure(with configuration: StandardButtonConfiguration) {
    setTitle(configuration.title, for: .normal)
    updateType(configuration.style)
  }
  // MARK: - Setup
  
  private func setup() {
    setupAppearance()
    setupActivityIndicator()
  }
  
  private func setupAppearance() {
    backgroundColor = type.normalColor
    setTitleColor(type.textColor, for: .normal)
    makeRoundedCorners(radius: 28)
    titleLabel?.font = .title2Semibold
    
    if type == .outlined {
      layer.borderWidth = 1
      layer.borderColor = UIColor.base1.cgColor
    }
  }
  
  private func setupActivityIndicator() {
    addSubview(activityIndicatorView)
    
    activityIndicatorView.hidesWhenStopped = true
    activityIndicatorView.color = type.activityIndicatorColor
    
    activityIndicatorView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Private methods
  
  private func configureHighlightedState(isHighlighted: Bool) {
    if isHighlighted {
      backgroundColor = type.highlightColor
      setTitleColor(type.highlightTextColor, for: .normal)
    } else {
      backgroundColor = type.normalColor
      setTitleColor(type.textColor, for: .normal)
    }
  }
  
  private func configureEnabledState(isEnabled: Bool) {
    if isEnabled {
      backgroundColor = type.normalColor
      setTitleColor(type.textColor, for: .normal)
    } else {
      backgroundColor = type.disabledColor
      setTitleColor(type.disabledTextColor, for: .normal)
    }
    
    if type == .outlined {
      layer.borderColor = isEnabled ? UIColor.base1.cgColor : UIColor.shade40.cgColor
    }
  }
  
  // MARK: - Default action
  @objc private func triggerActionHandler() {
    actionHandler?()
  }
}
