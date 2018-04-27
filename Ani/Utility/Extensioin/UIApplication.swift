//
//  UIApplication.swift
//  Ani
//
//  Created by jeonminseop on 2018/04/26.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

extension UIApplication {
  var statusBar: UIView? {
    return value(forKey: "statusBar") as? UIView
  }
}
