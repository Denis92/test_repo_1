//
//  UIImage+Barcode.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let ciFilterBarcodeType = "CICode128BarcodeGenerator"
  static let ciFilterBarcodeInputMessageKey = "inputMessage"
  static let ciFilterBarcodeInputQuietSpaceKey = "inputQuietSpace"
}

extension UIImage {
  static func makeBarcode(from barcodeString: String) -> UIImage? {
    let data = barcodeString.data(using: .ascii)
    guard let filter = CIFilter(name: Constants.ciFilterBarcodeType) else { return nil }
    filter.setValue(data, forKey: Constants.ciFilterBarcodeInputMessageKey)
    filter.setValue(0, forKey: Constants.ciFilterBarcodeInputQuietSpaceKey)
    guard let ciImage = filter.outputImage else { return nil }
    return UIImage(ciImage: ciImage.transformed(by: CGAffineTransform(scaleX: 4, y: 4)))
  }
}
