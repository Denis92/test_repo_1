//
//  WarrantyServiceViewModel.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let warrantyServiceURL = "https://apple.com" // TODO - replace with actual url
}

struct WarrantyServiceViewModel: WarrantyServiceViewModelProtocol {
  var text: NSAttributedString {
    let attributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.font: UIFont.textRegular,
      NSAttributedString.Key.foregroundColor: UIColor.base1
    ]
    let string = R.string.contractDetails.warrantyServiceDescription()
    let keyword = R.string.contractDetails.warrantyServiceURLKeyWord()
    let keywordRange = (string as NSString).range(of: keyword)
    let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: attributes)
    attributedString.addAttributes(Constants.warrantyServiceURL.linkAttributes,
                                   range: keywordRange)
    return attributedString
  }
  
  let onDidSelectURL: ((URL) -> Void)?
}
