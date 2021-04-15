//
//  NetworkService+Subscription.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

extension NetworkService: SubscriptionsNetworkProtocol {
  func subscriptionList() -> Promise<[BoughtSubscription]> {
    return baseRequest(requestType: .common, method: .get, url: URLFactory.Subscription.subscriptionList)
  }
}
