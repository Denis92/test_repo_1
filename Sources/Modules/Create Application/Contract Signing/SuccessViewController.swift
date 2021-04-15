//
//  SuccessViewController.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let screenShowingInterval: TimeInterval = 2
}

enum SuccessViewControllerType {
  case success(title: String?)
  case fail(title: String?, subtitle: String?)
  
  var isSuccess: Bool {
    switch self {
    case .success:
      return true
    case .fail:
      return false
    }
  }
  
  var title: String? {
    switch self {
    case .success(let title), .fail(let title, _):
      return title
    }
  }
  
  var subtitle: String? {
    switch self {
    case .fail(_, let subtitle):
      return subtitle
    default:
      return nil
    }
  }
}

class SuccessViewController: BaseViewController, NavigationBarHiding {
  // MARK: - Properties
  
  private let stackView = UIStackView()
  private let imageView = UIImageView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let subtitleLabel = AttributedLabel(textStyle: .textRegular)
  
  private var onDidFinish: (() -> Void)?
  private let type: SuccessViewControllerType
  
  // MARK: - Init
  
  init(type: SuccessViewControllerType, onDidFinish: (() -> Void)?) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
    titleLabel.text = type.title
    subtitleLabel.text = type.subtitle
    self.onDidFinish = onDidFinish
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.screenShowingInterval) {
      self.onDidFinish?()
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupStackView()
    setupImageView()
    setupTitleLabel()
    setupSubtitleLabel()
  }
  
  private func setupStackView() {
    view.addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 32
    stackView.alignment = .center
    stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.centerY.equalToSuperview()
    }
  }
  
  private func setupImageView() {
    stackView.addArrangedSubview(imageView)
    imageView.image = type.isSuccess ? R.image.successIcon() : R.image.failedIcon()
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints { make in
      make.size.equalTo(121)
    }
  }
  
  private func setupTitleLabel() {
    stackView.addArrangedSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    stackView.setCustomSpacing(16, after: titleLabel)
  }
  
  private func setupSubtitleLabel() {
    stackView.addArrangedSubview(subtitleLabel)
    subtitleLabel.numberOfLines = 0
    subtitleLabel.textAlignment = .center
  }
}
