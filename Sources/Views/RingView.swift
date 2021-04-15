//
//  RingView.swift
//  ForwardLeasing
//

import UIKit

class RingView: UIView {
  // MARK: - Layers
  private let backgroundLayer = CAShapeLayer()
  private let progressLayer = CAShapeLayer()
  
  // MARK: - Properties
  var strokeColor: UIColor? {
    didSet {
      progressLayer.strokeColor = strokeColor?.cgColor
    }
  }
  
  var fraction: CGFloat = 0 {
    didSet {
      progressLayer.strokeStart = 1 - fraction
    }
  }
  
  var width: CGFloat = 8 {
    didSet {
      backgroundLayer.lineWidth = width
      progressLayer.lineWidth = width
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayers()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupLayers()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    updateLayersPaths()
  }
  
  private func setupLayers() {
    backgroundLayer.fillColor = UIColor.clear.cgColor
    backgroundLayer.lineCap = .round
    backgroundLayer.lineWidth = width
    backgroundLayer.strokeColor = UIColor.shade20.cgColor
    layer.addSublayer(backgroundLayer)
    
    progressLayer.strokeEnd = 1.0
    progressLayer.fillColor = UIColor.clear.cgColor
    progressLayer.strokeColor = strokeColor?.cgColor
    progressLayer.lineWidth = width
    progressLayer.lineCap = .round
    layer.addSublayer(progressLayer)
  }
  
  private func updateLayersPaths() {
    let radius = min(bounds.width, bounds.height) / 2
    let layerPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                 radius: radius,
                                 startAngle: -.pi / 2,
                                 endAngle: 3 * .pi / 2,
                                 clockwise: true)
    backgroundLayer.path = layerPath.cgPath
    progressLayer.path = layerPath.cgPath
  }
}
