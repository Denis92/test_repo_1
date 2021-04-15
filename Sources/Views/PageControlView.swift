//
//  PageControlView.swift
//  ForwardLeasing
//

import UIKit

class PageControlView: UIView {
  // MARK: - Properties
  
  var numberOfPages: Int = 0 {
    didSet {
      updatePageControlDots()
    }
  }
  
  var currentPage: Int = 0 {
    didSet {
      updateCurrentPage()
    }
  }
  
  private let scrollView = UIScrollView()
  private let containerView = UIView()
  private let stackView = UIStackView()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupScrollView()
    setupContainerView()
    setupStackView()
  }
  
  private func setupScrollView() {
    addSubview(scrollView)
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.contentInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(16)
    }
  }
  
  private func setupContainerView() {
    scrollView.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalToSuperview()
      make.width.greaterThanOrEqualToSuperview().offset(-12)
    }
  }
  
  private func setupStackView() {
    containerView.addSubview(stackView)
    stackView.spacing = 4
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.greaterThanOrEqualToSuperview().priority(250)
    }
  }
  
  // MARK: - Private methods
  
  private func updatePageControlDots() {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    for _ in 1...numberOfPages {
      let dot = UIView()
      
      dot.backgroundColor = .shade60
      dot.makeRoundedCorners(radius: 3)
      dot.snp.makeConstraints { make in
        make.width.height.equalTo(6)
      }
      
      stackView.addArrangedSubview(dot)
    }
    
    stackView.arrangedSubviews.element(at: currentPage)?.backgroundColor = .accent
  }
  
  private func updateCurrentPage() {
    if stackView.arrangedSubviews.element(at: currentPage)?.backgroundColor == .accent {
      return
    }
    
    UIView.animate(withDuration: 0.2) {
      self.stackView.arrangedSubviews.forEach { $0.backgroundColor = .shade60 }
      self.stackView.arrangedSubviews.element(at: self.currentPage)?.backgroundColor = .accent
    }
    
    if let dotView = stackView.arrangedSubviews.element(at: currentPage) {
      scrollView.scrollRectToVisible(dotView.frame, animated: true)
    }
  }
}
