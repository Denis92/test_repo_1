//
//  SubscriptionContractViewController.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let additionalTopInset: CGFloat = 24
}

protocol SubscriptionContractViewControllerDelegate: class {
  func subscriptionContractViewControllerDidRequestGoBack(_ viewController: SubscriptionContractViewController)
}

class SubscriptionContractViewController: BaseViewController, NavigationBarHiding,
                                          RoundedNavigationBarHaving, ErrorEmptyViewDisplaying,
                                          ActivityIndicatorViewDisplaying, ViewModelBinding {
  // MARK: - Properties
  let contentView = UIView()
  let errorEmptyView = ErrorEmptyView()
  let activityIndicatorView = ActivityIndicatorView()
  let navigationBarView = NavigationBarView(type: .titleAlwaysVisible())
  let scrollView = UIScrollView()

  var scrollViewLastOffset: CGFloat = 0

  weak var delegate: SubscriptionContractViewControllerDelegate?

  private let viewModel: SubscriptionContractViewModel
  private let headerView = SubscriptionContractHeaderView()
  private let stackView = UIStackView()
  private let activityIndicator = ActivityIndicatorView()
  
  private var currentNavBarContentContainerHeight: CGFloat = 0
  private var ignoreScrollEvent = false

  // MARK: - Init
  init(viewModel: SubscriptionContractViewModel) {
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
    viewModel.loadCards()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.bringSubviewToFront(navigationBarView)
    let bottomInset = scrollView.frame.height - (UIApplication.shared.statusBarFrame.height
                                                  + navigationBarView.titleViewHeight
                                                  + Constants.additionalTopInset
                                                  + scrollView.contentSize.height)
    scrollView.contentInset.bottom = bottomInset
  }

  // MARK: - ErrorEmptyViewDisplaying
  func handleErrorEmptyViewHiddenStateChanged(isHidden: Bool) {
    navigationBarView.setState(isCollapsed: !isHidden, animated: false)
    scrollView.setContentOffset(.zero, animated: false)
  }

  func handleEmptyViewRefreshButtonTapped() {
    viewModel.loadCards()
  }

  func reloadViews() {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    let keysView = SubscriptionKeyListView()
    keysView.configure(with: viewModel.keysViewModel)
    stackView.addArrangedSubview(keysView)
    let aboutView = AboutSubscriptionDetailsView()
    aboutView.configure(with: viewModel.aboutViewModel)
    stackView.addArrangedSubview(aboutView)
    let renewView = RenewSubscriptionDetailsView()
    if let renewViewModel = viewModel.renewViewModel {
      renewView.configure(with: renewViewModel)
      stackView.addArrangedSubview(renewView)
    }
    updateForNavBarContentContainerHeight(height: currentNavBarContentContainerHeight)
  }

  // MARK: - Private Methods
  
  private func bindToViewModel() {
    bind(to: viewModel)
    viewModel.onDidRequestToShowEmptyErrorView = { [weak self] error in
      self?.scrollView.setContentOffset(.zero, animated: false)
      self?.navigationBarView.setState(isCollapsed: true, animated: true)
      self?.handle(dataDefiningError: error)
    }
    viewModel.onDidCopyKey = { [weak self] in
      self?.showBanner(text: R.string.subscriptionDetails.copySnackbarText())
    }
    viewModel.onNeedsToShareKeys = { [weak self] keys in
      self?.share(text: keys)
    }
  }

  private func setup() {
    headerView.configure(with: viewModel.headerViewModel)
    setupScrollView()
    setupNavBar()
    setupContentView()
    setupStackView()
    addErrorEmptyView()
    addActivityIndicatorView()
    view.bringSubviewToFront(navigationBarView)
  }
  
  private func setupScrollView() {
    view.addSubview(scrollView)
    scrollView.delegate = self
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.alwaysBounceVertical = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupNavBar() {
    scrollView.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.leading.trailing.top.equalTo(view)
    }
    navigationBarView.addContentView(headerView)
    navigationBarView.configureNavigationBarTitle(title: viewModel.title)
    navigationBarView.addBackButton { [weak self] in
      guard let self = self else { return }
      self.delegate?.subscriptionContractViewControllerDidRequestGoBack(self)
    }
    navigationBarView.onDidUpdateContentContainerHeight = { [weak self] height in
      self?.currentNavBarContentContainerHeight = height
      self?.updateForNavBarContentContainerHeight(height: height)
    }
    navigationBarView.onNeedsToLayoutSuperview = { [unowned self] in
      self.scrollView.layoutIfNeeded()
      
      if self.navigationBarView.isCollapsed {
        self.ignoreScrollEvent = true
        let contentOffsetY = self.contentView.frame.origin.y
        self.scrollView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
        self.ignoreScrollEvent = false
      }
    }
  }

  private func setupContentView() {
    scrollView.addSubview(contentView)
    scrollView.showsVerticalScrollIndicator = false
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view)
    }
  }

  private func setupStackView() {
    contentView.addSubview(stackView)
    stackView.axis = .vertical
    stackView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  // MARK: - Update Content Inset

  private func updateForNavBarContentContainerHeight(height: CGFloat) {
    var topInset = height + navigationBarView.maskArcHeight + Constants.additionalTopInset + navigationBarView.titleViewHeight
    topInset += UIApplication.shared.statusBarFrame.height
    scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0,
                                           bottom: scrollView.contentInset.bottom, right: 0)

    if scrollView.contentOffset.y <= 0 {
      scrollView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    }
  }
  
  // MARK: - Share
  
  private func share(text: String) {
    let items = [text]
    let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
    DispatchQueue.main.async {
      self.present(activityViewController, animated: true, completion: nil)
    }
  }
}

// MARK: - UIScrollViewDelegate
extension SubscriptionContractViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView.contentSize.height > 0, !ignoreScrollEvent else {
      return
    }
    navigationBarView.frame.origin.y = scrollView.contentOffset.y
    handleScrollDefault(scrollView: scrollView)
  }
}
