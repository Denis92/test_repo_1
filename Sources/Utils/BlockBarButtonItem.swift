//
//  BlackBarButtonItem.swift
//  ForwardLeasing
//

import UIKit

class BlockBarButtonItem: UIBarButtonItem {
  private let tapHandler: (() -> Void)

  init(image: UIImage?, style: UIBarButtonItem.Style, tapHandler: @escaping (() -> Void)) {
    self.tapHandler = tapHandler
    super.init()

    self.image = image
    self.style = style
    self.target = self
    self.action = #selector(buttonTapped(_:))
  }

  init(title: String?, style: UIBarButtonItem.Style, tapHandler: @escaping (() -> Void)) {
    self.tapHandler = tapHandler
    super.init()

    self.title = title
    self.style = style
    self.target = self
    self.action = #selector(buttonTapped(_:))
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func buttonTapped(_ sender: UIBarButtonItem) {
    tapHandler()
  }
}
