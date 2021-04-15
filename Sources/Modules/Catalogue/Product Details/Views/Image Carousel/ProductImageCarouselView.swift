//
//  ProductImageCarouselView.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let horizontalInset: CGFloat = 40
  static let interItemSpacing: CGFloat = 25
  static let cellSideLength = UIScreen.main.bounds.width - horizontalInset * 2
}

class ProductImageCarouselView: UIView, Configurable {
  typealias ViewModel = ProductImageCarouselViewModel
  typealias ImageCell = CommonConfigurableCollectionViewCell<ProductImageCarouselItemView>
  
  // MARK: - Properties
  
  private var viewModel: ProductImageCarouselViewModel?
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
  
  private let pageControl = PageControlView()
  private let collectionLayout: ProductImagCarouselFlowLayout = {
    let layout = ProductImagCarouselFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0,
                                       right: Constants.horizontalInset)
    layout.itemSize = CGSize(width: Constants.cellSideLength, height: Constants.cellSideLength)
    layout.minimumLineSpacing = Constants.interItemSpacing
    layout.scrollDirection = .horizontal
    return layout
  }()
  
  private let dataSource = CollectionViewDataSource(lineSpacing: 0, interItemSpacing: 0,
                                                    itemSize: CGSize(width: Constants.cellSideLength,
                                                                     height: Constants.cellSideLength))
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  func configure(with viewModel: ProductImageCarouselViewModel) {
    self.viewModel = viewModel
    dataSource.setup(collectionView: collectionView, viewModel: viewModel)
    collectionView.decelerationRate = .fast
    pageControl.numberOfPages = viewModel.itemsCount
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupCollectionView()
    setupPageControl()
  }
  
  private func setupCollectionView() {
    addSubview(collectionView)
    
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
    
    collectionLayout.onWillSnapToPage = { [weak self] page in
      var currentPage = page
      if currentPage < 0 {
        currentPage = 0
      }
      if currentPage > (self?.viewModel?.itemsCount ?? 0) - 1 {
        currentPage = (self?.viewModel?.itemsCount ?? 0) - 1
      }
      self?.pageControl.currentPage = currentPage
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(Constants.cellSideLength)
    }
  }
  
  private func setupPageControl() {
    addSubview(pageControl)
    pageControl.snp.makeConstraints { make in
      make.top.equalTo(collectionView.snp.bottom).offset(25)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
}
