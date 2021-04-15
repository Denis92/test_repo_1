//
//  AppDelegate.swift
//  ForwardLeasing
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  // MARK: - Properties
  private lazy var appDependency = AppDependency.makeDefault()
  private lazy var mainCoordinator: MainCoordinator = createMainCoordinator()
  var window: UIWindow?
  
  // MARK: - App Life Cycle

  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    guard NSClassFromString("XCTestCase") == nil else {
      return true // do not start main coordinator if app is loaded as a unit tests container
    }
    configureFireBase()
    appDependency.mapService.initialize()
    startMainCoordinator()
    return true
  }
  
  // MARK: - Private Methods
  
  private func createMainCoordinator() -> MainCoordinator {
    let windowFrame = UIScreen.main.bounds
    let newWindow = UIWindow(frame: windowFrame)
    self.window = newWindow
    let utility = MainCoordinatorUtility(dependencies: appDependency)
    return MainCoordinator(window: newWindow, utility: utility, appDependency: appDependency)
  }
  
  private func startMainCoordinator() {
    mainCoordinator.start(animated: false)
  }

  private func configureFireBase() {
    FirebaseApp.configure()
  }

  // MARK: - UIApplicationDelegate
  func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                   restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    appDependency.deeplinkService.parseLink(userActivity.webpageURL)
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    appDependency.deeplinkService.parseLink(url)
    return true
  }
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool{
    appDependency.deeplinkService.parseLink(url)
    return true
  }
}
