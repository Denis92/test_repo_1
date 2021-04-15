//
//  SubcatogiryCellView.swift
//  ForwardLeasing
//

import UIKit

class SubcategoryCellView: UIView, Configurable {
  private var viewModel: SubcategoryCellViewModel?
  
  private let imageView = UIImageView()
  private let titleLabel = AttributedLabel(textStyle: .title2Regular)
  private let transitionImage = UIImageView()
  private let dividerView = UIView()
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with viewModel: SubcategoryCellViewModel) {
    self.viewModel = viewModel
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    addGestureRecognizer(gestureRecognizer)
    imageView.setImage(with: viewModel.imageURL)
    titleLabel.text = viewModel.title
  }
  
  // MARK: - Setup
  private func setup() {
    setupImageView()
    setupTransitionImage()
    setupTitleLabel()
    setupDividerView()
  }
  
  private func setupImageView() {
    addSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints { make in
      make.size.equalTo(40)
      make.leading.centerY.equalToSuperview()
    }
  }
  
  private func setupTransitionImage() {
    addSubview(transitionImage)
    transitionImage.image = R.image.disclosureIndicatorIcon()
    transitionImage.contentMode = .center
    transitionImage.snp.makeConstraints { make in
      make.size.equalTo(24)
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(imageView.snp.trailing).offset(15)
      make.trailing.equalTo(transitionImage.snp.leading).offset(-9)
      make.top.bottom.equalToSuperview().inset(18)
    }
  }
  
  private func setupDividerView() {
    addSubview(dividerView)
    dividerView.backgroundColor = .shade40
    dividerView.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(0.5)
    }
  }

  // MARK: - Actions

  @objc private func handleTap() {
    viewModel?.selectSubcategory()
  }
}
