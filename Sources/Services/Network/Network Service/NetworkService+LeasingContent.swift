//
//  NetworkService+LeasingContent.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/14/21.
//

import Foundation
import PromiseKit

extension NetworkService: LeasingContentNetworkProtocol {
  func getMainpageData() -> Promise<LeasingContentResponse> {
    baseRequest(requestType: .leasingContent, method: .get, url: URLFactory.LeasingContent.mainpage())
  }
}
