//
//  UIImageView+SetImage.swift
//  ForwardLeasing
//

import UIKit
import Kingfisher

enum ImageDownloadError: Error {
  case cancelled, empty
}

extension UIImageView {
  func setImage(with url: URL?, placeholder: UIImage? = nil, imageProcessor: ImageProcessor? = nil, authToken: String? = nil,
                completion: ((Result<UIImage, Error>) -> Void)? = nil) {
    guard let url = url else {
      completion?(.failure(ImageDownloadError.empty))
      return
    }
    var options: KingfisherOptionsInfo?
    if let processor = imageProcessor {
      options = [.processor(processor)]
    }
    if let token = authToken {
      let modifier = AnyModifier { request in
        var modifiedRequest = request
        modifiedRequest.setValue("\(NetworkService.HeaderKeys.bearer) \(token)",
                                 forHTTPHeaderField: NetworkService.HeaderKeys.authorization)
        return modifiedRequest
      }
      if options == nil {
        options = [.requestModifier(modifier)]
      } else {
        options?.append(.requestModifier(modifier))
      }
    }
    kf.setImage(with: url, placeholder: placeholder, options: options, progressBlock: nil) { result in
      switch result {
      case .success(let value):
        completion?(.success(value.image))
      case .failure(let error):
        if case KingfisherError.requestError(let reason) = error,
           case KingfisherError.RequestErrorReason.taskCancelled = reason {
          completion?(.failure(ImageDownloadError.cancelled))
        } else if case KingfisherError.imageSettingError(let reason) = error,
                  case KingfisherError.ImageSettingErrorReason.notCurrentSourceTask = reason {
          completion?(.failure(ImageDownloadError.cancelled))
        } else {
          completion?(.failure(error))
        }
      }
    }
  }
  
  func cancelDownloadTask() {
    kf.cancelDownloadTask()
  }
  
  func setImageAndScaleToFill(with url: URL?,
                              targetSize: CGSize,
                              placeholder: UIImage? = nil,
                              completion: ((Result<UIImage, Error>) -> Void)? = nil) {
    contentMode = .scaleAspectFill
    let processor = AspectScaledToFillSizeImageProcessor(targetSize: targetSize)
    setImage(with: url, placeholder: placeholder, imageProcessor: processor, completion: completion)
  }
}

struct ImageDownloadUtility {
  static func prefetchImage(with url: URL?, targetSize: CGSize) {
    guard let url = url else {
      return
    }

    let cache = ImageCache.default

    let processor = AspectScaledToFillSizeImageProcessor(targetSize: targetSize)

    guard !cache.isCached(forKey: url.absoluteString, processorIdentifier: processor.identifier) else {
      return
    }

    let options: KingfisherOptionsInfo = [.processor(processor)]
    DispatchQueue.global().async {
      ImagePrefetcher(urls: [url], options: options).start()
    }
  }
}
