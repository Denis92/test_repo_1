//
//  ProductButtonsView.swift
//  ForwardLeasing
//

import UIKit

enum ProductButtonAction {
  case `continue`
  case cancelApplication
  case cancelUpgradeApplication
  case cancelReturnApplication
  case checkStatus
  case signСontract
  case cancelContract
  case selectDeliveryType
  case pickupWithStorePoint
  case pickupWithoutStorePoint
  case signDelivery
  case cancelDelivery
  case pay
  case upgrade
  case `return`
  case buyAgain
  
  var title: String {
    switch self {
    case .continue:
      return R.string.productCard.buttonContinueTitle()
    case .cancelApplication:
      return R.string.productCard.buttonCancelApplicationTitle()
    case .cancelUpgradeApplication:
      return R.string.productCard.buttonCancelUpgradeTitle()
    case .cancelReturnApplication:
      return R.string.productCard.buttonCancelReturnTitle()
    case .checkStatus:
      return R.string.productCard.buttonCheckStatusTitle()
    case .signСontract:
      return R.string.productCard.buttonSignContractTitle()
    case .cancelContract:
      return R.string.productCard.buttonCancelContractTitle()
    case .selectDeliveryType:
      return R.string.productCard.buttonDeliveryTypeTitle()
    case .pickupWithStorePoint:
      return R.string.productCard.buttonDeliveryTypePickupWithStorePointTitle()
    case .pickupWithoutStorePoint:
      return R.string.productCard.buttonDeliveryTypePickupWithoutStorePointTitle()
    case .signDelivery:
      return R.string.productCard.buttonSignDeliveryTitle()
    case .cancelDelivery:
      return R.string.productCard.buttonCancelDeliveryTitle()
    case .pay:
      return R.string.productCard.buttonPayTitle()
    case .upgrade:
      return R.string.productCard.buttonUpgradeTitle()
    case .return:
      return R.string.productCard.buttonReturnTitle()
    case .buyAgain:
      return R.string.productCard.buttonBuyAgainTitle()
    }
  }

  var type: StandardButtonType {
    switch self {
    case .cancelApplication, .cancelUpgradeApplication, .cancelReturnApplication,
         .cancelContract, .cancelDelivery:
      return .secondary
    default:
      return .primary
    }
  }
}

protocol ProductButtonsViewModelProtocol: class {
  var buttonsActions: [ProductButtonAction] { get }
  
  func select(action: ProductButtonAction)
}

class ProductButtonsView: UIView {
  // MARK: - Properties
  private let containerStackView = UIStackView()

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  func configure(with viewModel: ProductButtonsViewModelProtocol) {
    containerStackView.arrangedSubviews.forEach {
      $0.removeFromSuperview()
    }
    for action in viewModel.buttonsActions {
      let button = StandardButton(type: action.type)
      button.actionHandler(controlEvents: .touchUpInside) { [weak viewModel] in
        viewModel?.select(action: action)
      }
      button.setTitle(action.title, for: .normal)
      containerStackView.addArrangedSubview(button)
    }
  }

  // MARK: - Private methods
  private func setup() {
    setupContainerStackView()
  }

  private func setupContainerStackView() {
    addSubview(containerStackView)
    containerStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    containerStackView.axis = .vertical
    containerStackView.spacing = 16
  }
}

// MARK: - StackViewItemView
extension ProductButtonsView: StackViewItemView {
  func configure(with viewModel: StackViewItemViewModel) {
    guard let viewModel = viewModel as? ProductButtonsViewModelProtocol else {
      return
    }
    configure(with: viewModel)
  }
}
