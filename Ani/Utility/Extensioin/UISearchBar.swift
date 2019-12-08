//
//  UISearchBar.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

extension UISearchBar {
  var textField: UITextField {
    if let textFiled = self.value(forKey: "searchField") as? UITextField {
      return textFiled
    } else {
      return UITextField()
    }
  }

  func disableBlur() {
    backgroundImage = UIImage()
    isTranslucent = true
  }

  var cancelButton: UIButton {
    if let cancelButton = self.value(forKey: "cancelButton") as? UIButton {
      return cancelButton
    } else {
      return UIButton()
    }
  }
}
