//
//  BottomSheetListViewController.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let bottomInset: CGFloat = 32
}

class BottomSheetListViewController<T: SelectableItem>: BaseBottomSheetViewController {
  // MARK: - Subviews
  let tableView = UITableView()
  let dataSource = TableViewDataSource()
  
  // MARK: - Properties
  override var calculatedHeight: CGFloat? {
    let height: CGFloat
    if contentHeight > maxHeight {
      height = maxHeight
    } else {
      height = contentHeight + buttonOffset
    }
    return height
  }
  
  var maxHeight: CGFloat {
    return Constants.maxModalScreenHeight
  }
  
  var contentHeight: CGFloat {
    return tableView.contentSize.height + Constants.bottomInset + view.safeAreaInsets.bottom
  }
  
  private var buttonOffset: CGFloat {
    return closeButton.frame.maxY + 12
  }
  
  private var previousContentHeight: CGFloat = 0 {
    didSet {
      tableView.isScrollEnabled = previousContentHeight == maxHeight
    }
  }
  
  private let viewModel: BottomSheetListViewModel<T>
  
  // MARK: - Init
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if previousContentHeight != calculatedHeight {
      previousContentHeight = calculatedHeight ?? 0
      self.shouldResize = true
      self.forceLayout()
    }
  }
  
  init(viewModel: BottomSheetListViewModel<T>) {
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
  }
  
  override func didRemoveViewController() {
    viewModel.finish()
  }
  
  // MARK: - Public methods
  func setFooterView(_ view: UIView) {
    tableView.tableFooterView = view
  }
  
  // MARK: - Private Methods
  private func setup() {
    view.insertSubview(tableView, at: 0)
    tableView.contentInset = UIEdgeInsets(top: closeButton.frame.maxY + 12, left: 0,
                                          bottom: Constants.bottomInset + view.safeAreaInsets.bottom,
                                          right: 0)
    tableView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    tableView.showsVerticalScrollIndicator = false
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.register(BottomSheetListCell.self,
                       forCellReuseIdentifier: BottomSheetListCell.reuseIdentifier)
    dataSource.setup(tableView: tableView, viewModel: viewModel)
  }
}
