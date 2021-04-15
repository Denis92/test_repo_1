//
//  CurrentApplicationsViewController.swift
//  ForwardLeasing
//

import UIKit

protocol CurrentApplicationsViewControllerDelegate: class {
  func currentApplicationsViewControllerDidFinish(_ viewController: CurrentApplicationsViewController)
}

class CurrentApplicationsViewController: BaseViewController, RoundedNavigationBarHaving,
                                         NavigationBarHiding, ActivityIndicatorViewDisplaying,
                                         ErrorEmptyViewDisplaying, ViewModelBinding {
  private typealias HeaderView = CommonContainerHeaderFooterView<CurrentApplicationsTableHeaderView>
  private typealias ItemCell = CommonContainerTableViewCell<CurrentApplicationsItemView>
  
  // MARK: - Properties
  
  weak var delegate: CurrentApplicationsViewControllerDelegate?
  
  var activityIndicatorView = ActivityIndicatorView(color: .accent)
  var errorEmptyView = ErrorEmptyView()
  var scrollViewLastOffset: CGFloat = 0
  var scrollView: UIScrollView {
    return tableView
  }
  
  let navigationBarView = NavigationBarView()
  
  private let tableView = UITableView(frame: .zero, style: .grouped)
  private let headerLabel = AttributedLabel(textStyle: .title3Semibold)

  private let viewModel: CurrentApplicationsViewModel
  private let dataSource = TableViewDataSource()

  private var updatedContentOffset = false
  
  // MARK: - Init
  
  init(viewModel: CurrentApplicationsViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindToViewModel()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadViews()
    updatedContentOffset = false
    view.setNeedsLayout()
    view.layoutIfNeeded()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !updatedContentOffset, scrollView.contentSize.height > 0 {
      updatedContentOffset = true
      scrollView.contentInset.top = navigationBarView.maskArcHeight + 24
      scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: false)
      handleScrollDefault(scrollView: scrollView)
      navigationBarView.setNeedsLayout()
      navigationBarView.layoutIfNeeded()
      navigationBarView.setState(isCollapsed: false, animated: false)
    }
  }
  
  // MARK: - Public methods
  
  func handleEmptyViewRefreshButtonTapped() {
    viewModel.repeatFailedRequest()
  }
  
  func reloadViews() {
    dataSource.update(viewModel: viewModel)
    tableView.reloadData()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    handleScrollDefault(scrollView: scrollView)
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupNavigationView()
    setupTableView()
    addActivityIndicatorView()
    addErrorEmptyView()
    view.bringSubviewToFront(navigationBarView)
  }
  
  private func setupTableView() {
    view.addSubview(tableView)
    
    tableView.showsVerticalScrollIndicator = false
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.alwaysBounceVertical = false
    tableView.contentInset = UIEdgeInsets(top: 88, left: 0, bottom: 0, right: 0)
    
    tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseIdentifier)
    tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.reuseIdentifier)

    tableView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(navigationBarView.titleViewMaxY)
      make.leading.trailing.bottom.equalToSuperview()
    }
    
    dataSource.setup(tableView: tableView, viewModel: viewModel)
    dataSource.onDidScroll = { [weak self] scrollView in
      self?.scrollViewDidScroll(scrollView)
    }
  }
  
  private func setupNavigationView() {
    view.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    navigationBarView.addBackButton { [unowned self] in
      self.delegate?.currentApplicationsViewControllerDidFinish(self)
    }
    navigationBarView.configureNavigationBarTitle(title: R.string.currentApplications.screenTitle())
  }

  private func deleteRow(at indexPath: IndexPath) {
    dataSource.update(viewModel: viewModel)
    tableView.performBatchUpdates({ [weak self] in
      self?.tableView.deleteRows(at: [indexPath], with: .automatic)
    }, completion: nil)
  }

  // MARK: - View Model
  
  private func bindToViewModel() {
    bind(to: viewModel)
    viewModel.onDidRequestDeleteRow = { [weak self] indexPath in
      self?.deleteRow(at: indexPath)
    }
  }
}
