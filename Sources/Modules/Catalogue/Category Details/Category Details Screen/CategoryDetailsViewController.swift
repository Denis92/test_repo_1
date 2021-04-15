//
//  CategoryDetailsViewController.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let navBarTopConstantHeight: CGFloat = 44
  static let additionalTopInset: CGFloat = 24
}

private typealias SingleProductCell = CommonContainerTableViewCell<SingleProductView>
private typealias ProductPromoCell = CommonContainerTableViewCell<ProductPromoView>

protocol CategoryDetailsViewControllerDelegate: class {
  func categoryDetailsViewControllerDidFinish(_ viewController: CategoryDetailsViewController)
}

class CategoryDetailsViewController: BaseViewController, NavigationBarHiding, RoundedNavigationBarHaving,
                                     ActivityIndicatorViewDisplaying, ErrorEmptyViewDisplaying, ViewModelBinding {
  // MARK: - Subviews
  var activityIndicatorView = ActivityIndicatorView(color: .accent)
  var errorEmptyView = ErrorEmptyView()
  let navigationBarView = NavigationBarView(type: .titleAlwaysVisible())
  var scrollView: UIScrollView {
    return tableView
  }

  private let tableView = UITableView()
  private let selectSubcategoryView = SelectSubcategoryHeaderView()
  private lazy var filterButton: NavBarButton = {
    return NavBarButton(image: R.image.filterButtonWithBackgroundIcon()) { [unowned self] in
      self.viewModel.changeFilters()
    }
  }()

  // MARK: - Properties
  let scrollType: NavBarScrollType = .showOnOffset
  
  var scrollViewLastOffset: CGFloat = 0
  weak var delegate: CategoryDetailsViewControllerDelegate?

  private let dataSource: TableViewDataSource
  private let viewModel: CategoryDetailsViewModel

  init(viewModel: CategoryDetailsViewModel, dataSource: TableViewDataSource = TableViewDataSource()) {
    self.viewModel = viewModel
    self.dataSource = dataSource
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindToViewModel()
    viewModel.loadData()
  }

  // MARK: - Public methods
  func handleEmptyViewRefreshButtonTapped() {
    viewModel.loadData()
  }

  func reloadViews() {
    dataSource.update(viewModel: viewModel)
    tableView.reloadData()
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    navigationBarView.frame.origin.y = scrollView.contentOffset.y
    handleScrollDefault(scrollView: scrollView)
  }

  // MARK: - Setup

  private func setup() {
    addTableView()
    addNavigationView()
    addActivityIndicatorView()
    addErrorEmptyView()
  }

  private func addNavigationView() {
    tableView.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.leading.trailing.top.equalTo(view)
    }
    navigationBarView.addContentView(selectSubcategoryView)
    selectSubcategoryView.configure(with: viewModel.headerViewModel)
    navigationBarView.configureNavigationBarTitle(title: viewModel.screenTitle, rightViews: [filterButton])
    navigationBarView.addBackButton { [unowned self] in
      self.delegate?.categoryDetailsViewControllerDidFinish(self)
    }
    navigationBarView.onDidUpdateContentContainerHeight = { [weak self] height in
      self?.updateForNavBarContentContainerHeight(height: height)
    }
    navigationBarView.onNeedsToLayoutSuperview = { [unowned self] in
      self.tableView.layoutIfNeeded()
    }
    filterButton.isHidden = !viewModel.isFilterButtonVisible
  }

  private func addTableView() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    tableView.register(SingleProductCell.self,
                       forCellReuseIdentifier: SingleProductCell.reuseIdentifier)
    tableView.register(ProductPromoCell.self,
                       forCellReuseIdentifier: ProductPromoCell.reuseIdentifier)
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.showsVerticalScrollIndicator = false
    var frame = CGRect.zero
    frame.size.height = .leastNormalMagnitude
    tableView.tableHeaderView = UIView(frame: frame)
    tableView.tableFooterView = UIView(frame: frame)

    dataSource.setup(tableView: tableView, viewModel: viewModel)
    dataSource.onDidScroll = { [weak self] scrollView in
      self?.scrollViewDidScroll(scrollView)
    }
  }

  // MARK: - Update Content Inset

  private func updateForNavBarContentContainerHeight(height: CGFloat) {
    var topInset = height + navigationBarView.maskArcHeight + Constants.additionalTopInset + navigationBarView.titleViewHeight
    topInset += UIApplication.shared.statusBarFrame.height

    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)

    if tableView.contentOffset.y <= 0 {
      tableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    }
  }

  // MARK: - View Model

  private func bindToViewModel() {
    bind(to: viewModel)
    viewModel.onDidUpdateFilterButtonVisibility = { [weak self] isVisible in
      self?.filterButton.isHidden = !isVisible
    }
  }
}
