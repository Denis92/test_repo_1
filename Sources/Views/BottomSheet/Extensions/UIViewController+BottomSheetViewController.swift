//
//  UIViewController+BottomSheetViewController.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let downViewHeight: CGFloat = 20
}

extension UIViewController {
  fileprivate func makeDownView() -> UIView {
    let downViewFrame = CGRect(x: 0,
                               y: view.frame.height - Constants.downViewHeight,
                               width: view.frame.width,
                               height: Constants.downViewHeight)
    return UIView(frame: downViewFrame)
  }
  
  fileprivate func addBackgroundView(for viewController: BottomSheetViewController, sheetType: SheetType) {
    let backgroundView = BottomSheetBackgroundView(frame: view.frame, sheetType: sheetType)
    view.addSubview(backgroundView)
    
    viewController.darkView = backgroundView
    
    let downView = makeDownView()
    downView.backgroundColor = viewController.backgroundColor
    viewController.updateDownView(downView)
    view.addSubview(downView)
    
    backgroundView.onViewDidReceiveTap = { [weak viewController] in
      downView.removeFromSuperview()
      viewController?.moveDown { [weak viewController] in
        viewController?.remove()
      }
    }
    
    viewController.onDidRemoveBottomSheetViewController = {
      downView.removeFromSuperview()
      backgroundView.remove { [weak backgroundView] in
        guard let backgroundView = backgroundView else { return }
        backgroundView.removeFromSuperview()
      }
    }
    
    UIView.animate(withDuration: 0.3) {
      backgroundView.alpha = 1.0
    }
  }
  
  func addBottomSheetViewController(withDarkView: Bool,
                                    viewController: BottomSheetViewController,
                                    initialAnchorPointOffset: CGFloat = 0, height: CGFloat? = nil,
                                    animated: Bool, sheetType: SheetType = .hiding,
                                    shouldResize: Bool = false) {
    if withDarkView {
      addBackgroundView(for: viewController, sheetType: sheetType)
    }
    
    addChild(viewController)
    viewController.setup(superView: view,
                         initialAnchorPointOffset: initialAnchorPointOffset,
                         height: height,
                         sheetType: sheetType,
                         shouldResize: shouldResize)
    viewController.moveToPointWithAnimation(action: .add,
                                            duration: animated ? 0.3 : 0, animations: { [weak self] in
      self?.view.layoutIfNeeded()
      }, completion: nil)
  }
}
