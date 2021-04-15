//
//  PaymentsScheduleView.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

private extension Constants {
  static let backdropItemHeight: CGFloat = 8
  static let backdropItemsCount = 2
}

typealias PaymentsScheduleCell = CommonContainerTableViewCell<PaymentsScheduleView>

class PaymentsScheduleView: UIView, Configurable {
  // MARK: - Properties
  
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let backdropView = makeBackdropView(itemsCount: Constants.backdropItemsCount)
  private let scheduleContainerView = UIView()
  private let scheduleStackView = UIStackView()
  private let exchangeView = PaymentsScheduleExchangeView()
  private let scheduleInfoView = PaymentsScheduleInfoView()
  private let remainingPaymentsLabel = AttributedLabel(textStyle: .textRegular)
  
  private var isCollapsed = true
  private var hasSetInitialState = false
  private var scheduleContainerTopConstraint: Constraint?
  private var viewModel: PaymentScheduleViewModel?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  
  func configure(with viewModel: PaymentScheduleViewModel) {
    self.viewModel = viewModel
    
    remainingPaymentsLabel.text = viewModel.remainingPaymentsTitle
    exchangeView.price = viewModel.exchangePrice
    
    scheduleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    viewModel.itemViewModels.forEach { itemViewModel in
      let itemView = PaymentsScheduleItemView()
      itemView.configure(with: itemViewModel)
      scheduleStackView.addArrangedSubview(itemView)
    }
    scheduleStackView.addArrangedSubview(scheduleInfoView)
    
    updateState(animated: false)
  }
  
  // MARK: - Actions
  
  @objc private func didTapView() {
    toggleScheduleState()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupTitleLabel()
    setupBackdropView()
    setupScheduleContainerView()
    setupScheduleStackView()
    setupRemainingPaymentsLabel()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.text = R.string.contractDetails.paymentsScheduleTitle()
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupBackdropView() {
    addSubview(backdropView)
    backdropView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupScheduleContainerView() {
    addSubview(scheduleContainerView)
    scheduleContainerView.backgroundColor = .shade20
    scheduleContainerView.layer.cornerRadius = 12
    scheduleContainerView.clipsToBounds = true
    scheduleContainerView.snp.makeConstraints { make in
      scheduleContainerTopConstraint = make.top.equalTo(titleLabel.snp.bottom)
        .offset(CGFloat(16) + Constants.backdropItemHeight * CGFloat(Constants.backdropItemsCount)).constraint
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupScheduleStackView() {
    scheduleContainerView.addSubview(scheduleStackView)
    scheduleStackView.axis = .vertical
    scheduleStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    scheduleStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupRemainingPaymentsLabel() {
    addSubview(remainingPaymentsLabel)
    remainingPaymentsLabel.numberOfLines = 0
    remainingPaymentsLabel.snp.makeConstraints { make in
      make.top.equalTo(scheduleContainerView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
    }
  }
  
  // MARK: - Private methods
  
  private static func makeBackdropView(itemsCount: Int) -> UIView {
    let containerView = UIView()
    containerView.snp.makeConstraints { make in
      make.height.equalTo(CGFloat(itemsCount) * Constants.backdropItemHeight)
    }
    
    for index in 0..<itemsCount {
      let itemView = UIView()
      itemView.backgroundColor = UIColor.shade20.withAlphaComponent(0.7 - CGFloat(index) * 0.2)
      itemView.makeRoundedCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 12)
      containerView.addSubview(itemView)
      itemView.snp.makeConstraints { make in
        make.bottom.equalToSuperview().inset(CGFloat(index) * Constants.backdropItemHeight)
        make.leading.trailing.equalToSuperview().inset(10 + CGFloat(index) * 10)
        make.height.equalTo(Constants.backdropItemHeight)
      }
    }
    
    return containerView
  }
  
  private func toggleScheduleState() {
    isCollapsed.toggle()
    updateState()
  }
  
  private func updateState(animated: Bool = true) {
    scheduleInfoView.isHidden = isCollapsed
    
    if isCollapsed {
      setCollapsedState()
    } else {
      setExpandedState()
    }
    
    if animated {
      UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
        self.viewModel?.layoutSuperview()
      }, completion: nil)
    } else {
      self.viewModel?.layoutSuperview()
    }
  }
  
  private func setCollapsedState() {
    exchangeView.removeFromSuperview()
    
    let firstPaymentItemIndex = viewModel?.firstPaymentItemIndex ?? 0
    let secondPaymentItemIndex = viewModel?.secondPaymentItemIndex ?? 1
    
    guard let firstPaymentItemView = scheduleStackView.arrangedSubviews.element(at: firstPaymentItemIndex)
            as? PaymentsScheduleItemView, let secondPaymentItemView = scheduleStackView.arrangedSubviews
              .element(at: secondPaymentItemIndex) as? PaymentsScheduleItemView else { return }
    
    let stackViewHeight: CGFloat = scheduleStackView.arrangedSubviews.reduce(0) { result, item in
      guard let item = item as? PaymentsScheduleItemView else { return result }
      return result + item.estimatedSize.height
    }
    
    scheduleContainerTopConstraint?.update(offset: CGFloat(16) + CGFloat(Constants.backdropItemsCount)
                                            * Constants.backdropItemHeight)
    
    var firstPaymentItemViewPositionY: CGFloat = 0
    for index in 0..<firstPaymentItemIndex {
      firstPaymentItemViewPositionY += (scheduleStackView.arrangedSubviews.element(at: index) as? PaymentsScheduleItemView)?
        .estimatedSize.height ?? 0
    }
    
    let secondPaymentItemViewPositionY = firstPaymentItemViewPositionY + firstPaymentItemView.estimatedSize.height
    
    scheduleStackView.snp.remakeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(-firstPaymentItemViewPositionY)
      make.bottom.equalToSuperview().offset(stackViewHeight - secondPaymentItemViewPositionY
                                              - secondPaymentItemView.estimatedSize.height)
    }
    
    backdropView.subviews.enumerated().forEach { index, item in
      item.snp.remakeConstraints { make in
        make.bottom.equalToSuperview().inset(CGFloat(index) * Constants.backdropItemHeight)
        make.leading.trailing.equalToSuperview().inset(10 + CGFloat(index) * 10)
        make.height.equalTo(Constants.backdropItemHeight)
      }
    }
  }
  
  private func setExpandedState() {
    if let index = viewModel?.exchangeIndex {
      scheduleStackView.insertArrangedSubview(exchangeView, at: index)
    }
    
    scheduleContainerTopConstraint?.update(offset: 16)
    scheduleStackView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
    }
    backdropView.subviews.forEach { item in
      item.snp.remakeConstraints { make in
        make.leading.trailing.equalToSuperview()
        make.top.equalToSuperview()
        make.height.equalTo(Constants.backdropItemHeight)
      }
    }
  }
}
