//
//  AttributedLabel.swift
//  ForwardLeasing
//

import UIKit

class AttributedLabel: UILabel {
  private var lineHeight: CGFloat {
    return textStyle.lineHeight
  }
  private var lineHeightMultiple: CGFloat {
    return textStyle.lineHeightMultiple
  }
  private var kern: CGFloat {
    return textStyle.kern
  }
  private (set) var textStyle: TextStyle

  override var textAlignment: NSTextAlignment { didSet { updateText()  } }
  override var text: String? { didSet { updateText() } }

  @available(*, deprecated, message: "Change textStyle instead ")
  override var font: UIFont? { didSet { updateText() } }

  override var lineBreakMode: NSLineBreakMode { didSet { updateText() } }
  var paragraphSpacing: CGFloat? { didSet { updateText() } }

  var height: CGFloat {
    return attributedText?.textHeight(forContainerWidth: frame.width) ?? 0
  }

  init(textStyle: TextStyle) {
    self.textStyle = textStyle
    super.init(frame: .zero)
    super.font = textStyle.font
    textColor = .base1
  }

  required init?(coder aDecoder: NSCoder) {
    self.textStyle = .textRegular
    super.init(coder: aDecoder)
    super.font = textStyle.font
    textColor = .base1
  }

  override func drawText(in rect: CGRect) {
    guard let font = super.font else {
      return super.drawText(in: rect)
    }
    var newRect = rect
    let offset = 0.5 * (lineHeight - font.lineHeight)
    newRect.origin = CGPoint(x: rect.origin.x, y: -offset)
    super.drawText(in: newRect)
  }

  func change(textStyle: TextStyle) {
    super.font = textStyle.font
    self.textStyle = textStyle
    updateText()
  }

  func formattedText(string: String?) -> NSAttributedString? {
    guard let text = string else {
      return nil
    }
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = lineHeightMultiple
    paragraphStyle.alignment = textAlignment
    paragraphStyle.lineBreakMode = lineBreakMode
    if let paragraphSpacing = paragraphSpacing {
      paragraphStyle.paragraphSpacing = paragraphSpacing
    }
    let attributes: [NSAttributedString.Key: Any] = [
      .paragraphStyle: paragraphStyle, .font: super.font ?? .textRegular, .kern: kern
    ]
    let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
    return attributedString
  }

  private func updateText() {
    var resultString: NSAttributedString?
    if let attributedString = formattedText(string: text) {
      resultString = attributedString
    }
    self.attributedText = resultString
  }
}
