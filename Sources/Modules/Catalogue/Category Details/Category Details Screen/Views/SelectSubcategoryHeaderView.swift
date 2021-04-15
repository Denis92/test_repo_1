//
//  SelectSubcategoryHeaderView.swift
//  ForwardLeasing
//

import UIKit

protocol SelectSubcategoryHeaderViewModelProtocol: class {
  var selectedSubcategoryTitle: String? { get }
  
  var onDidUpdateSelectedSubcategoryTitle: ((String?) -> Void)? { get set }
  
  func selectSubcategory()
}

class SelectSubcategoryHeaderView: UIView, Configurable {
  private let subcategoryLabel = AttributedLabel(textStyle: .title2Regular)
  private let downwardChevronImageView = UIImageView(image: R.image.dropdownIndicatorIcon()?.withRenderingMode(.alwaysTemplate))
  private let containerView = UIView()
  private let overlayButton = HighlightableButton()
  
  private var viewModel: SelectSubcategoryHeaderViewModelProtocol?
  
  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: SelectSubcategoryHeaderViewModelProtocol) {
    self.viewModel = viewModel
    subcategoryLabel.text = viewModel.selectedSubcategoryTitle
    viewModel.onDidUpdateSelectedSubcategoryTitle = { [weak self] title in
      self?.subcategoryLabel.text = title
    }
  }

  // MARK: - Setup

  private func setup() {
    addContainerView()
    addSubcategoryLabel()
    addDownwardChevronImageView()
    addOverlayButton()
  }
  
  private func addContainerView() {
    addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(16)
      make.bottom.equalToSuperview().inset(14)
    }
  }
  
  private func addSubcategoryLabel() {
    containerView.addSubview(subcategoryLabel)
    subcategoryLabel.snp.makeConstraints { make in
      make.leading.top.bottom.equalToSuperview()
    }
    subcategoryLabel.textColor = .base2
  }
  
  private func addDownwardChevronImageView() {
    containerView.addSubview(downwardChevronImageView)
    downwardChevronImageView.snp.makeConstraints { make in
      make.centerY.trailing.equalToSuperview()
      make.leading.equalTo(subcategoryLabel.snp.trailing).offset(2)
    }
    downwardChevronImageView.tintColor = .base2
  }
  
  private func addOverlayButton() {
    addSubview(overlayButton)
    overlayButton.addTarget(self, action: #selector(handleButtonTapped(_:)), for: .touchUpInside)
    overlayButton.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    overlayButton.onHighlightedChanged = { [weak self] isHighlighted in
      self?.downwardChevronImageView.tintColor = isHighlighted ? .shade60 : .base2
      self?.subcategoryLabel.textColor = isHighlighted ? .shade60  : .base2
    }
  }
  
  // MARK: - Action
  
  @objc private func handleButtonTapped(_ sender: UIButton) {
    viewModel?.selectSubcategory()
  }
}
