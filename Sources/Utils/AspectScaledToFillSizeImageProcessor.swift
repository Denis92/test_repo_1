//
//  AspectScaledToFillSizeImageProcessor.swift
//  ForwardLeasing
//

import Kingfisher

public enum AspectScaledType: Int {
  case toFit, toFill
}

public struct AspectScaledToFillSizeImageProcessor: ImageProcessor {
  public let identifier: String
  private let targetSize: CGSize

  init(targetSize: CGSize) {
    self.targetSize = targetSize
    let height = targetSize.height
    let width = targetSize.width
    self.identifier = "AspectScaledToFillSizeImageProcessor-height-\(height)-width-\(width)"
  }

  public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
    switch item {
    case .image(let image):
      return image.imageAspectScaled(.toFill, size: targetSize)
    case .data:
      return (DefaultImageProcessor.default |> self).process(item: item, options: options)
    }
  }
}

extension UIImage {
  public var containsAlphaComponent: Bool {
    let alphaInfo = cgImage?.alphaInfo

    return (alphaInfo == .first ||
            alphaInfo == .last ||
            alphaInfo == .premultipliedFirst ||
            alphaInfo == .premultipliedLast)
  }

  public var isOpaque: Bool { return !containsAlphaComponent }

  public func imageAspectScaled(_ scaledType: AspectScaledType = .toFill, size: CGSize) -> UIImage? {
    let imageAspectRatio = self.size.width / self.size.height
    let canvasAspectRatio = size.width / size.height

    var resizeFactor: CGFloat

    if imageAspectRatio > canvasAspectRatio {
      resizeFactor = size.height / self.size.height
    } else {
      resizeFactor = size.width / self.size.width
    }
    let scale = UIScreen.main.scale
    let scaledTargetSize = CGSize(width: size.width * scale, height: size.height * scale)

    resizeFactor *= scale

    let scaledSize = CGSize(width: self.size.width * resizeFactor, height: self.size.height * resizeFactor)
    let origin = CGPoint(x: (scaledTargetSize.width - scaledSize.width) / 2.0,
                         y: (scaledTargetSize.height - scaledSize.height) / 2.0)

    UIGraphicsBeginImageContextWithOptions(scaledTargetSize, isOpaque, 1)
    draw(in: CGRect(origin: origin, size: scaledSize))

    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return scaledImage
  }
}
