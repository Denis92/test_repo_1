//
//  ProductFeaturesView.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let horizontalInset: CGFloat = 20
  static let itemSize: CGSize = CGSize(width: 140, height: 320)
  static let interItemSpacing: CGFloat = 15
}

class ProductFeaturesView: UIView, Configurable {
  private typealias FeatureCell = CommonConfigurableCollectionViewCell<ProductFeatureCarouselItemView>
  
  // MARK: - Properties
  
  private let stackView = UIStackView()
  private lazy var featuresCollectionView = UICollectionView(frame: .zero,
                                                             collectionViewLayout: featuresCollectionLayout)
  
  private let featuresCollectionLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: Constants.horizontalInset,
                                       bottom: 0, right: Constants.horizontalInset)
    layout.itemSize = Constants.itemSize
    layout.minimumInteritemSpacing = Constants.interItemSpacing
    layout.scrollDirection = .horizontal
    return layout
  }()
  private let dataSource = CollectionViewDataSource(lineSpacing: Constants.interItemSpacing,
                                                    interItemSpacing: Constants.interItemSpacing,
                                                    itemSize: Constants.itemSize)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ProductFeaturesViewModel) {
    dataSource.setup(collectionView: featuresCollectionView, viewModel: viewModel)
    viewModel.mainFeatures.forEach { feature in
      stackView.addArrangedSubview(createFeatureRowView(title: feature.title,
                                                        content: feature.content))
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupStackView()
    setupCollectionView()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 10
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupCollectionView() {
    addSubview(featuresCollectionView)
    
    featuresCollectionView.backgroundColor = .clear
    featuresCollectionView.showsHorizontalScrollIndicator = false
    featuresCollectionView.register(FeatureCell.self, forCellWithReuseIdentifier: FeatureCell.reuseIdentifier)
    
    featuresCollectionView.snp.makeConstraints { make in
      make.top.equalTo(stackView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(32)
      make.height.equalTo(320)
    }
  }
  
  // MARK: - Private methods
  
  private func createFeatureRowView(title: String?, content: String?) -> UIView {
    let containerView = UIStackView()
    containerView.spacing = 15
    containerView.alignment = .top
    containerView.distribution = .fillEqually
    containerView.axis = .horizontal
    
    let leftLabel = AttributedLabel(textStyle: .textRegular)
    leftLabel.textColor = .shade70
    leftLabel.numberOfLines = 0
    leftLabel.text = title
    containerView.addArrangedSubview(leftLabel)
    
    let rightLabel = AttributedLabel(textStyle: .textRegular)
    rightLabel.textColor = .base1
    rightLabel.numberOfLines = 0
    rightLabel.text = content
    containerView.addArrangedSubview(rightLabel)
    
    return containerView
  }
}
