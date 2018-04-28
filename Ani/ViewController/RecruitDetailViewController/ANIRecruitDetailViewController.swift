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
  private weak var backButton: UIButton?
  private weak var clipButton: ANIImageButtonView?
  
  private weak var recruitDetailView: ANIRecruitDetailView?
  
  var testRecruit: Recruit?

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .lightContent
  }
  
  private func setup() {
    //basic
    self.navigationController?.navigationBar.tintColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false

    //recruitDetailView
    let recruitDetailView = ANIRecruitDetailView()
    recruitDetailView.headerMinHeight = UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT
    recruitDetailView.delegate = self
    recruitDetailView.testRecruit = testRecruit
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
    
    //backButton
    let backButton = UIButton()
    let backButtonImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate)
    backButton.setImage(backButtonImage, for: .normal)
    backButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    myNavigationBar.addSubview(backButton)
    backButton.width(44.0)
    backButton.height(44.0)
    backButton.leftToSuperview()
    backButton.bottomToSuperview()
    self.backButton = backButton
    
    //clipButton
    let clipButton = ANIImageButtonView()
    let clipButtonImage = UIImage(named: "clipButton")?.withRenderingMode(.alwaysTemplate)
    clipButton.image = clipButtonImage
    clipButton.delegate = self
    clipButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    myNavigationBar.addSubview(clipButton)
    clipButton.width(44.0)
    clipButton.height(44.0)
    clipButton.rightToSuperview()
    clipButton.bottomToSuperview()
    self.clipButton = clipButton
  }
  
  //MARK: Action
  @objc private func back() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension ANIRecruitDetailViewController: ANIRecruitDetailViewDelegate {
  func recruitDetailViewDidScroll(offset: CGFloat) {
    guard let myNavigationBar = self.myNavigationBar,
          let backButton = self.backButton else { return }
    
      if offset > 1 {
        let backGroundColorOffset: CGFloat = 1.0
        let tintColorOffset = 1.0 - offset
        backButton.tintColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
        clipButton?.tintColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
        myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: backGroundColorOffset)
        UIApplication.shared.statusBarStyle = .default
      } else {
        let tintColorOffset = 1.0 - offset
        let ANIColorDarkBrightness: CGFloat = 0.18
        if tintColorOffset > ANIColorDarkBrightness {
          backButton.tintColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
          clipButton?.tintColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
        } else {
          backButton.tintColor = UIColor(hue: 0, saturation: 0, brightness: ANIColorDarkBrightness, alpha: 1)
          clipButton?.tintColor = UIColor(hue: 0, saturation: 0, brightness: ANIColorDarkBrightness, alpha: 1)
        }
       
        myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
        UIApplication.shared.statusBarStyle = .lightContent
      }
  }
}

extension ANIRecruitDetailViewController: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === self.clipButton {
      print("clip button tapped")
    }
  }
}
