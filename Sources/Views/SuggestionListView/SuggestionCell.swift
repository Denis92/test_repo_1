//
//  SuggestionCell.swift
//  ForwardLeasing
//

import UIKit

class SuggestionCell: UITableViewCell, CommonTableCell, Configurable {
  // MARK: - Properties
  
  private let containerView = UIView()
  private let stackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .textRegular)
  private let separatorView = UIView()
  
  private var needsTopCornersRadius = false
  private var needsBottomCornersRadius = false
  
  // MARK: - Init
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func prepareForReuse() {
    super.prepareForReuse()
    needsTopCornersRadius = false
    containerView.layer.cornerRadius = 0
    titleLabel.text = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    containerView.makeRoundedCorners(radius: 8)
  }
  
  // MARK: - Configure
  func configure(with viewModel: CommonTableCellViewModel) {
    guard let viewModel = viewModel as? SuggestionCellViewModel else { return }
    titleLabel.text = viewModel.title
    needsTopCornersRadius = viewModel.isFirst
    needsBottomCornersRadius = viewModel.isLast
    separatorView.isHidden = viewModel.isLast
  }
  
  // MARK: - Private methods
  
  private func setup() {
    contentView.backgroundColor = .base2
    setupContainerView()
    setupStackView()
    setupTitleLabel()
    setupSeparatorView()
  }
  
  private func setupContainerView() {
    contentView.addSubview(containerView)
    
    containerView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  private func setupStackView() {
    stackView.axis = .vertical
    stackView.spacing = 2
    containerView.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(16)
    }
  }
  
  private func setupTitleLabel() {
    titleLabel.numberOfLines = 0
    stackView.addArrangedSubview(titleLabel)
  }
  
  private func setupSeparatorView() {
    separatorView.backgroundColor = .shade30
    containerView.addSubview(separatorView)
    
    separatorView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(16)
      make.bottom.trailing.equalToSuperview()
      make.height.equalTo(1)
    }
  }
}
