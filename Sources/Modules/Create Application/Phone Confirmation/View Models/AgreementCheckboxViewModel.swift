//
//  AgreementCheckboxViewModel.swift
//  ForwardLeasing
//

import UIKit

class AgreementCheckboxViewModel: CommonTableCellViewModel, AgreementCheckboxViewModelProtocol {
  private typealias Cell = CommonContainerTableViewCell<AgreementCheckboxView>
  
  var tableCellIdentifier: String {
    return Cell.reuseIdentifier
  }
  
  let isSelected: Bool
  var agreement: NSAttributedString {
    let attributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.font: UIFont.textRegular,
      NSAttributedString.Key.foregroundColor: UIColor.base1
    ]
    let attributedString: NSMutableAttributedString
    switch type {
    case .electronicSignature(let basketID):
      let string = R.string.auth.agreementElectronicSignature()
      let keyword = R.string.auth.electronicSignatureAgreementKeyWord()
      let keywordRange = (string as NSString).range(of: keyword)
      attributedString = NSMutableAttributedString(string: string,
                                                   attributes: attributes)
      let url = URLFactory.LeasingBasket.consetForm(basketID: basketID)
      attributedString.addAttributes(url.linkAttributes,
                                     range: keywordRange)
    case .leasingPersonalData(let basketID):
      let string = R.string.auth.agreementPersonalData()
      let keyword = R.string.auth.personalDataAgreementKeyWord()
      let keywordRange = (string as NSString).range(of: keyword)
      attributedString = NSMutableAttributedString(string: string,
                                                   attributes: attributes)
      let url = URLFactory.LeasingBasket.personalDataAgreement(basketID: basketID)
      attributedString.addAttributes(url.linkAttributes,
                                     range: keywordRange)
    case .registerPersonalData:
      let string = R.string.auth.agreementPersonalData()
      let keyword = R.string.auth.personalDataAgreementKeyWord()
      let keywordRange = (string as NSString).range(of: keyword)
      attributedString = NSMutableAttributedString(string: string,
                                                   attributes: attributes)
      let url = URLFactory.LeasingBasket.registerPersonalDataAgreementURL
      attributedString.addAttributes(url.linkAttributes,
                                     range: keywordRange)
    case .personalDataAndSubscrptionRules:
      let string = R.string.subscriptionRegister.personalDataAndSubscriptionRules()
      
      let agreementKeyword = R.string.subscriptionRegister.agreementKeyword()
      let agreementKeywordRange = (string as NSString).range(of: agreementKeyword)
      
      let rulesKeyword = R.string.subscriptionRegister.rulesKeyword()
      let rulesKeywordRange = (string as NSString).range(of: rulesKeyword)
      attributedString = NSMutableAttributedString(string: string,
                                                   attributes: attributes)
      
      attributedString.addAttributes(URLFactory.Documents.personalDataPolicy.linkAttributes,
                                     range: agreementKeywordRange)
      attributedString.addAttributes(URLFactory.Documents.leasingRules.linkAttributes,
                                     range: rulesKeywordRange)
    }
    return attributedString
  }
  
  var onDidToggleCheckbox: ((Bool) -> Void)?
  var onDidSelectURL: ((URL) -> Void)?
  
  private let type: AgreementType
  
  init(type: AgreementType,
       isSelected: Bool,
       onDidToggleCheckbox: ((Bool) -> Void)?,
       onDidSelectURL: ((URL) -> Void)?) {
    self.isSelected = isSelected
    self.type = type
    self.onDidToggleCheckbox = onDidToggleCheckbox
    self.onDidSelectURL = onDidSelectURL
  }
}
