//
//  ExchangeOptionsFlowLayout.swift
//  ForwardLeasing
//

import UIKit

class ExchangeOptionsFlowLayout: UICollectionViewFlowLayout {
  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                    withScrollingVelocity velocity: CGPoint) -> CGPoint {
    guard let collectionView = self.collectionView else {
      return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                       withScrollingVelocity: velocity)
    }
    
    let pageWidth = self.itemSize.width + 8
    let approximatePage = collectionView.contentOffset.x / pageWidth
    
    let targetPage: CGFloat
    if velocity.x == 0 {
      targetPage = round(approximatePage)
    } else if velocity.x < 0 {
      targetPage = floor(approximatePage)
    } else {
      targetPage = ceil(approximatePage)
    }

    let flickVelocity = velocity.x * 0.3
    let flickedPages = abs(round(flickVelocity)) <= 1 ? 0 : round(flickVelocity)
    let newHorizontalOffset = ((targetPage + flickedPages) * pageWidth) - collectionView.contentInset.left
  
    return CGPoint(x: newHorizontalOffset, y: proposedContentOffset.y)
  }
}
