//
//  CatalogueTopCollectionElementView.swift
//  ForwardLeasing
//

import UIKit

enum CatalogueTopCollectionElementType {
  case imageWithBackground(imageURL: URL?, backgroundColorHEX: String), roundImage(imageURL: URL?)
}

private extension Constants {
  static let roundViewSideLength: CGFloat = 80
}

protocol CatalogueTopCollectionElementViewModelProtocol {
  var type: CatalogueTopCollectionElementType { get }
  var title: String? { get }
}

class CatalogueTopCollectionElementView: UIView, Configurable {
  private let backgroundRoundView = UIView()
  private let backgroundImageView = UIImageView()
  private let foregroundImageView = UIImageView()
  private let titleLabel = ArcLabel()

  // MARK: - Init

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func prepareForReuse() {
    backgroundImageView.cancelDownloadTask()
    foregroundImageView.cancelDownloadTask()
  }

  func configure(with viewModel: CatalogueTopCollectionElementViewModelProtocol) {
    titleLabel.text = viewModel.title
    switch viewModel.type {
    case .imageWithBackground(let imageURL, let backgroundColorHEX):
      backgroundRoundView.isHidden = false
      backgroundImageView.isHidden = true
      foregroundImageView.isHidden = false
      backgroundRoundView.backgroundColor = UIColor(hexString: backgroundColorHEX)
      foregroundImageView.setImage(with: imageURL)
    case .roundImage(let imageURL):
      backgroundRoundView.isHidden = true
      backgroundImageView.isHidden = false
      foregroundImageView.isHidden = true
      backgroundImageView.setImage(with: imageURL)
    }
  }

  private func setup() {
    addTitleLabel()
    addBackgroundRoundView()
    addBackgroundImageView()
    addForegroundImageView()
    clipsToBounds = false
  }

  private func addBackgroundRoundView() {
    addSubview(backgroundRoundView)
    backgroundRoundView.makeRoundedCorners(radius: Constants.roundViewSideLength * 0.5)
    backgroundRoundView.snp.makeConstraints { make in
      make.width.height.equalTo(Constants.roundViewSideLength)
      make.bottom.equalToSuperview().inset(16)
      make.leading.trailing.equalToSuperview().inset(18)
    }
  }

  private func addBackgroundImageView() {
    addSubview(backgroundImageView)
    backgroundImageView.makeRoundedCorners(radius: Constants.roundViewSideLength * 0.5)
    backgroundImageView.snp.makeConstraints { make in
      make.edges.equalTo(backgroundRoundView)
    }
    backgroundImageView.contentMode = .scaleAspectFill
  }

  private func addForegroundImageView() {
    addSubview(foregroundImageView)
    foregroundImageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(13)
      make.bottom.equalToSuperview().inset(16)
    }
    foregroundImageView.contentMode = .scaleAspectFit
  }

  private func addTitleLabel() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().offset(4)
      make.width.height.equalTo(120)
    }
  }
}
