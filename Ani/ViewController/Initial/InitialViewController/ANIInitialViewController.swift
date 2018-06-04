//
//  ANIInitialViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/23.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIInitialViewController: UIViewController {
  
  private weak var initialView: ANIInitialView?
  
  override func viewDidLoad() {
    setup()
  }
  
  private func setup() {
    //basic
    self.view.backgroundColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false
    UIApplication.shared.isStatusBarHidden = true
    
    //initialView
    let initialView = ANIInitialView()
    initialView.delegate = self
    self.view.addSubview(initialView)
    initialView.edgesToSuperview()
    self.initialView = initialView
  }
}

//MARK: ANIInitialViewDelegate
extension ANIInitialViewController: ANIInitialViewDelegate {
  func loginButtonTapped() {
    let loginViewController = ANILoginViewController()
    self.navigationController?.pushViewController(loginViewController, animated: true)
  }
  
  func signUpButtonTapped() {
    let signUpViewController = ANISignUpViewController()
    self.navigationController?.pushViewController(signUpViewController, animated: true)
  }
}
