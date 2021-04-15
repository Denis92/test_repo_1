//
//  DiagnosticService.swift
//  ForwardLeasing
//

import Foundation
import FLDiagnostic
import PromiseKit

protocol DiagnosticServiceProtocol {
  func showDiagnosticOrContinue(with diagnosticID: String, sessionURL: String) -> Promise<GradeType>
}

class DiagnosticService: DiagnosticServiceProtocol {
  // MARK: - Properties
  var onDidFinishDiagnosticWithError: ((Error) -> Void)?
  var onDidFinishDiagnosticSuccess: ((GradeType) -> Void)?
  private let userDataStore: UserDataStoring

  // MARK: - Init
  init(userDataStore: UserDataStoring) {
    self.userDataStore = userDataStore
  }

  func showDiagnosticOrContinue(with diagnosticID: String, sessionURL: String) -> Promise<GradeType> {
    return Promise { seal in
      guard shouldDiagnose(diagnosticID: diagnosticID) else {
        return seal.reject(DiagnosticError.notAvailable)
      }

      FLDiagnostic.startTesting(diagnosticID, sessionURL) { [weak self] gradeString, errorMessage in
        if let errorMessage = errorMessage {
          return seal.reject(DiagnosticError.diagnosticError(errorMessage))
        }
        if let gradeString = gradeString {
          let grade = GradeType(rawValue: gradeString) ?? .none
          self?.saveDiagnosticSession(sessionID: diagnosticID)
          return seal.fulfill(grade)
        }
      }
    }
  }

  private func shouldDiagnose(diagnosticID: String) -> Bool {
    return diagnosticID != userDataStore.lastDiagnosticSessionID
  }

  private func saveDiagnosticSession(sessionID: String) {
    userDataStore.lastDiagnosticSessionID = sessionID
  }

}
