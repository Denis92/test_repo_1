//
//  TimerView.swift
//  TestFeatures
//

import UIKit

class TimerView: UIView, Configurable {
  // MARK: - Subviews
  private let countdownLabel = AttributedLabel(textStyle: .title1Bold)
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let subtitleLabel = AttributedLabel(textStyle: .textRegular)
  private let ringView = RingView()
  
  // MARK: - Properties
  var color: UIColor = .accent {
    didSet {
      setNeedsDisplay()
    }
  }
  
  var width: CGFloat = 8 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  private var halfSize: CGFloat {
    return min(bounds.size.width / 2, bounds.size.height / 2) / 2
  }
  
  private var fraction: CGFloat = 0
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with viewModel: TimerViewModel) {
    titleLabel.text = viewModel.title
    subtitleLabel.text = viewModel.subtitle
    viewModel.onDidCountdownUpdate = { [weak self, weak viewModel] in
      guard let self = self, let viewModel = viewModel else { return }
      self.update(with: viewModel)
    }
  }
    
  // MARK: - Setup views
  private func setup() {
    setupRingView()
    setupCountdownLabel()
    setupTitleLabel()
    setupSubtitleLabel()
  }
  
  private func update(with viewModel: TimerViewModel) {
    countdownLabel.text = viewModel.totalTimeFormattedString
    ringView.fraction = viewModel.fraction
  }
  
  private func setupRingView() {
    addSubview(ringView)
    ringView.strokeColor = .accent
    ringView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(100)
      make.width.greaterThanOrEqualTo(100)
      make.height.equalTo(ringView.snp.width)
    }
  }
  
  private func updateTimerLabel(duration: TimeInterval) {
    countdownLabel.text = duration.description
  }
  
  private func setupCountdownLabel() {
    addSubview(countdownLabel)
    countdownLabel.textAlignment = .center
    countdownLabel.snp.makeConstraints { make in
      make.center.equalTo(ringView)
    }
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(ringView.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupSubtitleLabel() {
    addSubview(subtitleLabel)
    subtitleLabel.textAlignment = .center
    subtitleLabel.numberOfLines = 0
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
}
