//
//  AdditionalInfoDescriptionViewModel.swift
//  ForwardLeasing
//

import Foundation

struct AdditionalInfoDescriptionViewModel: AdditionalInfoDescriptionViewModelProtocol {
  let description: String?
  let buttonTitle: String?
  let isEnabled: Bool
  let onDidTapButton: (() -> Void)?
}
