//
//  ProductDetailsItemViewModel.swift
//  ForwardLeasing
//

import UIKit

enum ProductDetailsItemType {
  case imageCarousel
  case colorPicker
  case propertyPicker
  case programPicker
  case monthlyPayment
  case advantages
  case features
  case fullFeatures
  case divider
}

protocol ProductDetailsItemViewModel {
  var type: ProductDetailsItemType { get }
  var customSpacing: CGFloat? { get }
}
