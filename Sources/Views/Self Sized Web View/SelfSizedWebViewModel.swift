//
//  SelfSizedWebViewModel.swift
//  ForwardLeasing
//

import Foundation

// TODO: - Remove temporary logic
enum HTMLInfoType {
  case video
  case digits

  var url: URL? {
    return Bundle.main.url(forResource: fileName, withExtension: "html")
  }

  private var fileName: String {
    switch self {
    case .video:
      return "video"
    case .digits:
      return "digits"
    }
  }
}

class SelfSizedWebViewModel: SelfSizedWebViewModelProtocol {
  var infoURLRequest: URLRequest? {
    guard let url = url else {
      return nil
    }
    return URLRequest(url: url)
  }

  private let url: URL?

  init(htmlInfoType: HTMLInfoType) {
    self.url = htmlInfoType.url
  }

}
