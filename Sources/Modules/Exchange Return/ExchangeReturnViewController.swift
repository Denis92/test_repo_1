//
//  ExchangeReturnViewController.swift
//  ForwardLeasing
//

import UIKit

protocol ExchangeReturnViewControllerDelegate: class {
  func exchangeReturnViewControllerDidFinish(_ viewController: ExchangeReturnViewController)
}

typealias ExchangeReturnDocumentCell = CommonContainerTableViewCell<PaddingAddingContainer<DocumentPDFView>>
typealias ExchangeReturnBarcodeCell = CommonContainerTableViewCell<PaddingAddingContainer<BarcodeView>>
typealias ExchangeReturnStoreInfoCell = CommonContainerTableViewCell<PaddingAddingContainer<StoreInfoView>>
typealias ExchangeReturnTitleViewCell = CommonContainerTableViewCell<PaddingAddingContainer<ExchangeReturnTitleView>>
typealias ExchangeReturnPriceCell = CommonContainerTableViewCell<ExchangeReturnPriceView>
typealias ExchangeReturnInfoButtonsCell = CommonContainerTableViewCell<ExchangeReturnInfoButtonsView>
typealias ExchangeReturnSelectStoreCell = CommonContainerTableViewCell<ExchangeReturnSelectStoreView>

class ExchangeReturnViewController: RoundedNavigationBarTableViewController {
  // MARK: - Properties
  
  weak var delegate: ExchangeReturnViewControllerDelegate?
  
  var appDidBecomeActiveNotificationToken: NSObjectProtocol?
  var appWillResignActiveNotificationToken: NSObjectProtocol?
  
  override var bottomInset: CGFloat {
    return 40
  }
  
  private let viewModel: ExchangeReturnViewModel
  
  // MARK: - Init
  
  init(viewModel: ExchangeReturnViewModel) {
    self.viewModel = viewModel
    super.init(viewModel: viewModel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindToViewModel()
    viewModel.loadData(isRefreshing: false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    subscribeForAppActivityNotifications()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    unsubscribeFromAppActivityNotifications()
    viewModel.invalidateRefreshTimer()
  }
  
  override func handleStartRefreshing() {
    super.handleStartRefreshing()
    viewModel.loadData(isRefreshing: true)
  }
  
  override func handleEmptyViewRefreshButtonTapped() {
    super.handleEmptyViewRefreshButtonTapped()
    viewModel.loadData(isRefreshing: false)
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupNavigationBar()
    setupTableView()
  }
  
  private func setupNavigationBar() {
    navigationBarView.configureNavigationBarTitle(title: viewModel.screenTitle)
    navigationBarView.addBackButton { [weak self] in
      guard let self = self else { return }
      self.delegate?.exchangeReturnViewControllerDidFinish(self)
    }
  }
  
  private func setupTableView() {
    tableView.register(ExchangeReturnDocumentCell.self, forCellReuseIdentifier: ExchangeReturnDocumentCell.reuseIdentifier)
    tableView.register(ExchangeReturnBarcodeCell.self, forCellReuseIdentifier: ExchangeReturnBarcodeCell.reuseIdentifier)
    tableView.register(ExchangeReturnPriceCell.self, forCellReuseIdentifier: ExchangeReturnPriceCell.reuseIdentifier)
    tableView.register(ExchangeReturnSelectStoreCell.self, forCellReuseIdentifier: ExchangeReturnSelectStoreCell.reuseIdentifier)
    tableView.register(ExchangeReturnStoreInfoCell.self, forCellReuseIdentifier: ExchangeReturnStoreInfoCell.reuseIdentifier)
    tableView.register(ExchangeReturnInfoButtonsCell.self, forCellReuseIdentifier: ExchangeReturnInfoButtonsCell.reuseIdentifier)
    tableView.register(ExchangeReturnTitleViewCell.self, forCellReuseIdentifier: ExchangeReturnTitleViewCell.reuseIdentifier)
    
    tableView.contentInset.bottom = 40
  }
  
  // MARK: - Bind
  
  private func bindToViewModel() {
    viewModel.onDidRequestToCancelContract = { [weak self] in
      self?.showCancelContractAlert()
    }
  }
  
  // MARK: - Private methods
  
  private func showCancelContractAlert() {
    let controller = BaseAlertViewController()
    let popup = PopupAlertView(R.string.exchangeInfo.cancelContractAlertTitle())
    
    let confirmButton = StandardButton(type: .primary)
    confirmButton.setTitle(R.string.common.yes(), for: .normal)
    confirmButton.actionHandler(controlEvents: .touchUpInside) { [weak self, weak controller] in
      self?.viewModel.cancelContract()
      controller?.dismiss(animated: true, completion: nil)
    }
    popup.addButton(confirmButton)
    
    let cancelButton = StandardButton(type: .secondary)
    cancelButton.setTitle(R.string.common.cancel(), for: .normal)
    cancelButton.actionHandler(controlEvents: .touchUpInside) { [weak controller] in
      controller?.dismiss(animated: true, completion: nil)
    }
    popup.addButton(cancelButton)
    
    controller.addPopupAlert(popup)
    present(controller, animated: true, completion: nil)
  }
}

// MARK: - AppActivityMonitoring

extension ExchangeReturnViewController: AppActivityMonitoring {
  func appDidBecomeActive() {
    viewModel.startBackgroundUpdatesIfNeeded()
  }
  
  func appWillResignActive() {
    viewModel.invalidateRefreshTimer()
  }
}
