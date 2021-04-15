//
//  ArcLabel.swift
//  ForwardLeasing
//

import UIKit

enum CircularDirection {
  case clockwise, anticlockwise
}

private extension Constants {
  static let maxTextCircleSegment: CGFloat = 0.6
}

class ArcLabel: UIView {
  var text: String? {
    didSet {
      setNeedsDisplay()
    }
  }
  var textStyle: TextStyle = .subheadRegular
  var textColor: UIColor = .base2

  override init(frame: CGRect) {
    super.init(frame: frame)
    isOpaque = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    let size = bounds.size
    context.clear(bounds)

    guard let text = text else {
      return
    }

    context.translateBy(x: size.width / 2, y: size.height / 2)
    context.scaleBy(x: 1, y: -1)

    centreArcPerpendicular(text: text,
                           context: context,
                           radius: 0.5 * (size.height - textStyle.lineHeight) - 2,
                           angle: -.pi / 2,
                           color: textColor,
                           font: textStyle.font,
                           textDirection: .anticlockwise)
  }

  func centreArcPerpendicular(text: String, context: CGContext, radius: CGFloat, angle theta: CGFloat, color: UIColor,
                              font: UIFont, textDirection: CircularDirection) {
    // *******************************************************
    // This draws the String str around an arc of radius r,
    // with the text centred at polar angle theta
    // *******************************************************

    let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font,
                                                     NSAttributedString.Key.kern: textStyle.kern]
    var stringSize = text.size(withAttributes: attributes)
    let circleCircumference = 2 * .pi * radius
    var newString = text
    var numberOfCharactersToDrop = 1

    while stringSize.width > Constants.maxTextCircleSegment * circleCircumference {
      newString = String(text.dropLast(numberOfCharactersToDrop)) + "..."
      stringSize = newString.size(withAttributes: attributes)
      numberOfCharactersToDrop += 1
    }

    let characters: [String] = newString.map { String($0) } // An array of single character strings, each character in string
    let stringLength = characters.count

    var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
    var totalArc: CGFloat = 0 // ... and the total arc subtended by the string

    // Calculate the arc subtended by each letter and their total
    for index in 0 ..< stringLength {
      arcs += [chordToArc(characters[index].size(withAttributes: attributes).width, radius: radius)]
      totalArc += arcs[index]
    }

    // Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
    // or anti-clockwise (right way up at 6 o'clock)?
    let direction: CGFloat = textDirection == .clockwise ? -1 : 1
    let slantCorrection: CGFloat = textDirection == .clockwise ? -.pi / 2 : .pi / 2

    // The centre of the first character will then be at
    // thetaI = theta - totalArc / 2 + arcs[0] / 2
    // But we add the last term inside the loop
    var thetaI = theta - direction * totalArc / 2

    for index in 0 ..< stringLength {
      thetaI += direction * arcs[index] / 2
      // Call centerText with each character in turn.
      // Remember to add +/-90º to the slantAngle otherwise
      // the characters will "stack" round the arc rather than "text flow"
      center(text: characters[index], context: context, radius: radius,
             angle: thetaI, color: color, font: font, slantAngle: thetaI + slantCorrection)
      // The centre of the next character will then be at
      // thetaI = thetaI + arcs[index] / 2 + arcs[index + 1] / 2
      // but again we leave the last term to the start of the next loop...
      thetaI += direction * arcs[index] / 2
    }
  }

  func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
    return 2 * asin(chord / (2 * radius))
  }

  func center(text: String, context: CGContext, radius: CGFloat,
              angle theta: CGFloat, color: UIColor, font: UIFont, slantAngle: CGFloat) {
    // *******************************************************
    // This draws the String text centred at the position
    // specified by the polar coordinates (R, theta)
    // i.e. the x = R * cos(theta) y = R * sin(theta)
    // and rotated by the angle slantAngle
    // *******************************************************

    let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: color,
                                                     NSAttributedString.Key.font: font,
                                                     NSAttributedString.Key.kern: textStyle.kern]
    context.saveGState()

    // Undo the inversion of the Y-axis (or the text goes backwards!)
    context.scaleBy(x: 1, y: -1)
    // Move the origin to the centre of the text (negating the y-axis manually)
    context.translateBy(x: radius * cos(theta), y: -(radius * sin(theta)))
    // Rotate the coordinate system
    context.rotate(by: -slantAngle)

    let offset = text.size(withAttributes: attributes)

    // Move the origin by half the size of the text
    context.translateBy(x: -(offset.width) / 2, y: -offset.height / 2)

    text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
    context.restoreGState()
  }
}
