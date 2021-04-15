//
//  CatalogueTopCollectionView.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let cellWidth: CGFloat = 116
  static let cellHeight: CGFloat = 118
  static let interitemSpacing: CGFloat = 0
}

typealias CatalogueCollectionViewCell = CommonConfigurableCollectionViewCell<CatalogueTopCollectionElementView>

class CatalogueTopCollectionView: UIView, Configurable {
  // MARK: - Properties

  private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = Constants.interitemSpacing
    layout.itemSize = CGSize(width: Constants.cellWidth, height: Constants.cellHeight)
    return layout
  }()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
  private lazy var dataSource = CollectionViewDataSource(lineSpacing: Constants.interitemSpacing,
                                                         interItemSpacing: Constants.interitemSpacing,
                                                         itemSize: CGSize(width: Constants.cellWidth,
                                                                          height: Constants.cellHeight))

  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: Constants.cellHeight)
  }

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure

  func configure(with viewModel: CommonCollectionViewModel) {
    dataSource.setup(collectionView: collectionView, viewModel: viewModel)
    collectionView.reloadData()
  }

  // MARK: - Setup

  private func setup() {
    setupCollectionView()
  }

  private func setupCollectionView() {
    addSubview(collectionView)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.clipsToBounds = false
    collectionView.register(CatalogueCollectionViewCell.self,
                            forCellWithReuseIdentifier: CatalogueCollectionViewCell.reuseIdentifier)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(Constants.cellHeight)
    }
  }
}
