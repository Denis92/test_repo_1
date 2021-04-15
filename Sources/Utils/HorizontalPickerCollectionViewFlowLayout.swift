//
//  HorizontalPickerCollectionViewFlowLayout.swift
//  ForwardLeasing
//

import UIKit

class HorizontalPickerCollectionViewFlowLayout: UICollectionViewFlowLayout {
  // MARK: - Properties

  override var scrollDirection: UICollectionView.ScrollDirection {
    get {
      return super.scrollDirection
    }
    set {
      super.scrollDirection = .horizontal
    }
  }

  // MARK: - Init

  override init() {
    super.init()
    scrollDirection = .horizontal
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  // MARK: - Overrides

  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                    withScrollingVelocity velocity: CGPoint) -> CGPoint {
    var targetContentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                                        withScrollingVelocity: velocity)
    guard let collectionView = collectionView else {
      return targetContentOffset
    }
    let rect = CGRect(x: targetContentOffset.x,
                      y: 0,
                      width: collectionView.frame.width,
                      height: collectionView.frame.height)

    guard let attributes = layoutAttributesForElements(in: rect),
      !attributes.isEmpty else {
        return targetContentOffset
    }

    var nearestItemAttributes: UICollectionViewLayoutAttributes?
    var nearestDistance: CGFloat = .infinity
    attributes.forEach {
      let diff = abs(rect.midX - $0.center.x)
      if nearestDistance > diff {
        nearestDistance = diff
        nearestItemAttributes = $0
      }
    }
    if let attributes = nearestItemAttributes {
      targetContentOffset.x = attributes.frame.minX - (collectionView.frame.width - attributes.frame.width) / 2
    }
    return targetContentOffset
  }
}
