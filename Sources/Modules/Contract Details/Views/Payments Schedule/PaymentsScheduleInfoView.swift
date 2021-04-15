//
//  PaymentsScheduleInfoView.swift
//  ForwardLeasing
//

import UIKit

class PaymentsScheduleInfoView: UIView {
  // MARK: - Properties
  
  private let infoLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(infoLabel)
    infoLabel.numberOfLines = 0
    infoLabel.text = R.string.contractDetails.paymentsScheduleInfoText()
    infoLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10)
      make.top.bottom.equalToSuperview().inset(9)
    }
  }
}
