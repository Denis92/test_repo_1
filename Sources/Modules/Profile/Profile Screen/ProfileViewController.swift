//
//  ProfileViewController.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let additionalTopInset: CGFloat = 24
}

class ProfileViewController: RoundedNavigationBarTableViewController, TabBarControllerContained {
  // MARK: - Properties
  private let viewModel: ProfileViewModel
  private let greetingView = GreetingView()
  private let settingsButton = UIButton(type: .system)

  init(viewModel: ProfileViewModel) {
    self.viewModel = viewModel
    super.init(viewModel: viewModel, navigationBarType: .titleHiddenWhenFull(hasPullToRefresh: true))
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
    bindToViewModel()
    viewModel.loadData()
  }

  override func handleStartRefreshing() {
    super.handleStartRefreshing()

    viewModel.loadData(isRefreshing: true)
  }

  override func handleEmptyViewRefreshButtonTapped() {
    super.handleEmptyViewRefreshButtonTapped()

    viewModel.loadData(isRefreshing: true)
    
  }

  // MARK: - Setup

  private func setup() {
    setupGreetingView()
    setupSettingsButton()
    setupNavigationBarView()
    setupTableView()
  }

  private func setupGreetingView() {
    greetingView.name = "Константин"
    greetingView.onDidTapSettingsButton = { [weak self] in
      self?.viewModel.showSettings()
    }
  }

  private func setupSettingsButton() {
    settingsButton.setImage(R.image.settingsButtonWithBackground()?.withRenderingMode(.alwaysOriginal), for: .normal)
    settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
    settingsButton.snp.makeConstraints { make in
      make.size.equalTo(32)
    }
  }

  private func setupNavigationBarView() {
    navigationBarView.addContentView(greetingView)
    navigationBarView.configureNavigationBarTitle(title: R.string.profile.screenTitle(),
                                                  rightViews: [settingsButton])
  }

  private func setupTableView() {
    tableView.register(TemporaryCell.self, forCellReuseIdentifier: TemporaryCell.reuseIdentifier)
    tableView.register(ProfileSegmentedControlCell.self, forCellReuseIdentifier: ProfileSegmentedControlCell.reuseIdentifier)
    tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.reuseIdentifier)
    tableView.register(ClosedContractsCell.self, forCellReuseIdentifier: ClosedContractsCell.reuseIdentifier)
    tableView.register(SubscriptionCell.self, forCellReuseIdentifier: SubscriptionCell.reuseIdentifier)
    tableView.register(ProfileEmptyStateCell.self, forCellReuseIdentifier: ProfileEmptyStateCell.reuseIdentifier)
  }

  // MARK: - Actions
  @objc private func settingsButtonTapped() {
    viewModel.showSettings()
  }
  
  // MARK: - ViewModel
  
  private func bindToViewModel() {
    viewModel.onNeedsToPerformBatchUpdates = { [weak self] in
      self?.tableView.performBatchUpdates(nil, completion: nil)
    }
    viewModel.onDidRequestToCancelLeasingEntity = { [weak self] callback in
      self?.showCancelLeasingEntityAlert(callback: callback)
    }
    viewModel.onDidRequestToShowHardcheckerError = { [weak self] message in
      self?.showHardcheckerError(message: message)
    }
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
    
    (tabBarController ?? self).present(alertController, animated: true, completion: nil)
  }
  
  private func showHardcheckerError(message: String?) {
    let alertController = BaseAlertViewController(closesOnBackgroundTap: false)
    let popup = PopupAlertView(message)
    alertController.addPopupAlert(popup)
    
    let okButton = StandardButton(type: .primary)
    okButton.setTitle(R.string.common.ok(), for: .normal)
    okButton.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
      alertController?.dismiss(animated: true, completion: nil)
    }
    popup.addButton(okButton)
    
    (tabBarController ?? self).present(alertController, animated: true, completion: nil)
  }
}
