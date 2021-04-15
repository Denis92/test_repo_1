//
//  KeyboardVisibilityHandler.swift
//  ForwardLeasing
//

import UIKit

protocol KeyboardVisibilityHandler: AnyObject {
  var keyboardWillShowNotificationToken: NSObjectProtocol? { get set }
  var keyboardWillHideNotificationToken: NSObjectProtocol? { get set }
  var keyboardWillChangeFrameNotificationToken: NSObjectProtocol? { get set }
  
  func subscribeForKeyboardNotifications()
  func unsubscribeFromKeyboardNotifications()
  
  func keyboardWillShow(_ keyboardInfo: KeyboardInfo)
  func keyboardWillHide(_ keyboardInfo: KeyboardInfo)
  func keyboardWillChangeFrame(_ keyboardInfo: KeyboardInfo)
}

extension KeyboardVisibilityHandler {
  func keyboardWillShow(_ keyboardInfo: KeyboardInfo) {}
  func keyboardWillHide(_ keyboardInfo: KeyboardInfo) {}
  func keyboardWillChangeFrame(_ keyboardInfo: KeyboardInfo) {}
}

extension KeyboardVisibilityHandler where Self: NSObject {
  func subscribeForKeyboardNotifications() {
    let notificationCenter = NotificationCenter.default
    keyboardWillShowNotificationToken = notificationCenter
      .addObserver(forName: UIResponder.keyboardWillShowNotification,
                   object: nil, queue: .main) { [weak self] notification in
      self?.keyboardWillShow(KeyboardInfo(notification: notification))
    }
    
    keyboardWillHideNotificationToken = notificationCenter
      .addObserver(forName: UIResponder.keyboardWillHideNotification,
                   object: nil, queue: .main) { [weak self] notification in
      self?.keyboardWillHide(KeyboardInfo(notification: notification))
    }
    
    keyboardWillChangeFrameNotificationToken = notificationCenter
    .addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                 object: nil, queue: .main) { [weak self] notification in
      self?.keyboardWillChangeFrame(KeyboardInfo(notification: notification))
    }
  }
  
  func unsubscribeFromKeyboardNotifications() {
    removeObserver(keyboardWillShowNotificationToken)
    removeObserver(keyboardWillHideNotificationToken)
    removeObserver(keyboardWillChangeFrameNotificationToken)
    
    keyboardWillShowNotificationToken = nil
    keyboardWillHideNotificationToken = nil
    keyboardWillChangeFrameNotificationToken = nil
  }
  
  private func removeObserver(_ token: NSObjectProtocol?) {
    guard let token = token else { return }
    NotificationCenter.default.removeObserver(token)
  }
  
}

struct KeyboardInfo {
  let animationDuration: TimeInterval
  let animationCurve: UIView.AnimationCurve
  let frameBegin: CGRect
  let frameEnd: CGRect
  
  var keyboardVisibleHeight: CGFloat {
    return UIScreen.main.bounds.height - frameEnd.origin.y
  }
  
  init(notification: Notification) {
    let userInfo = notification.userInfo
    
    let animationDurationKey = UIResponder.keyboardAnimationDurationUserInfoKey
    animationDuration = (userInfo?[animationDurationKey] as? TimeInterval) ?? 0
    
    let animationCurveKey = UIResponder.keyboardAnimationCurveUserInfoKey
    let animationCurveValue = (userInfo?[animationCurveKey] as? Int) ?? 0
    animationCurve = UIView.AnimationCurve(rawValue: animationCurveValue) ?? .linear
    
    let frameBeginKey = UIResponder.keyboardFrameBeginUserInfoKey
    let frameBeginValue = userInfo?[frameBeginKey] as? NSValue
    frameBegin = frameBeginValue?.cgRectValue ?? .zero
    
    let frameEndKey = UIResponder.keyboardFrameEndUserInfoKey
    let frameEndValue = userInfo?[frameEndKey] as? NSValue
    frameEnd = frameEndValue?.cgRectValue ?? .zero
  }
}
