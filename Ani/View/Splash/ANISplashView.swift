//
//  ANISplashView.swift
//  Ani
//
//  Created by jeonminseop on 2018/10/31.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANISplashView: UIView {
  
  private weak var backGroundImageView: UIImageView?
  private weak var logoImageView: UIImageView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //backGroundImageView
    let backGroundImageView = UIImageView()
    backGroundImageView.image = UIImage(named: "splashBG")
    backGroundImageView.contentMode = .scaleAspectFill
    self.addSubview(backGroundImageView)
    backGroundImageView.edgesToSuperview()
    self.backGroundImageView = backGroundImageView
    
    //logoImageView
    let logoImageView = UIImageView()
    logoImageView.image = UIImage(named: "MYAULogo")
    logoImageView.contentMode = .scaleAspectFill
    backGroundImageView.addSubview(logoImageView)
    logoImageView.centerInSuperview()
    logoImageView.height(83.0)
    logoImageView.width(118.0)
    self.logoImageView = logoImageView
  }
}
