//
//  CatalogueViewController.swift
//  ForwardLeasing
//

import UIKit

private typealias Header = CommonContainerHeaderFooterView<CatalogueListHeaderView>
private typealias SingleProductCell = CommonContainerTableViewCell<SingleProductView>
private typealias ProductPromoCell = CommonContainerTableViewCell<ProductPromoView>
private typealias SubcategoriesListCell = CommonContainerTableViewCell<SubcategoryListView>
private typealias ShowCategoryDetailsButtonCell = CommonContainerTableViewCell<ShowCategoryDetailsButtonView>
private typealias ProductPairCell = CommonContainerTableViewCell<ProductPairView>
private typealias SubscriptionProductCell = CommonContainerTableViewCell<SubscriptionProductView>

class CatalogueViewController: RoundedNavigationBarTableViewController, TabBarControllerContained {
  // MARK: - Subviews
  private let topNavigationCollectionView = CatalogueTopCollectionView()

  // MARK: - Properties
  let scrollType: NavBarScrollType = .showOnOffset

  private var currentNavBarContentContainerHeight: CGFloat = 0
  private var additionalNavBarOffset: CGFloat = 0

  private let viewModel: CatalogueViewModel

  init(viewModel: CatalogueViewModel) {
    self.viewModel = viewModel
    super.init(viewModel: viewModel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    viewModel.loadData()
  }

  // MARK: - Public methods

  override func handleEmptyViewRefreshButtonTapped() {
    super.handleEmptyViewRefreshButtonTapped()
    viewModel.loadData()
  }

  override func handleStartRefreshing() {
    super.handleStartRefreshing()
    viewModel.loadData()
  }

  override func reloadViews() {
    super.reloadViews()
    configureTopNavigationView(with: viewModel.topCollectionViewModel)
  }

  // MARK: - Setup

  private func setup() {
    setupNavigationBarView()
    setupTableView()
  }

  private func setupNavigationBarView() {
    navigationBarView.addContentView(topNavigationCollectionView)
    navigationBarView.configureNavigationBarTitle(title: R.string.catalogue.screenTitle())
  }

  private func setupTableView() {
    tableView.register(Header.self,
                       forHeaderFooterViewReuseIdentifier: Header.reuseIdentifier)
    tableView.register(SingleProductCell.self,
                       forCellReuseIdentifier: SingleProductCell.reuseIdentifier)
    tableView.register(ProductPromoCell.self,
                       forCellReuseIdentifier: ProductPromoCell.reuseIdentifier)
    tableView.register(SubcategoriesListCell.self,
                       forCellReuseIdentifier: SubcategoriesListCell.reuseIdentifier)
    tableView.register(ShowCategoryDetailsButtonCell.self,
                       forCellReuseIdentifier: ShowCategoryDetailsButtonCell.reuseIdentifier)
    tableView.register(ProductPairCell.self,
                       forCellReuseIdentifier: ProductPairCell.reuseIdentifier)
    tableView.register(SubscriptionProductCell.self,
                       forCellReuseIdentifier: SubscriptionProductCell.reuseIdentifier)
  }

  // MARK: - Configure Views
  private func configureTopNavigationView(with viewModel: CatalogueTopCollectionViewModel?) {
    viewModel.map { topNavigationCollectionView.configure(with: $0 )}
  }
}
