//
//  ContractSigningAgreementViewModel.swift
//  ForwardLeasing
//

import UIKit

class ContractSigningAgreementViewModel: AgreementCheckboxViewModelProtocol {
  let applicationID: String
  let isSelected: Bool = false
  var agreement: NSAttributedString {
    let attributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.font: UIFont.textRegular,
      NSAttributedString.Key.foregroundColor: UIColor.base1
    ]
    let string = R.string.contractSigning.contractAgreementText()
    let keyword = R.string.contractSigning.contractAgreementKeyWord()
    let keywordRange = (string as NSString).range(of: keyword)
    let agreement = NSMutableAttributedString(string: string,
                                              attributes: attributes)
    agreement.addAttributes(addLinkAttributes(for: URLFactory.LeasingApplication.consetForm(applicationID: applicationID)),
                            range: keywordRange)
    return agreement
  }
  var onDidToggleCheckbox: ((Bool) -> Void)?
  var onDidSelectURL: ((URL) -> Void)?

  init(applicationID: String) {
    self.applicationID = applicationID
  }

  private func addLinkAttributes(for url: String) -> [NSAttributedString.Key: Any] {
    var attributes: [NSAttributedString.Key: Any] = [:]
    attributes[NSAttributedString.Key.link] = url
    attributes[NSAttributedString.Key.font] = UIFont.textBold
    return attributes
  }
}
