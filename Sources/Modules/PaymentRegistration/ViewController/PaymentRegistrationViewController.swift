//
//  PaymentRegistrationViewController.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let itemWidth: CGFloat = 186
  static let itemHeight: CGFloat = 108
  static let itemsSpacing: CGFloat = 16
  static let pickerHorizontalInsets: CGFloat = 51
  static let minPickerItemAlpha: CGFloat = 0.5
  static let periodsBackgroundTopRadius: CGFloat = 17
}

class PaymentRegistrationViewController: BaseViewController {
  // MARK: - Outlets

  @IBOutlet private weak var titleLabel: AttributedLabel! {
    didSet {
      titleLabel.change(textStyle: .h3)
    }
  }
  @IBOutlet private weak var paymentDateLabel: AttributedLabel! {
    didSet {
      paymentDateLabel.change(textStyle: .textBold)
    }
  }
  @IBOutlet private weak var paymentDetailsLabel: AttributedLabel! {
    didSet {
      paymentDetailsLabel.change(textStyle: .footnoteRegular)
    }
  }
  @IBOutlet private weak var payButton: StandardButton!
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var periodsContainerView: UIView!
  @IBOutlet private weak var paymentDetailsContainerView: UIView!
  @IBOutlet private weak var cardsPickerView: PaymentCardPickerView!
  @IBOutlet private weak var scrollView: UIScrollView!

  // MARK: - Views

  private let periodsBackgroundMaskLayer = CAShapeLayer()

  // MARK: - Peoperties

  private let viewModel: PaymentRegistrationViewModel

  private lazy var dataSource: CollectionViewDataSource = {
    let dataSource = CollectionViewDataSource(lineSpacing: Constants.itemsSpacing,
                                              interItemSpacing: Constants.itemsSpacing,
                                              itemSize: CGSize(width: Constants.itemWidth,
                                                               height: Constants.itemHeight))
    return dataSource
  }()
  private let collectionViewFlowLayout = HorizontalPickerCollectionViewFlowLayout()

  // MARK: - Init

  init(viewModel: PaymentRegistrationViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    bindToViewModel()
    setup()
    viewModel.requestCards()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    periodsBackgroundMaskLayer.frame = periodsContainerView.bounds
    periodsContainerView.layer.mask = periodsBackgroundMaskLayer
    updatePeriodsContainerBackground()
    paymentDetailsContainerView.layer.cornerRadius = paymentDetailsContainerView.bounds.height / 2
    scrollView.layoutIfNeeded()
    scrollView.isScrollEnabled = scrollView.contentSize.height > scrollView.bounds.height
  }

  // MARK: - Actions

  @IBAction private func payButtonTapped(_ sender: Any) {
    viewModel.pay()
  }

  @IBAction private func closeButtonTapped(_ sender: Any) {
    viewModel.cancel()
  }

  // MARK: - Private methods

  private func bindToViewModel() {
    titleLabel.text = viewModel.title
    updateSelectedPeriodInfo()
    viewModel.onDidUpdateSelectedPeriods = { [weak self] in
      self?.updateSelectedPeriodInfo()
    }
    
    viewModel.onDidReceiveError = { [weak self] error in
      self?.handle(error: error)
    }
    
    viewModel.onDidStartRequest = { [weak self] in
      self?.payButton.startAnimating()
    }
    
    viewModel.onDidFinishRequest = { [weak self] in
      self?.payButton.stopAnimating()
    }
    
    viewModel.onDidStartUpdateCards = { [weak self] in
      self?.payButton.isEnabled = false
    }
    
    viewModel.onDidFinishUpdateCards = { [weak self] in
      self?.payButton.isEnabled = true
    }
    
    viewModel.onDidReceiveWrongMinimumPayment = { [weak self] description in
      self?.handleMinimumPayment(with: description)
    }
  }

  private func setup() {
    view.backgroundColor = .clear
    periodsContainerView.layer.mask = periodsBackgroundMaskLayer
    configureCollectionView()
    cardsPickerView.configure(with: viewModel.cardsViewModel)
  }
  
  private func configureCollectionView() {
    collectionView.decelerationRate = .fast
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset.left = Constants.pickerHorizontalInsets
    collectionView.contentInset.right = Constants.pickerHorizontalInsets
    collectionView.register(UINib(nibName: PaymentPeriodCell.reuseIdentifier,
                                  bundle: nil),
                            forCellWithReuseIdentifier: PaymentPeriodCell.reuseIdentifier)
    dataSource.setup(collectionView: collectionView,
                     collectionViewLayout: collectionViewFlowLayout,
                     viewModel: viewModel)
    collectionView.delegate = self
  }

  private func updateSelectedPeriodInfo() {
    paymentDetailsLabel.text = viewModel.paymentDetails
    paymentDateLabel.text = viewModel.plannedPaymentDate
    paymentDateLabel.isHidden = viewModel.plannedPaymentDate == nil
    payButton.setTitle(viewModel.payButtonTitle, for: .normal)
  }

  private func updatePeriodsContainerBackground() {
    let bounds = periodsContainerView.bounds
    let curveStartPointY = Constants.periodsBackgroundTopRadius
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: bounds.height))
    path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
    path.addLine(to: CGPoint(x: bounds.width, y: curveStartPointY))
    path.addQuadCurve(to: CGPoint(x: 0, y: curveStartPointY),
                      controlPoint: CGPoint(x: bounds.width / 2, y: 0))
    path.close()
    periodsBackgroundMaskLayer.path = path.cgPath
  }
  
  private func handleMinimumPayment(with description: String) {
    showAlert(withTitle: R.string.common.error(), message: description)
  }
}

extension PaymentRegistrationViewController: UICollectionViewDelegate, UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    updatePickerItemsVisibility()
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    updatePickerItemsVisibility()
    didEndScrolling()
  }

  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    updatePickerItemsVisibility()
    didEndScrolling()
  }

  func collectionView(_ collectionView: UICollectionView,
                      willDisplay cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath) {
    updateVisibilityAttributes(for: cell)
  }

  private func updatePickerItemsVisibility() {
    collectionView.visibleCells.forEach {
      updateVisibilityAttributes(for: $0)
    }
  }

  private func updateVisibilityAttributes(for cell: UICollectionViewCell) {
    let collectionCenterX = collectionView.center.x
    let cellCenterX = collectionView.convert(cell.center, to: collectionView.superview).x
    let offset = abs(collectionCenterX - cellCenterX)
    let halfWidth = Constants.itemWidth / 2
    let halfSpacing = Constants.itemsSpacing / 2
    cell.alpha = min(max(Constants.minPickerItemAlpha, 1 - (offset / (halfWidth + halfSpacing))), 1)
  }

  private func didEndScrolling() {
    let centerCell = collectionView.visibleCells.first {
      let cellFrame = collectionView.convert($0.frame, to: collectionView.superview)
      return cellFrame.contains(collectionView.center)
    }
    guard let cell = centerCell, let indexPath = collectionView.indexPath(for: cell) else { return }
    viewModel.selectPeriod(atIndex: indexPath.item)
  }
}
