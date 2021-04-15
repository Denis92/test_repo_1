//
//  SelectableListItemView.swift
//  ForwardLeasing
//

import UIKit

protocol SelectableItemListViewModelProtocol: class {
  var title: String? { get }
  var isSelected: Bool { get }
  var textColor: UIColor { get }

  var onDidUpdate: (() -> Void)? { get set }

  func didTap()
}

class SelectableListItemView: UIView, Configurable {
  private var viewModel: SelectableItemListViewModelProtocol?
  
  private let titleLabel = AttributedLabel(textStyle: .title2Regular)
  private let checkImageView = UIImageView()
  
  // MARK: - Init
  init(addGestureRecognizer: Bool) {
    super.init(frame: .zero)
    setup(addGestureRecognizer: addGestureRecognizer)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup(addGestureRecognizer: false)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with viewModel: SelectableItemListViewModelProtocol) {
    self.viewModel = viewModel
    
    titleLabel.text = viewModel.title
    titleLabel.textColor = viewModel.isSelected ? .accent : viewModel.textColor
    checkImageView.isHidden = !viewModel.isSelected
    
    viewModel.onDidUpdate = { [weak self] in
      self?.titleLabel.textColor = viewModel.isSelected ? .accent : viewModel.textColor
      self?.checkImageView.isHidden = !viewModel.isSelected
    }
  }
  
  // MARK: - Actions
  @objc private func didTapView() {
    viewModel?.didTap()
  }
  
  // MARK: - Setup
  private func setup(addGestureRecognizer: Bool) {
    setupContainer(addGestureRecognizer: addGestureRecognizer)
    setupTitle()
    setupCheckImage()
  }
  
  private func setupContainer(addGestureRecognizer: Bool) {
    if addGestureRecognizer {
      self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    snp.makeConstraints { make in
      make.height.equalTo(56)
    }
  }
  
  private func setupTitle() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.centerY.equalToSuperview()
    }
  }
  
  private func setupCheckImage() {
    addSubview(checkImageView)
    checkImageView.image = R.image.checkmarkSelected()
    checkImageView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(20)
      make.leading.equalTo(titleLabel.snp.trailing)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(24)
    }
  }
}
