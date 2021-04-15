//
//  UserInfoTextFieldUpdating.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol UserInfoTextFieldUpdating {
  var applicationService: ApplicationNetworkProtocol { get }
  var onDidRequestUpdateEmail: ((String) -> Void)? { get set }
  var fieldConfigurators: [FieldConfigurator<AnyFieldType<RegisterFieldType>>] { get }
  
  func getClientInfo()
}

extension UserInfoTextFieldUpdating {
  func getClientInfo() {
    firstly {
      applicationService.getClientInfo()
    }.done { clientInfo in
      self.handleClientInfo(clientInfo)
    }.cauterize()
  }
  
  private func handleClientInfo(_ clientInfo: MaskedClientInfo) {
    onDidRequestUpdateEmail?(clientInfo.email)
    if let configurator = fieldConfigurators.first(where: { $0.type.wrapped == .email }) {
      configurator.validate(silent: true)
    }
  }
}
