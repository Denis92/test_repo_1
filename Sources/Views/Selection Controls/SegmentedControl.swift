//
//  SegmentedControl.swift
//  ForwardLeasing
//

import UIKit

class SegmentedControl: UIControl {
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: 68)
  }
  
  private(set) var selectedIndex = 0
  
  private let stackView = UIStackView()
  private let selectionView = UIView()
  
  private var segmentLabels: [AttributedLabel] = []
  private var selectionViewFrameOnPanStarted: CGRect?
  private var isManuallyChangingSelectionViewFrame = false
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    stackView.layoutIfNeeded()
    
    if !isManuallyChangingSelectionViewFrame {
      moveSelectionViewToSelectedIndex(animated: false)
    }
  }
  
  // MARK: - Public methods
  
  func setTabs(titles: [String]) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    segmentLabels = []
    
    titles.forEach { title in
      let label = AttributedLabel(textStyle: .title2Semibold)
      label.textAlignment = .center
      label.text = title
      label.textColor = .shade70
      label.isUserInteractionEnabled = true
      stackView.addArrangedSubview(label)
      segmentLabels.append(label)
    }
  }
  
  func setSelectedIndex(_ index: Int, animated: Bool, shouldSendAction: Bool = true) {
    guard !segmentLabels.indexOutOfRange(index) else { return }
    selectedIndex = index
    if shouldSendAction {
      sendActions(for: .valueChanged)
    }
    moveSelectionViewToSelectedIndex(animated: animated)
  }
  
  // MARK: - Actions
  
  @objc private func viewPanned(_ gestureRecognizer: UIPanGestureRecognizer) {
    handlePan(gestureRecognizerState: gestureRecognizer.state, translation: gestureRecognizer.translation(in: stackView))
  }
  
  @objc private func viewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    selectedIndex = nearestIndex(toPoint: gestureRecognizer.location(in: stackView))
    sendActions(for: .valueChanged)
    moveSelectionViewToSelectedIndex(animated: true)
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupStackView()
    setupSelectionView()
  }
  
  private func setupContainer() {
    backgroundColor = UIColor.inputPrimary
    makeRoundedCorners(radius: 34)
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
    addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:))))
  }
  
  private func setupStackView() {
    addSubview(stackView)
    
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(4)
    }
  }
  
  private func setupSelectionView() {
    insertSubview(selectionView, belowSubview: stackView)
    
    selectionView.backgroundColor = .base2
    selectionView.makeRoundedCorners(radius: 30)
  }
  
  // MARK: - Private methods
  
  private func updateLabelColors(animated: Bool) {
    if animated {
      segmentLabels.forEach { label in
        UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve, animations: {
          label.textColor = .shade70
        }, completion: nil)
      }
      if let label = segmentLabels.element(at: selectedIndex) {
        UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve, animations: {
          label.textColor = .base1
        }, completion: nil)
      }
    } else {
      segmentLabels.forEach { $0.textColor = .shade70 }
      segmentLabels.element(at: selectedIndex)?.textColor = .base1
    }
  }
  
  private func updateLabelColors(withPercentage percentage: CGFloat, currentIndex: Int, nextIndex: Int) {
    if let currentComponents = UIColor.shade70.cgColor.components,
      let targetComponents = UIColor.base1.cgColor.components {
      let red = (1.0 - percentage) * currentComponents[0] + percentage * targetComponents[0]
      let green = (1.0 - percentage) * currentComponents[1] + percentage * targetComponents[1]
      let blue = (1.0 - percentage) * currentComponents[2] + percentage * targetComponents[2]
      segmentLabels.element(at: currentIndex)?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    if let currentComponents = UIColor.base1.cgColor.components,
      let targetComponents = UIColor.shade70.cgColor.components {
      let red = (1.0 - percentage) * currentComponents[0] + percentage * targetComponents[0]
      let green = (1.0 - percentage) * currentComponents[1] + percentage * targetComponents[1]
      let blue = (1.0 - percentage) * currentComponents[2] + percentage * targetComponents[2]
      segmentLabels.element(at: nextIndex)?.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
  }
  
  private func moveSelectionView(to index: Int) {
    let elementFrame = stackView.arrangedSubviews.element(at: index)?.frame ?? .zero
    self.selectionView.frame = CGRect(x: elementFrame.origin.x + 4, y: elementFrame.origin.y + 4,
                                      width: elementFrame.width, height: elementFrame.height)
    self.layoutIfNeeded()
  }
  
  private func moveSelectionViewToSelectedIndex(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.3,
                     delay: 0.0,
                     usingSpringWithDamping: 0.75,
                     initialSpringVelocity: 0.0,
                     options: [.beginFromCurrentState, .curveEaseOut],
                     animations: {
                      self.moveSelectionView(to: self.selectedIndex)
      }, completion: { _ in
        self.isManuallyChangingSelectionViewFrame = false
      })
    } else {
      moveSelectionView(to: selectedIndex)
      isManuallyChangingSelectionViewFrame = false
    }
    updateLabelColors(animated: animated)
  }
  
  private func nearestIndex(toPoint point: CGPoint) -> Int {
    let distances = segmentLabels.map { abs(point.x - $0.center.x) }
    guard let minDistance = distances.min(), let index = distances.firstIndex(of: minDistance) else { return 0 }
    return index
  }
  
  private func handlePan(gestureRecognizerState state: UIGestureRecognizer.State, translation: CGPoint) {
    switch state {
    case .began:
      isManuallyChangingSelectionViewFrame = true
      selectionViewFrameOnPanStarted = selectionView.frame
    case .changed:
      handlePanGesturePositionChange(translation: translation)
    case .ended, .failed, .cancelled:
      setSelectedIndex(nearestIndex(toPoint: selectionView.center), animated: true)
    default:
      break
    }
  }
  
  private func handlePanGesturePositionChange(translation: CGPoint) {
    guard var frame = selectionViewFrameOnPanStarted else { return }
    frame.origin.x += translation.x
    let currentIndex = nearestIndex(toPoint: CGPoint(x: frame.midX, y: frame.midY))
    
    if let currentFrame = segmentLabels.element(at: currentIndex)?.frame {
      let nextIndex: Int
      
      if currentFrame.origin.x < frame.origin.x {
        nextIndex = min(currentIndex + 1, segmentLabels.count - 1)
      } else {
        nextIndex = max(currentIndex - 1, 0)
      }
      
      if let nextFrame = segmentLabels.element(at: nextIndex)?.frame {
        if nextFrame.origin.x != currentFrame.origin.x {
          if currentFrame.origin.x < frame.origin.x {
            let percentage = (frame.origin.x - currentFrame.origin.x) / (nextFrame.origin.x - currentFrame.origin.x)
            frame.size.width = (nextFrame.width - currentFrame.width) * percentage + currentFrame.width
            updateLabelColors(withPercentage: 1.0 - percentage, currentIndex: currentIndex, nextIndex: nextIndex)
          } else {
            let percentage = (frame.origin.x - nextFrame.origin.x) / (currentFrame.origin.x - nextFrame.origin.x)
            frame.size.width = (currentFrame.width - nextFrame.width) * percentage + nextFrame.width
            updateLabelColors(withPercentage: percentage, currentIndex: currentIndex, nextIndex: nextIndex)
          }
        } else {
          frame.size.width = currentFrame.width
        }
      }
      
      frame.origin.x = max(min(frame.origin.x, stackView.frame.maxX - frame.width), stackView.frame.minX)
      
      selectionView.frame = frame
    }
  }
}
