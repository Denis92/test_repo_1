//
//  OnboardingPageControlView.swift
//  ForwardLeasing
//

import UIKit

class OnboardingPageControlView: UIView {
  // MARK: - Subviews
  private let pageControlStackView = UIStackView()
  
  var numberOfPages = 0 {
    didSet {
      setupPageControl()
    }
  }
  
  var currentPage = 0 {
    didSet {
      setCurrentPage()
    }
  }
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func setupPageControl() {
    addSubview(pageControlStackView)
    pageControlStackView.spacing = 4
    pageControlStackView.snp.makeConstraints { make in
      make.height.equalTo(4)
    }
    
    for _ in 0..<numberOfPages {
      let indicator = UIView()
      indicator.makeRoundedCorners(radius: 2)
      indicator.backgroundColor = .accent2Light
      indicator.snp.makeConstraints { make in
        make.width.equalTo(34)
      }
      pageControlStackView.addArrangedSubview(indicator)
    }
  }
  
  private func setCurrentPage() {
    self.pageControlStackView.arrangedSubviews.forEach { $0.backgroundColor = .accent2Light }
    self.pageControlStackView.arrangedSubviews.element(at: self.currentPage)?.backgroundColor = .base2
  }
}
