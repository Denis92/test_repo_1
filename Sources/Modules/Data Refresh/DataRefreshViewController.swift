//
//  DataRefreshViewController.swift
//  ForwardLeasing
//

import UIKit

protocol DataRefreshViewModelProtocol: class {
  var onDidStartRequest: (() -> Void)? { get set }
  var onDidFinishRequest: (() -> Void)? { get set }
  var onDidRequestToShowErrorBanner: ((Error) -> Void)? { get set }

  func refresh()
}

class DataRefreshViewController: BaseViewController, NavigationBarHiding {
  // MARK: - Properties
  private let viewModel: DataRefreshViewModelProtocol
  private let activityIndicatorView = ActivityIndicatorView(style: .white, color: .accent, title: R.string.common.loading(), spacing: 32)

  // MARK: - Init
  init(viewModel: DataRefreshViewModelProtocol) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
    bindToViewModel()
    viewModel.refresh()
  }

  // MARK: - Private methods
  private func setup() {
    setupActivityIndicatorView()
  }

  private func setupActivityIndicatorView() {
    view.addSubview(activityIndicatorView)
    activityIndicatorView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  private func bindToViewModel() {
    viewModel.onDidStartRequest = { [weak self] in
      self?.activityIndicatorView.startAnimating()
    }
    viewModel.onDidFinishRequest = { [weak self] in
      self?.activityIndicatorView.stopAnimating()
    }
    viewModel.onDidRequestToShowErrorBanner = { [weak self] error in
      self?.showErrorBanner(error: error)
    }
  }

}
