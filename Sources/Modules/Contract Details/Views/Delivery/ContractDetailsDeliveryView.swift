//
//  ContractDetailsDeliveryView.swift
//  ForwardLeasing
//

import UIKit

typealias ContractDetailsDeliveryCell = CommonContainerTableViewCell<ContractDetailsDeliveryView>

protocol ContractDetailsDeliveryViewModelProtocol: class {
  var shouldShowStatusOfDelivery: Bool { get }
  var statusOfDeliveryViewModel: StatusOfDeliveryViewModel { get }
}

class ContractDetailsDeliveryView: UIView, Configurable {
  // MARK: - Outlets
  private let stackView = UIStackView()
  private let statusOfDeliveryView = StatusOfDeliveryView()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Public Methods
  func configure(with viewModel: ContractDetailsDeliveryViewModelProtocol) {
    statusOfDeliveryView.configure(with: viewModel.statusOfDeliveryViewModel)
    statusOfDeliveryView.isHidden = !viewModel.shouldShowStatusOfDelivery
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupStackView()
    setupStatusOfDeliveryView()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
    }
  }
  
  private func setupStatusOfDeliveryView() {
    stackView.addArrangedSubview(statusOfDeliveryView)
  }
}
