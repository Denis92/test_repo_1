//
//  PointAvailabilityUtil.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

private extension Constants {
  static let availabilityCalculationQueue = "com.forwardleasing.availability.calculation"
}

struct PointAvailabilityUtil {
  private let queue = DispatchQueue(label: Constants.availabilityCalculationQueue, attributes: .concurrent)
  
  func calculateAvailability(goodCode: String?, for storePoints: [StorePointInfo]) -> Guarantee<[StorePointInfo]> {
    guard let goodCode = goodCode else {
      return Guarantee.value(storePoints)
    }
    return Guarantee { seal in
      queue.async {
        let points = getAvailablePoints(goodCode: goodCode, for: storePoints)
        seal(points)
      }
    }
  }
  
  private func getAvailablePoints(goodCode: String, for storePoints: [StorePointInfo]) -> [StorePointInfo] {
    var points: [StorePointInfo] = []
    for var storePoint in storePoints {
      guard let goods = storePoint.goods else {
        points.append(storePoint)
        continue
      }
      storePoint.hasRequiredGood = goods.contains(where: { $0.goodCode == goodCode })
      points.append(storePoint)
    }
    return points
  }
}
