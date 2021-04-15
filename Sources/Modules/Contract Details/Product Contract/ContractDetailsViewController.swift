//
//  ContractDetailsViewController.swift
//  ForwardLeasing
//

import UIKit

protocol ContractDetailsViewControllerDelegate: class {
  func contractDetailsViewControllerDidFinish(_ viewController: ContractDetailsViewController)
  func contractDetailsViewControllerDidRequestGoBack(_ viewController: ContractDetailsViewController)
}

class ContractDetailsViewController: RoundedNavigationBarTableViewController, ActivityIndicatorPresenting {
  // MARK: - Properties
  
  weak var delegate: ContractDetailsViewControllerDelegate?
  
  private let viewModel: ContractDetailsViewModel
  
  private let deliveryView = ContractDetailsDeliveryView()
  private let documentsButton = UIButton(type: .system)
  private let detailsInfoView = ContractDetailsInfoView()
  
  // MARK: - Init
  
  init(viewModel: ContractDetailsViewModel) {
    self.viewModel = viewModel
    super.init(viewModel: viewModel)
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
    viewModel.loadData()
  }

  override func handleEmptyViewRefreshButtonTapped() {
    viewModel.loadData(isRefreshing: true)
  }
  
  override func handleStartRefreshing() {
    self.viewModel.loadData(isRefreshing: true)
  }
  
  override func reloadViews() {
    super.reloadViews()
    navigationBarView.configureNavigationBarTitle(title: viewModel.title)
    tableView.isHidden = false
    navigationBarView.isHidden = false
  }
  
  override func handleRequestStarted(shouldShowActivityIndicator: Bool) {
    if shouldShowActivityIndicator {
      tableView.isHidden = true
      navigationBarView.isHidden = true
    }
  }

  // MARK: - Setup
  
  private func setup() {
    setupNavigationBarView()
    setupPDFButton()
    setupTableView()
  }

  private func setupNavigationBarView() {
    navigationBarView.addBackButton { [unowned self] in
      self.delegate?.contractDetailsViewControllerDidFinish(self)
    }
    navigationBarView.addContentView(detailsInfoView)
  }
  
  private func setupPDFButton() {
    navigationBarView.configureNavigationBarTitle(title: nil, rightViews: [documentsButton])
    documentsButton.setImage(R.image.documentsButton(), for: .normal)
    documentsButton.addTarget(self, action: #selector(didTapDocuments), for: .touchUpInside)
  }
  
  private func setupTableView() {
    tableView.register(ContractMakePaymentButtonCell.self,
                       forCellReuseIdentifier: ContractMakePaymentButtonCell.reuseIdentifier)
    tableView.register(ContractDetailsDeliveryCell.self,
                       forCellReuseIdentifier: ContractDetailsDeliveryCell.reuseIdentifier)
    tableView.register(ExchangeOptionsCell.self, forCellReuseIdentifier: ExchangeOptionsCell.reuseIdentifier)
    tableView.register(ContractDetailsAdditionInfoCell.self,
                       forCellReuseIdentifier: ContractDetailsAdditionInfoCell.reuseIdentifier)
    tableView.register(PaymentsScheduleCell.self, forCellReuseIdentifier: PaymentsScheduleCell.reuseIdentifier)
    tableView.register(AboutProductCell.self, forCellReuseIdentifier: AboutProductCell.reuseIdentifier)
    tableView.register(ContractExchangeApplicationCell.self,
                       forCellReuseIdentifier: ContractExchangeApplicationCell.reuseIdentifier)
    tableView.register(ContractReturnApplicationCell.self,
                       forCellReuseIdentifier: ContractReturnApplicationCell.reuseIdentifier)
  }
  
  // MARK: - ViewModel
  private func bindToViewModel() {
    bind(to: viewModel)
    viewModel.onNeedsToPerformBatchUpdates = { [weak self] in
      self?.tableView.performBatchUpdates(nil, completion: nil)
    }
    viewModel.onDidRequestShowAlertWithMessage = { [weak self] message in
      self?.showAppAlert(message: message)
    }
    viewModel.onDidRequestToDeleteSection = { [weak self] index in
      self?.updateDataSource()
      self?.tableView.deleteSections(IndexSet([index]), with: .fade)
      self?.view.setNeedsLayout()
      self?.view.layoutIfNeeded()
    }
    viewModel.onDidUpdateDetailsInfoViewModel = { [weak self] viewModel in
      self?.detailsInfoView.configure(with: viewModel)
    }
    viewModel.onDidRequestToCancelLeasingEntity = { [weak self] callback in
      self?.showCancelLeasingEntityAlert(callback: callback)
    }
    viewModel.onDidRequestToPresentActivityIndicator = { [weak self] in
      self?.presentActivtiyIndicator(completion: nil)
    }
    viewModel.onDidRequestToHideActivityIndicator = { [weak self] in
      self?.dismissActivityIndicator(completion: nil)
    }
  }
  
  // MARK: - Actions
  @objc private func didTapDocuments() {
    viewModel.showPDFDocuments()
  }
  
  // MARK: - Private methods
  
  private func showCancelLeasingEntityAlert(callback: @escaping () -> Void) {
    let alertController = BaseAlertViewController()
    let popup = PopupAlertView(R.string.profile.cancelApplicationAlertTitle())
    alertController.addPopupAlert(popup)
    
    let confirmButton = StandardButton(type: .primary)
    confirmButton.setTitle(R.string.common.yes(), for: .normal)
    confirmButton.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
      alertController?.dismiss(animated: true) {
        callback()
      }
    }
    popup.addButton(confirmButton)
    
    let cancelButton = StandardButton(type: .secondary)
    cancelButton.setTitle(R.string.common.cancel(), for: .normal)
    cancelButton.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
      alertController?.dismiss(animated: true, completion: nil)
    }
    popup.addButton(cancelButton)
    
    present(alertController, animated: true, completion: nil)
  }
}
