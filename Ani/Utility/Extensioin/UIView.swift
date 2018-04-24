//
//  UIView.swift
//  Ani
//
//  Created by jeonminseop on 2018/04/24.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

extension UIView {
  func dropShadow(
    color:UIColor = UIColor(red:0, green:0, blue:0, alpha:1),
    opacity:Float = 0.05,
    offset:CGSize = CGSize(width:0, height:5),
    radius:CGFloat = 5.0) {
    self.layer.shadowColor = color.cgColor
    self.layer.shadowOpacity = opacity
    self.layer.shadowOffset = offset
    self.layer.shadowRadius = radius
    self.layer.shouldRasterize = true
    self.layer.rasterizationScale = UIScreen.main.scale
  }
}
