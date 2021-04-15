//
//  URL+QueryParameters.swift
//  ForwardLeasing
//

import Foundation

extension String {
  func appendingQueryParameters(_ parameters: [String: String]) -> String {
    guard let url = self.toURL(), var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      return self
    }

    var mutableQueryItems: [URLQueryItem] = components.queryItems ?? []
    mutableQueryItems.append(contentsOf: parameters.map { URLQueryItem(name: $0, value: $1) })
    components.queryItems = mutableQueryItems

    return components.url?.absoluteString ?? self
  }
}

extension URL {
  var queryParameters: [String: String]? {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
      let queryItems = components.queryItems else {
      return nil
    }
    return queryItems.reduce(into: [:]) { result, item in
      result[item.name] = item.value
    }
  }
}
