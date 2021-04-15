//
//  NavigationBarView.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

private extension Constants {
  static let maskArcHeight: CGFloat = 44
  static let titleViewHeight: CGFloat = 44
  static let animationKey = "animatePath"
  static let animationDuration = 0.3
  static let pullToRefreshOffset: CGFloat = 40
}

enum NavigationBarViewType {
  case titleAlwaysVisible(hasPullToRefresh: Bool = false),
       titleHiddenWhenFull(hasPullToRefresh: Bool = false), titleWithoutContent
}

enum DraggingState {
  case draggingTop, noDragging, refreshing
}

class NavigationBarView: UIView {
  // MARK: - Public properties
  
  var onNeedsToLayoutSuperview: (() -> Void)?
  var onDidUpdateContentContainerHeight: ((CGFloat) -> Void)?
  var onDidStartRefreshing: ((_ additionalHeight: CGFloat) -> Void)?
  
  var maskArcHeight: CGFloat {
    return Constants.maskArcHeight
  }
  
  var titleViewHeight: CGFloat {
    return Constants.titleViewHeight
  }
  
  var titleViewMaxY: CGFloat {
    return titleViewHeight + UIApplication.shared.statusBarFrame.height
  }
  
  var isRefreshing: Bool {
    return draggingState == .refreshing || isFinishingRefreshing
  }
  
  private (set) var isCollapsed: Bool = false
  
  // MARK: - Private properties
  
  private let viewType: NavigationBarViewType
  private let roundedViewMaskLayer = CAShapeLayer()
  private let bottomRoundedView = UIView()
  private let containerView = UIView()
  private let backgroundView = UIView()
  private let contentContainerView = UIView()
  private let navigationBarTitleView = NavigationBarTitleView()
  private let backButton = NavBarBackButton()
  private let activityIndicatorView = UIActivityIndicatorView(style: .white)
  
  private var draggingState: DraggingState = .noDragging
  private var containerViewHeightConstraint: Constraint?
  private var contentContainerViewTopConstraint: Constraint?
  private var titleViewTopConstraint: Constraint?
  private var isAnimating: Bool = false
  private var isFinishingRefreshing: Bool = false
  private var currentDraggingAdditionalHeight: CGFloat = 0
  private var onBackButtonTapped: (() -> Void)?
  private var updateCollapsedStateWorkItem: DispatchWorkItem?
  
  private var contentContainerTopAdditionalOffset: CGFloat {
    if case .titleHiddenWhenFull = viewType {
      return UIApplication.shared.statusBarFrame.height
    }
    return 0
  }
  
  // MARK: - Init
  
  init(type: NavigationBarViewType = .titleAlwaysVisible()) {
    self.viewType = type
    super.init(frame: .zero)
    setup()
    
    onNeedsToLayoutSuperview = { [weak self] in
      self?.superview?.layoutIfNeeded()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if !isAnimating {
      roundedViewMaskLayer.frame = bounds
      roundedViewMaskLayer.path = (isCollapsed ? makeStraightPath() : makeRoundedPath()).cgPath
      bottomRoundedView.layer.mask = roundedViewMaskLayer
      
      if draggingState == .noDragging, !isFinishingRefreshing {
        updateHeight()
        onDidUpdateContentContainerHeight?(contentContainerView.bounds.height)
      }
    }
  }
  
  // MARK: - Public methods
  
  func addContentView(_ view: UIView) {
    contentContainerView.subviews.forEach { $0.removeFromSuperview() }
    contentContainerView.addSubview(view)
    view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    layoutIfNeeded()
  }
  
  func addBackButton(onBackButtonTapped: (() -> Void)?) {
    navigationBarTitleView.setLeftViews([backButton])
    self.onBackButtonTapped = onBackButtonTapped
    backButton.addTarget(self, action: #selector(handleBackButtonTapped(_:)), for: .touchUpInside)
  }
  
  func configureNavigationBarTitle(title: String?, leftViews: [UIView] = [], rightViews: [UIView] = []) {
    navigationBarTitleView.setTitle(title)
    if !leftViews.isEmpty || onBackButtonTapped == nil {
      navigationBarTitleView.setLeftViews(leftViews)
    }
    navigationBarTitleView.setRightViews(rightViews)
  }
  
  func setState(isCollapsed: Bool, animated: Bool) {
    guard isCollapsed != self.isCollapsed else { return }
    self.isCollapsed = isCollapsed
    
    updateHeight()
    
    let path = isCollapsed ? makeStraightPath() : makeRoundedPath()
    
    if animated {
      animate(layer: roundedViewMaskLayer, path: path)
      UIView.animate(withDuration: Constants.animationDuration, delay: 0.0,
                     options: [.beginFromCurrentState, .curveEaseInOut]) {
        self.setContentAppearance(isCollapsed: isCollapsed)
        self.onNeedsToLayoutSuperview?()
        self.layoutIfNeeded()
      }
    } else {
      setContentAppearance(isCollapsed: isCollapsed)
      roundedViewMaskLayer.path = path.cgPath
    }
  }
  
  func endRefreshing(animation: (() -> Void)? = nil) {
    isFinishingRefreshing = true
    draggingState = .noDragging
    currentDraggingAdditionalHeight = 0
    contentContainerViewTopConstraint?.update(offset: contentContainerTopAdditionalOffset)
    titleViewTopConstraint?.update(inset: UIApplication.shared.statusBarFrame.height)
    updateHeight()
    
    UIView.animate(withDuration: 0.3, animations: {
      self.activityIndicatorView.alpha = 0
      self.onNeedsToLayoutSuperview?()
      animation?()
    }, completion: { _ in
      self.activityIndicatorView.stopAnimating()
      self.isFinishingRefreshing = false
    })
  }
  
  func updateToDraggingState(offsetY: CGFloat, isTracking: Bool) {
    switch viewType {
    case .titleAlwaysVisible, .titleHiddenWhenFull:
      break
    default:
      return
    }
    
    switch draggingState {
    case .noDragging:
      if offsetY < 0 {
        draggingState = .draggingTop
        if isTracking, !isFinishingRefreshing {
          updatePullToRefresh(offsetY: offsetY)
        }
        currentDraggingAdditionalHeight = abs(offsetY)
        contentContainerViewTopConstraint?.update(offset: abs(offsetY) + contentContainerTopAdditionalOffset)
        if case .titleHiddenWhenFull = viewType {
          titleViewTopConstraint?.update(inset: UIApplication.shared.statusBarFrame.height + abs(offsetY))
        }
        updateHeight()
      }
    case .draggingTop:
      if offsetY < 0 {
        if (isTracking || activityIndicatorView.alpha != 0), !isFinishingRefreshing {
          updatePullToRefresh(offsetY: offsetY)
        }
        currentDraggingAdditionalHeight = abs(offsetY)
        contentContainerViewTopConstraint?.update(offset: abs(offsetY) + contentContainerTopAdditionalOffset)
        if case .titleHiddenWhenFull = viewType {
          titleViewTopConstraint?.update(inset: UIApplication.shared.statusBarFrame.height + abs(offsetY))
        }
        updateHeight()
      } else {
        currentDraggingAdditionalHeight = 0
        draggingState = .noDragging
        isFinishingRefreshing = false
        activityIndicatorView.alpha = 0
      }
    case .refreshing:
      if offsetY < 0 {
        currentDraggingAdditionalHeight = abs(offsetY) + Constants.pullToRefreshOffset
        contentContainerViewTopConstraint?.update(offset: abs(offsetY) + Constants.pullToRefreshOffset
                                                    + contentContainerTopAdditionalOffset)
        if case .titleHiddenWhenFull = viewType {
          titleViewTopConstraint?.update(inset: UIApplication.shared.statusBarFrame.height + abs(offsetY)
                                          + Constants.pullToRefreshOffset)
        }
        updateHeight()
      } else {
        currentDraggingAdditionalHeight = Constants.pullToRefreshOffset
        contentContainerViewTopConstraint?.update(offset: Constants.pullToRefreshOffset
                                                    + contentContainerTopAdditionalOffset)
        if case .titleHiddenWhenFull = viewType {
          titleViewTopConstraint?.update(inset: UIApplication.shared.statusBarFrame.height
                                          + Constants.pullToRefreshOffset)
        }
        updateHeight()
      }
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupBackgroundView()
    setupBottomRoundedView()
    setupNavigationBarTitleView()
    switch viewType {
    case .titleAlwaysVisible(let hasPullToRefresh) where hasPullToRefresh,
         .titleHiddenWhenFull(let hasPullToRefresh) where hasPullToRefresh:
      setupPullToRefresh()
    default:
      break
    }
    setupContentContainer()
    setContentAppearance(isCollapsed: false)
  }
  
  private func setupContainer() {
    addSubview(containerView)
    containerView.clipsToBounds = true
    containerView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(maskArcHeight)
      containerViewHeightConstraint = make.height.equalTo(0).constraint
    }
  }
  
  private func setupBackgroundView() {
    addSubview(backgroundView)
    backgroundView.backgroundColor = .accent2
    backgroundView.snp.makeConstraints { make in
      make.edges.equalTo(containerView)
    }
    sendSubviewToBack(backgroundView)
  }
  
  private func setupBottomRoundedView() {
    insertSubview(bottomRoundedView, belowSubview: backgroundView)
    bottomRoundedView.backgroundColor = .accent2
    bottomRoundedView.snp.makeConstraints { make in
      make.top.equalTo(containerView.snp.bottom).offset(-0.5) // fix for glitching when ending refreshing
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(maskArcHeight + 0.5)
    }
  }
  
  private func setupContentContainer() {
    containerView.addSubview(contentContainerView)
    contentContainerView.snp.makeConstraints { make in
      switch viewType {
      case .titleAlwaysVisible:
        contentContainerViewTopConstraint = make.top.equalTo(navigationBarTitleView.snp.bottom).constraint
      case .titleHiddenWhenFull:
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        contentContainerViewTopConstraint = make.top.equalToSuperview().offset(statusBarHeight).constraint
      case .titleWithoutContent:
        contentContainerViewTopConstraint = make.top.equalTo(navigationBarTitleView.snp.bottom).constraint
        make.height.equalTo(0)
      }
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupPullToRefresh() {
    containerView.addSubview(activityIndicatorView)
    activityIndicatorView.snp.makeConstraints { make in
      switch viewType {
      case .titleHiddenWhenFull:
        make.top.equalToSuperview().offset(10 + UIApplication.shared.statusBarFrame.height)
      default:
        make.top.equalTo(navigationBarTitleView.snp.bottom).offset(10)
      }
      make.centerX.equalToSuperview()
    }
    activityIndicatorView.hidesWhenStopped = false
    activityIndicatorView.alpha = 0
  }
  
  private func setupNavigationBarTitleView() {
    containerView.addSubview(navigationBarTitleView)
    navigationBarTitleView.snp.makeConstraints { make in
      titleViewTopConstraint = make.top.equalToSuperview().inset(UIApplication.shared.statusBarFrame.height).constraint
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(Constants.titleViewHeight)
    }
  }
}

// MARK: - Private methods

extension NavigationBarView {
  private func updatePullToRefresh(offsetY: CGFloat) {
    switch viewType {
    case .titleAlwaysVisible(let hasPullToRefresh) where hasPullToRefresh && !isFinishingRefreshing,
         .titleHiddenWhenFull(let hasPullToRefresh) where hasPullToRefresh && !isFinishingRefreshing:
      break
    default:
      return
    }
    
    activityIndicatorView.alpha = abs(offsetY) / Constants.pullToRefreshOffset
    if abs(offsetY) / Constants.pullToRefreshOffset >= 1, currentDraggingAdditionalHeight > 0 {
      activityIndicatorView.startAnimating()
      draggingState = .refreshing
      onDidStartRefreshing?(Constants.pullToRefreshOffset)
    }
  }
  
  private func animate(layer: CAShapeLayer, path: UIBezierPath, shouldUseFlags: Bool = true) {
    if shouldUseFlags {
      guard !isAnimating else { return }
      isAnimating = true
    }
    
    layer.removeAllAnimations()
    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = layer.path
    animation.toValue = path.cgPath
    animation.duration = Constants.animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    CATransaction.setCompletionBlock {
      if shouldUseFlags {
        self.isAnimating = false
      }
    }
    layer.add(animation, forKey: Constants.animationKey)
    layer.path = path.cgPath
    CATransaction.commit()
  }
  
  private func makeRoundedPath() -> UIBezierPath {
    let path = UIBezierPath()
    path.move(to: .zero)
    path.addLine(to: CGPoint(x: bounds.width, y: 0))
    path.addLine(to: CGPoint(x: bounds.width, y: 0))
    path.addQuadCurve(to: CGPoint(x: 0, y: 0),
                      controlPoint: CGPoint(x: bounds.width / 2,
                                            y: 2 * maskArcHeight))
    path.close()
    return path
  }
  
  private func makeStraightPath() -> UIBezierPath {
    return UIBezierPath(rect: CGRect(x: 0, y: 0, width: containerView.bounds.width, height: 0))
  }
  
  private func setContentAppearance(isCollapsed: Bool) {
    contentContainerView.alpha = isCollapsed ? 0 : 1
    switch viewType {
    case .titleAlwaysVisible, .titleWithoutContent:
      navigationBarTitleView.alpha = 1
    case .titleHiddenWhenFull:
      navigationBarTitleView.alpha = isCollapsed ? 1 : 0
    }
  }
  
  private func updateHeight() {
    var height: CGFloat
    
    switch viewType {
    case .titleAlwaysVisible, .titleWithoutContent:
      height = isCollapsed ? Constants.titleViewHeight
        : Constants.titleViewHeight + contentContainerView.bounds.height
    case .titleHiddenWhenFull:
      height = isCollapsed ? Constants.titleViewHeight : contentContainerView.bounds.height
    }
    
    if currentDraggingAdditionalHeight > 0 {
      height += currentDraggingAdditionalHeight
    }
    containerViewHeightConstraint?.update(offset: height + UIApplication.shared.statusBarFrame.height)
  }
}

// MARK: - Actions

extension NavigationBarView {
  @objc private func handleBackButtonTapped(_ sender: UIButton) {
    onBackButtonTapped?()
  }
}
