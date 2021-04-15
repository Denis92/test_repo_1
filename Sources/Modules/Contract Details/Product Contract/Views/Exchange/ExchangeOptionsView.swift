//
//  ExchangeOptionsView.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let itemSize = CGSize(width: UIScreen.main.bounds.width - 45, height: 130)
}

typealias ExchangeOptionsCell = CommonContainerTableViewCell<ExchangeOptionsView>

class ExchangeOptionsView: UIView, Configurable {
  private typealias OptionCell = CommonConfigurableCollectionViewCell<ExchangeOptionsItemView>
  
  // MARK: - Properties
  
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let remainingPaymentsLabel = AttributedLabel(textStyle: .textRegular)
  private let singleExchangeOptionView = ExchangeOptionsItemView()
  
  private let collectionViewLayout: UICollectionViewLayout = {
    let layout = ExchangeOptionsFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 8
    layout.minimumLineSpacing = 8
    layout.itemSize = Constants.itemSize
    layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    return layout
  }()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
  
  private let dataSource = CollectionViewDataSource(lineSpacing: 8, interItemSpacing: 8,
                                                    itemSize: Constants.itemSize)
  
  private var onDidTapSingleExchangeOptionView: (() -> Void)?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ExchangeOptionsViewModel) {
    titleLabel.text = viewModel.title
    remainingPaymentsLabel.text = viewModel.remainingPaymentsText
    
    if viewModel.collectionCellViewModels.count > 1 {
      collectionView.isHidden = false
      singleExchangeOptionView.isHidden = true
      dataSource.setup(collectionView: collectionView, viewModel: viewModel)
      collectionView.reloadData()
    } else if let itemViewModel = viewModel.collectionCellViewModels.first as? ExchangeOptionsItemViewModel {
      collectionView.isHidden = true
      singleExchangeOptionView.isHidden = false
      singleExchangeOptionView.configure(with: itemViewModel)
      onDidTapSingleExchangeOptionView = { [weak itemViewModel] in
        itemViewModel?.selectCollectionCell()
      }
    }
  }
  
  // MARK: - Actions
  
  @objc private func didTapSingleExchangeOptionView() {
    onDidTapSingleExchangeOptionView?()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupTitleLabel()
    setupCollectionView()
    setupRemainingPaymentsLabel()
    setupSingleExchangeOptionView()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.textColor = .base1
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupCollectionView() {
    addSubview(collectionView)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.decelerationRate = .fast
    collectionView.register(OptionCell.self, forCellWithReuseIdentifier: OptionCell.reuseIdentifier)
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(130)
    }
  }
  
  private func setupRemainingPaymentsLabel() {
    addSubview(remainingPaymentsLabel)
    remainingPaymentsLabel.numberOfLines = 0
    remainingPaymentsLabel.textColor = .base1
    remainingPaymentsLabel.snp.makeConstraints { make in
      make.top.equalTo(collectionView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
    }
  }
  
  private func setupSingleExchangeOptionView() {
    addSubview(singleExchangeOptionView)
    singleExchangeOptionView.isHidden = true
    singleExchangeOptionView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                         action: #selector(didTapSingleExchangeOptionView)))
    singleExchangeOptionView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(130)
    }
  }
}
