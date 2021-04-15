//
//  AppActivityMonitoring.swift
//  ForwardLeasing
//

import UIKit

protocol AppActivityMonitoring: AnyObject {
  var appDidBecomeActiveNotificationToken: NSObjectProtocol? { get set }
  var appWillResignActiveNotificationToken: NSObjectProtocol? { get set }

  func subscribeForAppActivityNotifications()
  func unsubscribeFromAppActivityNotifications()

  func appDidBecomeActive()
  func appWillResignActive()
}

extension AppActivityMonitoring {
  func subscribeForAppActivityNotifications() {
    unsubscribeFromAppActivityNotifications()
    let notificationCenter = NotificationCenter.default
    appDidBecomeActiveNotificationToken = notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                                         object: nil, queue: .main) { [weak self] _ in
       self?.appDidBecomeActive()
    }
    appWillResignActiveNotificationToken = notificationCenter.addObserver(forName: UIApplication.willResignActiveNotification,
                                                                          object: nil, queue: .main) { [weak self] _ in
       self?.appWillResignActive()
    }
  }

  func unsubscribeFromAppActivityNotifications() {
    removeObserver(appDidBecomeActiveNotificationToken)
    removeObserver(appWillResignActiveNotificationToken)

    appDidBecomeActiveNotificationToken = nil
    appWillResignActiveNotificationToken = nil
  }

  func appDidBecomeActive() {
    // Do nothing by default
  }

  func appWillResignActive() {
    // Do nothing by default
  }

  private func removeObserver(_ token: NSObjectProtocol?) {
    guard let token = token else { return }
    NotificationCenter.default.removeObserver(token)
  }
}
