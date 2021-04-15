//
//  TabBarViewController.swift
//  ForwardLeasing
//

import UIKit

class TabBarViewController: UITabBarController, NavigationBarHiding {
  override var shouldAutorotate: Bool {
    return false
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .portrait
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override var prefersStatusBarHidden: Bool {
    return false
  }

  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .slide
  }

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setNeedsStatusBarAppearanceUpdate()
    setDefaultBackButtonTitle()
    setupTabBarAppearance()
  }

  // MARK: - Setup

  private func setupTabBarAppearance() {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    let attributes = [NSAttributedString.Key.font: UIFont.caption3Regular,
                      NSAttributedString.Key.paragraphStyle: paragraphStyle]
    var selectedAttributes = attributes
    selectedAttributes[NSAttributedString.Key.foregroundColor] = UIColor.accent

    var normalAttributes = attributes
    normalAttributes[NSAttributedString.Key.foregroundColor] = UIColor.accent2

    UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)

    if #available(iOS 13.0, *) {
      let appearance = UITabBarAppearance()
      appearance.shadowImage = UIImage()
      appearance.shadowColor = .clear
      appearance.backgroundColor = .base2
      appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
      appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
      tabBar.standardAppearance = appearance
    } else {
      tabBar.backgroundColor = .base2
      tabBar.backgroundImage = UIImage()
      tabBar.shadowImage = UIImage()
    }

    tabBar.isTranslucent = false
    tabBar.tintColor = .accent
    tabBar.barTintColor = .base2
    tabBar.unselectedItemTintColor = .accent2
    tabBar.barStyle = .default
    tabBar.layer.borderColor = UIColor.black.withAlphaComponent(0).cgColor
    tabBar.layer.borderWidth = CGFloat.leastNormalMagnitude
    tabBar.clipsToBounds = false
  }
}
