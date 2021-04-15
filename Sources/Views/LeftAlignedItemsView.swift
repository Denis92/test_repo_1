//
//  LeftAlignedItemsView.swift
//  ForwardLeasing
//

import UIKit

class LeftAlignedItemsView: UIView {
  typealias LeftAlignedItem = UIView & EstimatedSizeHaving
  // MARK: - Properties
  
  private let containerView = UIView()
  
  private let spacing: CGFloat
  private let containerWidth: CGFloat?
  
  private var maxY: CGFloat = 0
  private var maxX: CGFloat = 0
  private var maxRowHeight: CGFloat = 0
  
  // MARK: - Init
  
  init(spacing: CGFloat = 0, containerWidth: CGFloat? = nil) {
    self.spacing = spacing
    self.containerWidth = containerWidth
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setup() {
    addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(0)
    }
  }
  
  // MARK: - Public methods
  
  func addArrangedSubview(_ view: LeftAlignedItem) {
    let width = view.estimatedSize.width > 0 ? view.estimatedSize.width : view.intrinsicContentSize.width
    let height = view.estimatedSize.height > 0 ? view.estimatedSize.height : view.intrinsicContentSize.height
    let size = CGSize(width: width, height: height)
    addArrangedSubview(view, with: size)
  }
  
  func addArrangedSubview(_ view: UIView, with size: CGSize) {
    containerView.addSubview(view)
    
    let width = size.width
    let height = size.height
    
    if maxX + width <= (containerWidth ?? self.bounds.width) {
      view.snp.makeConstraints { make in
        make.top.equalTo(maxY)
        make.leading.equalTo(maxX)
      }
      
      maxX += width + spacing
      maxRowHeight = max(maxRowHeight, height)
    } else {
      maxY += maxRowHeight + spacing
      maxRowHeight = height
      
      view.snp.makeConstraints { make in
        make.top.equalTo(maxY)
        make.leading.equalTo(0)
      }
      
      maxX = width + spacing
    }
    
    containerView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
      make.bottom.equalTo(view.snp.bottom)
    }
  }
  
  func prepare() {
    layoutIfNeeded()
    containerView.subviews.forEach { $0.removeFromSuperview() }
    maxY = 0
    maxX = 0
  }
}
