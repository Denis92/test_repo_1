//
//  ProductDetailsViewController.swift
//  ForwardLeasing
//

import UIKit

protocol ProductDetailsViewControllerDelegate: class {
  func productDetailsViewControllerDidFinish(_ viewController: ProductDetailsViewController)
}

class ProductDetailsViewController: BaseViewController, NavigationBarHiding,
                                    RoundedNavigationBarHaving, ActivityIndicatorViewDisplaying,
                                    ErrorEmptyViewDisplaying, ViewModelBinding {
  // MARK: - Properties
  
  weak var delegate: ProductDetailsViewControllerDelegate?
  
  var scrollViewLastOffset: CGFloat = 0
  
  let scrollView = UIScrollView()
  let navigationBarView = NavigationBarView(type: .titleWithoutContent)
  let activityIndicatorView = ActivityIndicatorView(color: .accent)
  let errorEmptyView = ErrorEmptyView()

  private let viewModel: ProductDetailsViewModel
  
  private let stackView = UIStackView()
  private let imageCarouselView = ProductImageCarouselView()
  private let colorPickerView = ProductColorPickerView()
  private let memoryPickerView = ProductPropertyPickerView()
  private let paymentsCountPickerView = ProductPropertyPickerView()
  private let deliveryTypePickerView = ProductPropertyPickerView()
  private let programPickerView = ProductProgramPickerView()
  private let monthlyPaymnentView = ProductMonthlyPaymentView()
  private let advantagesView = ProductAdvantagesView()
  private let featuresView = ExpandableView<ProductFeaturesView>(withDivider: false)
  private let fullFeaturesView = ExpandableView<ProductFullFeaturesView>(withDivider: false)
  private let productInfoStackView = UIStackView()
  private let makeOrderButton = StandardButton(type: .secondary)
  private let buttonContainerView = UIView()
  
  private var updatedContentOffset = false
  private var updateTitle: ((_ title: String?) -> Void)?
  
  // MARK: - Init
  
  init(viewModel: ProductDetailsViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindToViewModel()
    viewModel.loadData()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !updatedContentOffset {
      updatedContentOffset = true
      navigationBarView.setNeedsLayout()
      navigationBarView.layoutIfNeeded()
      navigationBarView.setState(isCollapsed: false, animated: false)
      scrollView.delegate = self
    }
    scrollView.contentInset.bottom = view.bounds.height - buttonContainerView.frame.origin.y
    scrollView.contentInset.top = navigationBarView.maskArcHeight
      + navigationBarView.titleViewHeight + 24
  }
  
  // MARK: - Public Methods
  func handleEmptyViewRefreshButtonTapped() {
    viewModel.loadData()
  }

  func createTitleView() -> UIView {
    let titleLabel = AttributedLabel(textStyle: .textBold)
    titleLabel.numberOfLines = 2
    titleLabel.textColor = .base2
    titleLabel.textAlignment = .center
    updateTitle = { [weak navigationBarView] title in
      navigationBarView?.configureNavigationBarTitle(title: title)
    }
    return titleLabel
  }

  func reloadViews() {
    updateTitle?(viewModel.productTitle)

    stackView.arrangedSubviews.forEach {
      $0.removeFromSuperview()
    }

    viewModel.itemsViewModels.forEach {
      setupItemView(with: $0)
    }

    setupProductLinksStackView()
    productInfoStackView.arrangedSubviews.forEach {
      $0.removeFromSuperview()
    }
    viewModel.infoWebViewModels.forEach { infoWebViewModel in
      let infoView = ExpandableView<SelfSizedWebView>(isExpanded: false, withDivider: false)
      infoView.onNeedsToLayoutSuperview = { [weak self] in
        self?.view.layoutIfNeeded()
      }
      infoView.configure(title: infoWebViewModel.title,
                         viewModel: infoWebViewModel.infoViewModel)
      productInfoStackView.addArrangedSubview(infoView)
    }

    makeOrderButton.configure(with: viewModel.buttonConfiguration)
  }

  // MARK: - Private Methods
  
  private func setup() {
    view.backgroundColor = .base2
    setupScrollView()
    setupNavigationBarView()
    setupStackView()
    setupProductLinksStackView()
    setupMakeOrderButton()
    addActivityIndicatorView()
    addErrorEmptyView()
    view.bringSubviewToFront(navigationBarView)
  }
  
  private func setupScrollView() {
    view.addSubview(scrollView)
    
    scrollView.delegate = self
    scrollView.showsVerticalScrollIndicator = false
    scrollView.contentInset = UIEdgeInsets(top: 52, left: 0, bottom: 44, right: 0)
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupNavigationBarView() {
    view.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.leading.top.trailing.equalToSuperview()
    }
    navigationBarView.addBackButton { [unowned self] in
      self.delegate?.productDetailsViewControllerDidFinish(self)
    }
  }
  
  private func setupStackView() {
    scrollView.addSubview(stackView)
    stackView.axis = .vertical
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
  }
  
  private func setupProductLinksStackView() {
    stackView.addArrangedSubview(productInfoStackView)
    productInfoStackView.axis = .vertical
  }
  
  private func setupMakeOrderButton() {
    buttonContainerView.backgroundColor = .base2
    let dividerView = UIView()
    buttonContainerView.addSubview(dividerView)
    dividerView.backgroundColor = .shade40
    dividerView.snp.makeConstraints { make in
      make.height.equalTo(1)
      make.top.leading.trailing.equalToSuperview()
    }
    buttonContainerView.addSubview(makeOrderButton)
    makeOrderButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(13)
      make.bottom.equalToSuperview().inset(10)
    }
    makeOrderButton.addTarget(self, action: #selector(buyButtonTapped(_:)), for: .touchUpInside)
    view.addSubview(buttonContainerView)
    buttonContainerView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
    let buttonBottomView = UIView()
    buttonBottomView.backgroundColor = .base2
    view.addSubview(buttonBottomView)
    buttonBottomView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.top.equalTo(buttonContainerView.snp.bottom)
    }
  }
  
  private func bindToViewModel() {
    bind(to: viewModel)

    viewModel.onDidStartBasketCreation = { [weak self] in
      self?.makeOrderButton.startAnimating()
    }
    viewModel.onDidFinishBasketCreation = { [weak self] in
      self?.makeOrderButton.stopAnimating()
    }
  }

  // MARK: - Private methods
  private func setupItemView(with viewModel: ProductDetailsItemViewModel) {
    switch viewModel.type {
    case .imageCarousel:
      setupView(viewType: ProductImageCarouselView.self, with: viewModel)
    case .colorPicker:
      setupView(viewType: ProductColorPickerView.self, with: viewModel)
    case .propertyPicker:
      setupView(viewType: ProductPropertyPickerView.self, with: viewModel)
    case .programPicker:
      setupView(viewType: ProductProgramPickerView.self, with: viewModel)
    case .monthlyPayment:
      setupView(viewType: ProductMonthlyPaymentView.self, with: viewModel)
    case .advantages:
      setupView(viewType: ProductAdvantagesView.self, with: viewModel)
    case .features:
      setupFeaturesView(with: viewModel)
    case .fullFeatures:
      setupFullFeaturesView(with: viewModel)
    case .divider:
      let divider = makeDivider()
      stackView.addArrangedSubview(divider)
      addCustomSpacing(with: viewModel, after: divider)
    }
  }

  // MARK: - Make Items view
  private func setupView<V>(viewType: V.Type, with viewModel: ProductDetailsItemViewModel) where V: UIView & Configurable {
    let view = V()
    stackView.addArrangedSubview(view)
    addCustomSpacing(with: viewModel, after: view)
    if let configurator = viewModel as? V.ViewModel {
      view.configure(with: configurator)
    }
  }

  private func setupFeaturesView(with viewModel: ProductDetailsItemViewModel) {
    let featuresView = ExpandableView<ProductFeaturesView>(withDivider: false)
    stackView.addArrangedSubview(featuresView)
    addCustomSpacing(with: viewModel, after: featuresView)
    if let viewModel = viewModel as? ProductFeaturesViewModel {
      featuresView.configure(title: R.string.productDetails.featuresSectionTitle(),
                             viewModel: viewModel)
    }
    featuresView.onNeedsToLayoutSuperview = { [weak self] in
      self?.view.layoutIfNeeded()
    }
  }

  private func setupFullFeaturesView(with viewModel: ProductDetailsItemViewModel) {
    let fullFeatures = ExpandableView<ProductFullFeaturesView>(withDivider: false)
    stackView.addArrangedSubview(fullFeatures)
    addCustomSpacing(with: viewModel, after: fullFeatures)
    if let viewModel = viewModel as? ProductFullFeaturesViewModel {
      fullFeatures.configure(title: R.string.productDetails.fullFeaturesSectionTitle(),
                             viewModel: viewModel)
    }
    fullFeatures.onNeedsToLayoutSuperview = { [weak self] in
      self?.view.layoutIfNeeded()
    }
  }

  private func addCustomSpacing(with viewModel: ProductDetailsItemViewModel, after view: UIView) {
    if let customSpacing = viewModel.customSpacing {
      stackView.setCustomSpacing(customSpacing, after: view)
    }
  }

  private func makeDivider() -> UIView {
    let dividerContainer = UIView()
    let dividerView = UIView()
    dividerContainer.addSubview(dividerView)
    dividerView.backgroundColor = .shade40
    dividerView.snp.makeConstraints { make in
      make.height.equalTo(1)
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
    return dividerContainer
  }
  
  // MARK: - Actions
  
  @objc private func buyButtonTapped(_ sender: UIButton) {
    viewModel.didTapBottomButton()
  }
}

// MARK: - UIScrollViewDelegate

extension ProductDetailsViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    handleScrollDefault(scrollView: scrollView)
  }
}
