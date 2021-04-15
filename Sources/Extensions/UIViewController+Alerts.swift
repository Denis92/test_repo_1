//
//  UIViewController+Alerts.swift
//  ForwardLeasing
//

import UIKit

struct AlertAction {
  let title: String
  let buttonType: StandardButtonType
  let action: (() -> Void)?
}

struct AlertViewModel {
  let title: String?
  let message: String?
  let prefferedStyle: UIAlertController.Style
  let actions: [AlertActionViewModel]
  
  init(title: String?,
       messages: [String],
       prefferedStyle: UIAlertController.Style = .alert,
       actions: [AlertActionViewModel]? = nil) {
    self.title = title
    if messages.count <= 1 {
      self.message = messages.first ?? nil
    } else {
      self.message = messages.map { "• " + $0 }.joined(separator: "\n")
    }
    self.prefferedStyle = prefferedStyle
    self.actions = actions ?? [AlertActionViewModel(title: R.string.common.ok(), style: .default, action: nil)]
  }
  
  init(title: String? = nil,
       message: String? = nil,
       prefferedStyle: UIAlertController.Style = .alert,
       actions: [AlertActionViewModel] = []) {
    self.title = title
    self.message = message
    self.prefferedStyle = prefferedStyle
    self.actions = actions
  }
}

struct AlertActionViewModel {
  let title: String?
  let style: UIAlertAction.Style
  let action: (() -> Void)?
  
  init(title: String?,
       style: UIAlertAction.Style = .default,
       action: (() -> Void)? = nil) {
    self.title = title
    self.style = style
    self.action = action
  }
}

extension UIViewController {
  func showAlert(withTitle title: String?,
                 message: String? = nil,
                 okButtonTitle: String = R.string.common.ok(),
                 isOkButtonDestructive: Bool = false,
                 cancelButtonTitle: String? = nil,
                 tintColor: UIColor = .systemBlue,
                 onCancelTap: (() -> Void)? = nil,
                 onTap: (() -> Void)? = nil) {
    let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)

    if let cancelButtonTitle = cancelButtonTitle {
      alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
        onCancelTap?()
      })
    }
    let okButtonStyle: UIAlertAction.Style = isOkButtonDestructive ? .destructive : .default
    alertController.addAction(UIAlertAction(title: okButtonTitle, style: okButtonStyle) { _ in
      onTap?()
    })
    showAlert(alertController, tintColor: tintColor)
  }
  
  func showAlert(with viewModel: AlertViewModel,
                 tintColor: UIColor = .systemBlue) {
    let alertController = UIAlertController(title: viewModel.title,
                                            message: viewModel.message,
                                            preferredStyle: viewModel.prefferedStyle)
    for action in viewModel.actions {
      alertController.addAction(UIAlertAction(title: action.title,
                                              style: action.style) { _ in
                                                action.action?()
      })
    }
    showAlert(alertController, tintColor: tintColor)
  }
  
  func showAppAlert(message: String, actions: [AlertAction] = []) {
    let alertController = BaseAlertViewController()
    let popupView = PopupAlertView(message)
    if !actions.isEmpty {
      actions.forEach {
        let button = makeAppAlertButton(alertAction: $0, for: alertController)
        popupView.addButton(button)
      }
    } else {
      let button = makeAppAlertButton(alertAction: AlertAction(title: R.string.common.ok(),
                                                               buttonType: .primary, action: nil),
                                      for: alertController)
      popupView.addButton(button)
    }
    alertController.addPopupAlert(popupView)
    present(alertController, animated: true, completion: nil)
  }

  func showAlert(withMessage message: String?,
                 okButtonTitle: String = R.string.common.ok(),
                 isOkButtonDestructive: Bool = false,
                 cancelButtonTitle: String? = nil,
                 tintColor: UIColor = .systemBlue,
                 onCancelTap: (() -> Void)? = nil,
                 onTap: (() -> Void)? = nil) {
    showAlert(withTitle: nil,
              message: message,
              okButtonTitle: okButtonTitle,
              isOkButtonDestructive: isOkButtonDestructive,
              cancelButtonTitle: cancelButtonTitle,
              tintColor: tintColor,
              onCancelTap: onCancelTap,
              onTap: onTap)
  }
  
  private func makeAppAlertButton(alertAction: AlertAction, for alertController: BaseAlertViewController) -> StandardButton {
    let button = StandardButton(type: alertAction.buttonType)
    button.setTitle(alertAction.title, for: .normal)
    button.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
      alertController?.dismiss(animated: true) {
        alertAction.action?()
      }
    }
    return button
  }

  private func showAlert(_ alertController: UIAlertController, tintColor: UIColor = .systemBlue) {
    present(alertController, animated: true, completion: nil)
    alertController.view.tintColor = tintColor
  }
}
