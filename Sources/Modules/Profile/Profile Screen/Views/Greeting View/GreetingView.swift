//
//  GreetingView.swift
//  ForwardLeasing
//

import UIKit

class GreetingView: UIView {
  // MARK: - Properties
  var name: String = "" {
    didSet {
      updateGreetingLabel()
    }
  }

  var onDidTapSettingsButton: (() -> Void)?
  
  private let greetingLabel = AttributedLabel(textStyle: .title1Bold)
  private let settingsButton = UIButton(type: .system)

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions
  @objc private func settingsButtonTapped() {
    onDidTapSettingsButton?()
  }
  
  // MARK: - Private methods
  private func setup() {
    addSettingsButton()
    addGreetingLabel()
  }
  
  private func addSettingsButton() {
    addSubview(settingsButton)
    settingsButton.setImage(R.image.gearIcon()?.withRenderingMode(.alwaysOriginal), for: .normal)
    settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
    settingsButton.snp.makeConstraints { make in
      make.size.equalTo(40)
      make.top.equalToSuperview().inset(24)
      make.trailing.equalToSuperview().inset(10)
    }
  }

  private func addGreetingLabel() {
    addSubview(greetingLabel)
    greetingLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.trailing.equalTo(settingsButton.snp.leading).offset(-16)
      make.top.bottom.equalToSuperview().inset(24)
    }
    greetingLabel.numberOfLines = 2
    greetingLabel.textColor = .base2
    updateGreetingLabel()
  }

  private func updateGreetingLabel() {
    greetingLabel.text = R.string.profile.greetingLabelTitle(name)
    greetingLabel.isHidden = name.isEmpty
  }
}
