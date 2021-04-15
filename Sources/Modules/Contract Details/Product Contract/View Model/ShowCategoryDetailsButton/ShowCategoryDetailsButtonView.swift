//
//  ShowCategoryDetailsButtonView.swift
//  ForwardLeasing
//

import UIKit

class ShowCategoryDetailsButtonView: UIView, Configurable {
  private var viewModel: ShowCategoryDetailsButtonViewModel?
  
  // MARK: - Subviews
  private let button = UIButton(type: .system)
  private let titleLabel = AttributedLabel(textStyle: .title2Regular)
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    button.layer.cornerRadius = button.frame.size.height / 2
  }
  
  // MARK: - Configure
  func configure(with viewModel: ShowCategoryDetailsButtonViewModel) {
    self.viewModel = viewModel
    button.backgroundColor = viewModel.buttonColor
    button.addTarget(self, action: #selector(handleButtonTap(_:)), for: .touchUpInside)
    titleLabel.text = viewModel.title
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupButton()
    setupLabel()
  }

  private func setupButton() {
    addSubview(button)
    button.tintColor = .white
    button.setImage(R.image.allCategoriesButton(), for: .normal)
    button.snp.makeConstraints { make in
      make.size.equalTo(60)
      make.trailing.equalToSuperview().inset(12)
      make.top.equalToSuperview().offset(10)
    }
  }
  
  private func setupLabel() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.centerY.leading.equalToSuperview()
      make.trailing.equalTo(button.snp.leading).offset(5)
      make.top.bottom.equalToSuperview().inset(28)
    }
  }

  @objc private func handleButtonTap(_ sender: UIButton) {
    viewModel?.showCategoryDetails()
  }
}
