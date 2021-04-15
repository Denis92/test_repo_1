//
//  ContractAdditionalApplicationTitles.swift
//  ForwardLeasing
//

import Foundation

protocol ContractAdditionalApplicationTitles {
  func primaryButtonTitle(with state: ContractAdditionalApplicationState) -> String?
  func statusTitle(with state: ContractAdditionalApplicationState) -> String?
}
