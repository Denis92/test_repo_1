//
//  RoundedNavigationBarTableViewController.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let additionalTopInset: CGFloat = 24
}

typealias ViewModel = CommonTableViewModel & BindableViewModel

class RoundedNavigationBarTableViewController: BaseViewController, NavigationBarHiding,
                                               RoundedNavigationBarHaving, ActivityIndicatorViewDisplaying,
                                               ErrorEmptyViewDisplaying, ViewModelBinding {
  // MARK: - Properties
  var scrollViewLastOffset: CGFloat = 0
  var shouldShowActivityIndicator: Bool {
    !navigationBarView.isRefreshing
  }
  var scrollView: UIScrollView {
    return tableView
  }
  
  let tableView = UITableView(frame: .zero, style: .grouped)
  let activityIndicatorView = ActivityIndicatorView(color: .accent)
  let errorEmptyView = ErrorEmptyView()
  let navigationBarView: NavigationBarView
  
  var bottomInset: CGFloat {
    return 0
  }
  
  private var currentNavBarContentContainerHeight: CGFloat = 0
  
  private let navigationBarType: NavigationBarViewType
  private let viewModel: ViewModel
  private let dataSource: TableViewDataSource
  
  // MARK: - Init
  init(viewModel: ViewModel,
       navigationBarType: NavigationBarViewType = .titleAlwaysVisible(hasPullToRefresh: true),
       dataSource: TableViewDataSource = TableViewDataSource()) {
    self.navigationBarView = NavigationBarView(type: navigationBarType)
    self.navigationBarType = navigationBarType
    self.viewModel = viewModel
    self.dataSource = dataSource
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
    bind(to: viewModel)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.bringSubviewToFront(navigationBarView)
  }
  
  // MARK: - Public methods
  func handleEmptyViewRefreshButtonTapped() {
    // default implementation
  }
  
  func handleStartRefreshing() {
    // default implementation
  }
  
  func handleRequestFinished() {
    tableView.isScrollEnabled = true
    if navigationBarView.isRefreshing {
      tableView.panGestureRecognizer.state = .ended
      navigationBarView.endRefreshing {
        self.updateForNavBarContentContainerHeight(height: self.currentNavBarContentContainerHeight)
      }
    }
  }
  
  func handleRequestStarted(shouldShowActivityIndicator: Bool) {
    if shouldShowActivityIndicator {
      tableView.isScrollEnabled = false
    }
  }
  
  func updateDataSource() {
    dataSource.update(viewModel: viewModel)
  }
  
  func reloadViews() {
    dataSource.update(viewModel: viewModel)
    tableView.isScrollEnabled = !dataSource.sections.isEmpty
    tableView.reloadData()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    navigationBarView.frame.origin.y = scrollView.contentOffset.y
    handleScrollDefault(scrollView: scrollView)
  }
  
  // MARK: - Setup
  private func setup() {
    setupTableView()
    setupNavigationView()
    addActivityIndicatorView()
    addErrorEmptyView()
  }
  
  private func setupTableView() {
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.showsVerticalScrollIndicator = false
    var frame = CGRect.zero
    frame.size.height = .leastNormalMagnitude
    tableView.tableHeaderView = UIView(frame: frame)
    tableView.tableFooterView = UIView(frame: frame)
    
    dataSource.setup(tableView: tableView, viewModel: viewModel)
    tableView.isScrollEnabled = !dataSource.sections.isEmpty
    
    dataSource.onDidScroll = { [weak self] scrollView in
      self?.scrollViewDidScroll(scrollView)
    }
  }
  
  private func setupNavigationView() {
    tableView.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.leading.trailing.top.equalTo(view)
    }
    navigationBarView.onDidUpdateContentContainerHeight = { [weak self] height in
      self?.currentNavBarContentContainerHeight = height
      self?.updateForNavBarContentContainerHeight(height: height)
    }
    navigationBarView.onDidStartRefreshing = { [weak self] additionalHeight in
      guard let self = self else {
        return
      }
      self.updateForNavBarContentContainerHeight(height: self.currentNavBarContentContainerHeight + additionalHeight)
      self.handleStartRefreshing()
    }
    navigationBarView.onNeedsToLayoutSuperview = { [unowned self] in
      self.tableView.layoutIfNeeded()
    }
  }
  
  // MARK: - Update Content Inset
  private func updateForNavBarContentContainerHeight(height: CGFloat) {
    var topInset = height + navigationBarView.maskArcHeight + Constants.additionalTopInset
    if case .titleAlwaysVisible = navigationBarType {
      topInset += navigationBarView.titleViewHeight
    }
    topInset += UIApplication.shared.statusBarFrame.height
    
    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
    
    activityIndicatorView.snp.remakeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(navigationBarView.isHidden ? 0 : topInset / 2)
    }
    activityIndicatorView.layoutIfNeeded()
    
    if tableView.contentOffset.y <= 0 {
      tableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    }
  }
}
