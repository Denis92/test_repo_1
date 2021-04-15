//
//  ContractDetailsAdditionalInfoView.swift
//  ForwardLeasing
//

import UIKit

protocol ContractDetailsAdditionalInfoViewModelProtocol: CellHeightCaching {
  var buyoutViewModel: AdditionalInfoDescriptionViewModel { get }
  var returnInfoViewModel: AdditionalInfoDescriptionViewModel { get }
  var warrantyServiceViewModel: WarrantyServiceViewModel { get }
  var onDidRequestLayout: (() -> Void)? { get set }
  var onDidUpdateCellHeight: ((CGFloat) -> Void)? { get set }
}

typealias ContractDetailsAdditionInfoCell = CommonContainerTableViewCell<ContractDetailsAdditionalInfoView>

class ContractDetailsAdditionalInfoView: UIView, Configurable {
  // MARK: - Subviews
  private let buyoutExpandableView = ExpandableView<AdditionalInfoDescriptionView>()
  private let returnInfoExpandableView = ExpandableView<AdditionalInfoDescriptionView>()
  private let warrantyServiceExpandableView = ExpandableView<WarrantyServiceView>()
  
  private let stackView = UIStackView()
  
  // MARK: - Properties
  var cachedHeight: CGFloat?
  
  private var onDidUpdateCellHeight: ((CGFloat) -> Void)?
  private var onDidRequestLayout: (() -> Void)?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let height = systemLayoutSizeFitting(CGSize(width: bounds.width, height: 0)).height
    onDidUpdateCellHeight?(height)
  }
  
  // MARK: - Public Methods
  
  func configure(with viewModel: ContractDetailsAdditionalInfoViewModelProtocol) {
    updateItems(with: viewModel)
    onDidRequestLayout = viewModel.onDidRequestLayout
    onDidUpdateCellHeight = viewModel.onDidUpdateCellHeight
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupStackView()
    setupItems()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupItems() {
    buyoutExpandableView.onNeedsToLayoutSuperview = { [weak self] in
      self?.setNeedsLayout()
      self?.layoutIfNeeded()
      self?.onDidRequestLayout?()
    }
    stackView.addArrangedSubview(buyoutExpandableView)
    
    returnInfoExpandableView.onNeedsToLayoutSuperview = { [weak self] in
      self?.setNeedsLayout()
      self?.layoutIfNeeded()
      self?.onDidRequestLayout?()
    }
    stackView.addArrangedSubview(returnInfoExpandableView)
    
    warrantyServiceExpandableView.onNeedsToLayoutSuperview = { [weak self] in
      self?.setNeedsLayout()
      self?.layoutIfNeeded()
      self?.onDidRequestLayout?()
    }
    stackView.addArrangedSubview(warrantyServiceExpandableView)
  }
  
  private func updateItems(with viewModel: ContractDetailsAdditionalInfoViewModelProtocol) {
    buyoutExpandableView.configure(title: R.string.contractDetails.buyoutTitle(),
                                   viewModel: viewModel.buyoutViewModel)
    returnInfoExpandableView.configure(title: R.string.contractDetails.returnInfoTitle(),
                                       viewModel: viewModel.returnInfoViewModel)
    warrantyServiceExpandableView.configure(title: R.string.contractDetails.warrantyServiceTitle(),
                                            viewModel: viewModel.warrantyServiceViewModel)
  }
}
