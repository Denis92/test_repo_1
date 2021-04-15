//
//  CircleProgressView.swift
//  ForwardLeasing
//

import UIKit

struct CircleProgressInfo {
  let segmentsCount: CGFloat
  let successSegmentsCount: CGFloat
  let failureSegmentsCount: CGFloat
  
  static let `default`: CircleProgressInfo = CircleProgressInfo(segmentsCount: 0,
                                                                successSegmentsCount: 0,
                                                                failureSegmentsCount: 0)
  
  static func make(from contract: LeasingEntity) -> CircleProgressInfo {
    let successSegmentsCount = CGFloat(contract.contractInfo?.successSegmentsCount ?? 0)
    let failureSegmentsCount = CGFloat(contract.contractInfo?.failureSegmentsCount ?? 0)
    return CircleProgressInfo(segmentsCount: CGFloat(contract.productInfo.paymentsCount),
                              successSegmentsCount: successSegmentsCount,
                              failureSegmentsCount: failureSegmentsCount)
  }
}

class CircleProgressView: UIView {
  // MARK: - Properties
  var circleProgressInfo: CircleProgressInfo = .default {
    didSet {
      updateLayers()
    }
  }

  var backgroundProgressColor: UIColor? = .shade20 {
    didSet {
      backgroundProgressLayer.strokeColor = backgroundProgressColor?.cgColor
    }
  }

  var successProgressColor: UIColor? = .access {
    didSet {
      successProgressLayer.strokeColor = successProgressColor?.cgColor
    }
  }

  var failureProgressColor: UIColor? = .error {
    didSet {
      failureProgressLayer.strokeColor = failureProgressColor?.cgColor
    }
  }

  var progressWidth: CGFloat = 6.0 {
    didSet {
      backgroundProgressLayer.lineWidth = progressWidth
      successProgressLayer.lineWidth = progressWidth
      failureProgressLayer.lineWidth = progressWidth
      updateLayers()
    }
  }

  private var arcCenter: CGPoint {
    return CGPoint(x: bounds.midX, y: bounds.midY)
  }

  private var arcRadius: CGFloat {
    return min(bounds.midX, bounds.midY) - offset
  }

  private var arcStartAngle: CGFloat {
    return -(.pi / 2)
  }

  private var offset: CGFloat {
    return progressWidth / 2
  }

  private var backgroundProgressLayer = CAShapeLayer()
  private var successProgressLayer = CAShapeLayer()
  private var failureProgressLayer = CAShapeLayer()

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    updateLayers()
  }

  // MARK: - Private methods
  private func setup() {
    setupBackgroundProgressLayer()
    setupFailureProgressLayer()
    setupSuccessProgressLayer()
  }

  private func setupBackgroundProgressLayer() {
    backgroundProgressLayer.fillColor = UIColor.clear.cgColor
    backgroundProgressLayer.lineCap = .butt
    backgroundProgressLayer.lineWidth = progressWidth
    backgroundProgressLayer.strokeColor = backgroundProgressColor?.cgColor
    layer.addSublayer(backgroundProgressLayer)
  }

  private func setupSuccessProgressLayer() {
    successProgressLayer.fillColor = UIColor.clear.cgColor
    successProgressLayer.lineCap = .butt
    successProgressLayer.lineJoin = .miter
    successProgressLayer.lineWidth = progressWidth
    successProgressLayer.strokeColor = successProgressColor?.cgColor
    layer.addSublayer(successProgressLayer)
  }

  private func setupFailureProgressLayer() {
    failureProgressLayer.fillColor = UIColor.clear.cgColor
    failureProgressLayer.lineCap = .butt
    failureProgressLayer.lineJoin = .miter
    failureProgressLayer.lineWidth = progressWidth
    failureProgressLayer.strokeColor = failureProgressColor?.cgColor
    layer.addSublayer(failureProgressLayer)
  }

  private func updateLayers() {
    backgroundProgressLayer.path = makeBackgroundProgressPath()
    successProgressLayer.path = makeProgressPath(for: circleProgressInfo.successSegmentsCount,
                                                 in: circleProgressInfo.segmentsCount,
                                                 startAngle: arcStartAngle)
    let failureStartAngle = endAngle(for: circleProgressInfo.successSegmentsCount,
                                     in: circleProgressInfo.segmentsCount,
                                     startAngle: arcStartAngle)
    failureProgressLayer.path = makeProgressPath(for: circleProgressInfo.failureSegmentsCount,
                                                 in: circleProgressInfo.segmentsCount,
                                                 startAngle: failureStartAngle)
  }

  private func makeBackgroundProgressPath() -> CGPath {
    return UIBezierPath(roundedRect: bounds.insetBy(dx: offset,
                                                    dy: offset),
                        cornerRadius: bounds.midY).cgPath
  }

  private func makeProgressPath(for segments: CGFloat,
                                in segmentsCounts: CGFloat,
                                startAngle: CGFloat) -> CGPath {
    let endAngle = self.endAngle(for: segments,
                                 in: segmentsCounts, startAngle: startAngle)
    return UIBezierPath(arcCenter: CGPoint(x: bounds.midX,
                                           y: bounds.midY),
                        radius: arcRadius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true).cgPath
  }

  private func endAngle(for segments: CGFloat,
                        in segmentsCounts: CGFloat,
                        startAngle: CGFloat) -> CGFloat {
    let segmentAngle = 2 * .pi / segmentsCounts
    return startAngle + segmentAngle * segments
  }
}
