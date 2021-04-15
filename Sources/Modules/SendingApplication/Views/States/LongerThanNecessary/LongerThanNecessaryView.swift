//
//  LongerThanNecessaryView.swift
//  ForwardLeasing
//

import UIKit

class LongerThanNecessaryView: UIView, Configurable {
  // MARK: - Subviews
  private let dotsStackView = UIStackView()
  private let buttonsStackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let subtitleLabel = AttributedLabel(textStyle: .textRegular)
  private let checkLaterButton = StandardButton(type: .primary)
  private let cancelApplicationButton = StandardButton(type: .clear)
  
  // MARK: - Properties
  private var onDidTapCheckLater: (() -> Void)?
  private var onDidTapCancel: (() -> Void)?
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with viewModel: LongerThanNecessaryViewModel) {
    bind(with: viewModel)
    update(with: viewModel)
  }
  
  // MARK: - Private
  private func bind(with viewModel: LongerThanNecessaryViewModel) {
    viewModel.onDidUpdate = { [weak viewModel, weak self] in
      guard let viewModel = viewModel else { return }
      self?.update(with: viewModel)
    }
    onDidTapCancel = { [weak viewModel] in
      viewModel?.didTapCancel()
    }
    onDidTapCheckLater = { [weak viewModel] in
      viewModel?.didTapCheckLater()
    }
  }
  
  private func update(with viewModel: LongerThanNecessaryViewModel) {
    checkLaterButton.isHidden = viewModel.isAlmostDone
    cancelApplicationButton.isHidden = viewModel.isAlmostDone
    titleLabel.text = viewModel.title
    subtitleLabel.text = viewModel.subtitle
  }
  
  private func setup() {
    setupTitleLabel()
    setupDotsStackView()
    setupSubtitleLabel()
    setupCancelApplicationButton()
    setupCheckLaterButton()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.text = R.string.sendingApplication.longerThanNecessaryViewTitle()
    titleLabel.textAlignment = .center
    titleLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(51)
    }
  }
  
  private func setupDotsStackView() {
    addSubview(dotsStackView)
    dotsStackView.spacing = 15
    for _ in 0..<3 {
      let singleDot = UIView()
      singleDot.layer.cornerRadius = 6
      singleDot.layer.masksToBounds = true
      singleDot.backgroundColor = .accent
      singleDot.snp.makeConstraints { make in
        make.size.equalTo(12)
      }
      dotsStackView.addArrangedSubview(singleDot)
    }
    
    dotsStackView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(titleLabel.snp.top).offset(-32)
    }
  }
  
  private func setupSubtitleLabel() {
    addSubview(subtitleLabel)
    subtitleLabel.numberOfLines = 0
    subtitleLabel.text = R.string.sendingApplication.longerThanNecessaryViewSubTitle()
    subtitleLabel.textAlignment = .center
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(51)
    }
  }
  
  private func setupCheckLaterButton() {
    addSubview(checkLaterButton)
    checkLaterButton.setTitle(R.string.sendingApplication.longerThanNecessaryViewButtonTryLater(), for: .normal)
    checkLaterButton.addTarget(self, action: #selector(didTapCheckLater), for: .touchUpInside)
    checkLaterButton.snp.makeConstraints { make in
      make.height.equalTo(56)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalTo(cancelApplicationButton.snp.top).offset(-28)
    }
  }
  
  private func setupCancelApplicationButton() {
    addSubview(cancelApplicationButton)
    cancelApplicationButton.setTitle(R.string.sendingApplication.longerThanNecessaryViewButtonCancelButton(), for: .normal)
    cancelApplicationButton.setTitleColor(.accent, for: .normal)
    cancelApplicationButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
    cancelApplicationButton.snp.makeConstraints { make in
      make.height.equalTo(56)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().offset(-52)
    }
  }
  
  // MARK: - Actions
  @objc private func didTapCheckLater() {
    onDidTapCheckLater?()
  }
  
  @objc private func didTapCancel() {
    onDidTapCancel?()
  }
}
