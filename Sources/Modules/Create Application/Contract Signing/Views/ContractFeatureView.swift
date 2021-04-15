//
//  ContractFeatureView.swift
//  ForwardLeasing
//

import UIKit

class ContractFeatureView: UIView, Configurable {
  // MARK: - Properties
  
  private let stackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .textRegular)
  private let valueLabel = AttributedLabel(textStyle: .textBold)
  private let strokeLayer = CAShapeLayer()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    strokeLayer.frame = bounds
    strokeLayer.path = makeStrokePath().cgPath
  }
  
  // MARK: - Init
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ContractSigningFeatureViewModel) {
    titleLabel.text = viewModel.title
    valueLabel.text = viewModel.value
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupStackView()
    setupTitleLabel()
    setupValueLabel()
    setupStroke()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.bottom.equalToSuperview().inset(12)
    }
  }
  
  private func setupTitleLabel() {
    stackView.addArrangedSubview(titleLabel)
    titleLabel.textColor = .shade70
    titleLabel.numberOfLines = 0
  }
  
  private func setupValueLabel() {
    stackView.addArrangedSubview(valueLabel)
    valueLabel.textColor = .base1
    valueLabel.numberOfLines = 0
  }
  
  private func setupStroke() {
    strokeLayer.strokeColor = UIColor.shade40.cgColor
    strokeLayer.lineDashPattern = [2, 2]
    strokeLayer.fillColor = nil
    layer.addSublayer(strokeLayer)
  }
  
  // MARK: - Private methods
  
  private func makeStrokePath() -> UIBezierPath {
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: bounds.height))
    path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
    return path
  }
}
