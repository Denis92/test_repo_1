//
//  ProductPropertyPickerItemView.swift
//  ForwardLeasing
//

import UIKit

protocol ProductPropertyPickerItemViewModelProtocol: class {
  var title: String? { get }
  var isEnabled: Bool { get }
  var isSelected: Bool { get }
  var onDidUpdate: (() -> Void)? { get set }

  func toggleSelectionStateByTap()
}

enum ProductPropertyPickersSelectionStyle {
  case outlined, filled
}

private extension Constants {
  static let titleSideInsets: CGFloat = 24
  static let titleTopBottomInset: CGFloat = 16
}

class ProductPropertyPickerItemView: UIView, EstimatedSizeHaving {
  // MARK: - Properties

  var estimatedSize: CGSize {
    let titleWidth = viewModel?.title?.width(forContainerHeight: TextStyle.title2Regular.lineHeight,
                                             textStyle: .title2Regular) ?? 0
    return CGSize(width: max(titleWidth + (Constants.titleSideInsets * 2), 80), height: 56)
  }
  
  var textColor: UIColor = .shade70 {
    didSet {
      titleLabel.textColor = textColor
    }
  }

  var isEnabled: Bool = true {
    didSet {
      titleLabel.textColor = isEnabled ? .shade70 : .shade40
      if !isEnabled {
        layer.borderColor = UIColor.shade40.cgColor
      }
    }
  }

  override var intrinsicContentSize: CGSize {
    let labelSize = titleLabel.intrinsicContentSize
    return CGSize(width: labelSize.width + 2 * Constants.titleSideInsets,
                  height: labelSize.height + 2 * Constants.titleTopBottomInset)
  }

  private let selectionStyle: ProductPropertyPickersSelectionStyle
  private let titleLabel = AttributedLabel(textStyle: .title2Regular)
  private var viewModel: ProductPropertyPickerItemViewModelProtocol?
  
  // MARK: - Init
  
  init(selectionStyle: ProductPropertyPickersSelectionStyle = .outlined) {
    self.selectionStyle = selectionStyle
    super.init(frame: .zero)
    setup()
  }

  override init(frame: CGRect) {
    selectionStyle = .outlined
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ProductPropertyPickerItemViewModelProtocol) {
    self.viewModel = viewModel
    titleLabel.text = viewModel.title

    isEnabled = viewModel.isEnabled
    setSelected(viewModel.isSelected)
    
    viewModel.onDidUpdate = { [weak self] in
      self?.isEnabled = viewModel.isEnabled
      self?.setSelected(viewModel.isSelected)
    }
  }
  
  // MARK: - Public methods
  
  func setSelected(_ isSelected: Bool) {
    guard isEnabled else { return }
    layer.borderColor = isSelected ? UIColor.accent.cgColor : UIColor.shade40.cgColor
    if selectionStyle == .filled {
      textColor = isSelected ? .base2 : .shade70
      backgroundColor = isSelected ? .accent : .clear
    }
  }
  
  // MARK: - Actions
  
  @objc private func handleTap() {
    viewModel?.toggleSelectionStateByTap()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupTitle()
  }
  
  private func setupContainer() {
    makeRoundedCorners(radius: 28)
    layer.borderColor = UIColor.shade40.cgColor
    layer.borderWidth = 1
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(80)
    }
  }
  
  private func setupTitle() {
    addSubview(titleLabel)
    titleLabel.textColor = textColor
    titleLabel.textAlignment = .center
    titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(Constants.titleSideInsets)
      make.top.bottom.equalToSuperview().inset(Constants.titleTopBottomInset)
    }
  }
}
