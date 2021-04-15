//
//  SelectSubcategoryViewController.swift
//  ForwardLeasing
//

import UIKit

private typealias Cell = CommonContainerTableViewCell<SelectableListItemView>

class SelectSubcategoryViewController: BaseBottomSheetViewController {
  // MARK: - Properties

  var height: CGFloat {
    return viewModel.height
  }

  private let titleLabel = AttributedLabel(textStyle: .title1Bold)
  private let tableView = UITableView()

  private let viewModel: SelectSubcategoryViewModel
  private let dataSource: TableViewDataSource

  // MARK: - Init

  init(viewModel: SelectSubcategoryViewModel, dataSource: TableViewDataSource = TableViewDataSource()) {
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
  }

  // MARK: - Setup

  private func setup() {
    addTitleLabel()
    addTableView()
  }

  private func addTitleLabel() {
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalTo(closeButton.snp.leading).inset(16)
      make.top.equalToSuperview().offset(28)
    }
    titleLabel.text = R.string.catalogue.subcategoryListTitle()
  }
  
  private func addTableView() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(12)
      make.leading.trailing.bottom.equalToSuperview()
    }
    tableView.register(Cell.self,
                       forCellReuseIdentifier: Cell.reuseIdentifier)
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.showsVerticalScrollIndicator = false
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                          bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
    tableView.alwaysBounceVertical = false
    dataSource.setup(tableView: tableView, viewModel: viewModel)
    tableView.reloadData()
  }

  // MARK: - View Model

  private func bindToViewModel() {
    viewModel.onDidSelectItem = { [weak self] in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self?.removeBottomSheetViewController(animated: true)
      }
    }
  }
}
