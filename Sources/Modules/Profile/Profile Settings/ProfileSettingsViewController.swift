//
//  ProfileSettingsViewController.swift
//  ForwardLeasing
//

import UIKit

protocol ProfileSettingViewControllerDelegate: class {
  func profileSettingsViewControllerDidRequestGoBack(_ viewController: ProfileSettingsViewController)
}

class ProfileSettingsViewController: RegularTableViewController, ActivityIndicatorViewDisplaying,
                                     ActivityIndicatorPresenting {
  // MARK: - Subviews
  var activityIndicatorContainerView: UIView {
    return view
  }
  let activityIndicatorView = ActivityIndicatorView()
  private let navigationBar = NavigationBarView()
  
  // MARK: - Properties
  weak var delegate: ProfileSettingViewControllerDelegate?
  
  private let viewModel: ProfileSettingsViewModel
  
  // MARK: - Init
  init(viewModel: ProfileSettingsViewModel) {
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
    bind()
    viewModel.loadCards()
  }
  
  // MARK: - Public Methods
  
  // MARK: - Private Methods
  private func setup() {
    setupNavigationBar()
    setupTableView(with: viewModel)
    addActivityIndicatorView()
  }
  
  private func setupNavigationBar() {
    let logoutButton = UIButton()
    logoutButton.setImage(R.image.logout(), for: .normal)
    logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
    logoutButton.isHidden = viewModel.isHiddenLogoutButton
    setupNavigationBarView(title: R.string.profileSettings.title(), rightViews: [logoutButton]) { [weak self] in
      guard let self = self else { return }
      self.delegate?.profileSettingsViewControllerDidRequestGoBack(self)
    }
  }
  
  private func bind() {
    viewModel.onDidUpdateViewModels = { [weak self] in
      self?.updateViews()
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.handle(error: error)
    }
    viewModel.onDidStartCardsRequest = { [weak self] in
      self?.activityIndicatorView.isHidden = false
    }
    viewModel.onDidFinishCardsRequest = { [weak self] in
      self?.activityIndicatorView.isHidden = true
    }
    viewModel.onNeedsDeleteRowAtIndexPath = { [weak self] indexPath in
      self?.deleteRow(at: indexPath)
    }
    viewModel.onDidStartRecoveryPinCodeRequest = { [weak self] in
      self?.presentActivtiyIndicator(completion: nil)
    }
    viewModel.onDidFinishRecoveryPinCodeRequest = { [weak self] in
      self?.dismissActivityIndicator {
        self?.viewModel.finish()
      }
    }
    viewModel.onDidRequestContactWithUs = { [weak self] viewModel in
      self?.showAlert(with: viewModel)
    }
  }
  
  private func updateViews() {
    dataSource.update(viewModel: viewModel)
    tableView.reloadData()
  }
  
  private func deleteRow(at indexPath: IndexPath) {
    dataSource.update(viewModel: viewModel)
    tableView.performBatchUpdates({ [weak self] in
      self?.tableView.deleteRows(at: [indexPath], with: .automatic)
    }, completion: nil)
  }
  
  private func showLogoutAlert() {
    showAppAlert(message: R.string.profileSettings.logoutMessage(), actions: viewModel.alertLogoutActions)
  }
}

// MARK: - Actions
private extension ProfileSettingsViewController {
  @objc func didTapLogout() {
    showLogoutAlert()
  }
}
