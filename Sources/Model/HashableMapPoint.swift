//
//  HashableMapPoint.swift
//  ForwardLeasing
//

import Foundation
import YandexMapsMobile

struct HashableMapPoint: Hashable {
  let latitude: Double
  let longitude: Double
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(latitude)
    hasher.combine(longitude)
  }
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    let equality = lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
    let sortEquality = [lhs.latitude, lhs.longitude] == [rhs.latitude, rhs.longitude]
    return equality && sortEquality
  }
}
