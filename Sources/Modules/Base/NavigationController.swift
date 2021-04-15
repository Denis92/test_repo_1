//
//  NavigationController.swift
//  ForwardLeasing
//

import UIKit

class NavigationController: UINavigationController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle ?? .lightContent
  }
  
  override var prefersStatusBarHidden: Bool {
    return topViewController?.prefersStatusBarHidden ?? false
  }
  
  override var shouldAutorotate: Bool {
    return topViewController?.shouldAutorotate ?? true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return topViewController?.supportedInterfaceOrientations ?? .portrait
  }
  
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return topViewController?.preferredStatusBarUpdateAnimation ?? .slide
  }

  init() {
    super.init(navigationBarClass: UINavigationBar.self, toolbarClass: nil)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  override init(rootViewController: UIViewController) {
    super.init(navigationBarClass: UINavigationBar.self, toolbarClass: nil)
    viewControllers = [rootViewController]
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
  }
  
  // MARK: - Navigation Bar Appearance
  
  func configureNavigationBarAppearance() {
    navigationBar.barTintColor = .accent2
    navigationBar.tintColor = .base2
    navigationBar.shadowImage = UIImage()
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.base2,
                                         NSAttributedString.Key.font: UIFont.textBold]
    navigationBar.isTranslucent = false
    navigationBar.backgroundColor = .clear
    view.backgroundColor = .base2

    let backButtonImage = R.image.backButtonWithBackgroundIcon()?.withRenderingMode(.alwaysOriginal)
    navigationBar.backIndicatorImage = backButtonImage
    navigationBar.backIndicatorTransitionMaskImage = backButtonImage
  }
}
