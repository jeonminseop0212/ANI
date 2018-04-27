//
//  ANIRecruitDetailViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/04/26.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIRecruitDetailViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var recruitDetailView: ANIRecruitDetailView?

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  private func setup() {
    //basic
    self.navigationController?.navigationBar.tintColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)

    //recruitDetailView
    let recruitDetailView = ANIRecruitDetailView()
    recruitDetailView.headerMinHeight = UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT
    recruitDetailView.delegete = self
    self.view.addSubview(recruitDetailView)
    recruitDetailView.edgesToSuperview()
    self.recruitDetailView = recruitDetailView
    
    //myNavigationBar
    let myNavigationBar = UIView()
    myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
    self.view.addSubview(myNavigationBar)
    myNavigationBar.topToSuperview()
    myNavigationBar.leftToSuperview()
    myNavigationBar.rightToSuperview()
    myNavigationBar.height(UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBar = myNavigationBar
  }
}

extension ANIRecruitDetailViewController: ANIRecruitDetailViewDelegate {
  func recruitDetailViewDidScroll(offset: CGFloat) {
    guard let myNavigationBar = self.myNavigationBar  else { return }
    
      if offset > 1 {
        let backGroundColorOffset: CGFloat = 1.0
        let tintColorOffset = 1.0 - offset
        self.navigationController?.navigationBar.tintColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
        myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: backGroundColorOffset)
      } else {
        let tintColorOffset = 1.0 - offset
        self.navigationController?.navigationBar.tintColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
        myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
      }
  }
}
