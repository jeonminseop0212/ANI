//
//  File.swift
//  Ani
//
//  Created by jeonminseop on 2020/03/29.
//  Copyright © 2020 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIForgetPasswordViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBarBase: UIView?
  private weak var backButton: UIButton?
  
  private weak var forgetPasswordView: ANIForgetPasswordView?
  
  private var rejectViewBottomConstraint: Constraint?
  private var rejectViewBottomConstraintOriginalConstant: CGFloat?
  private weak var rejectView: UIView?
  private weak var rejectBaseView: UIView?
  private weak var rejectLabel: UILabel?
  private var isRejectAnimating: Bool = false
  
  private weak var activityIndicatorView: ANIActivityIndicator?
  
  override func viewDidLoad() {
    setup()
  }
  
  private func setup() {
    //basic
    self.view.backgroundColor = .white
    
    //myNavigationBar
    let myNavigationBar = UIView()
    myNavigationBar.backgroundColor = .white
    self.view.addSubview(myNavigationBar)
    myNavigationBar.topToSuperview()
    myNavigationBar.leftToSuperview()
    myNavigationBar.rightToSuperview()
    myNavigationBar.height(UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBar = myNavigationBar
    
    //myNavigationBarBase
    let myNavigationBarBase = UIView()
    myNavigationBar.addSubview(myNavigationBarBase)
    myNavigationBarBase.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    myNavigationBarBase.bottomToSuperview()
    myNavigationBarBase.leftToSuperview()
    myNavigationBarBase.rightToSuperview()
    self.myNavigationBarBase = myNavigationBarBase
    
    //backButton
    let backButton = UIButton()
    let dismissButtonImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate)
    backButton.setImage(dismissButtonImage, for: .normal)
    backButton.tintColor = ANIColor.dark
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    myNavigationBarBase.addSubview(backButton)
    backButton.width(UIViewController.NAVIGATION_BAR_HEIGHT)
    backButton.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    backButton.leftToSuperview()
    backButton.centerYToSuperview()
    self.backButton = backButton
    
    //forgetPasswordView
    let forgetPasswordView = ANIForgetPasswordView()
    forgetPasswordView.delegate = self
    self.view.addSubview(forgetPasswordView)
    forgetPasswordView.topToBottom(of: myNavigationBar)
    forgetPasswordView.leftToSuperview()
    forgetPasswordView.rightToSuperview()
    forgetPasswordView.bottomToSuperview()
    self.forgetPasswordView = forgetPasswordView
    
    //rejectView
    let rejectView = UIView()
    rejectView.backgroundColor = ANIColor.emerald
    self.view.addSubview(rejectView)
    rejectViewBottomConstraint = rejectView.bottomToTop(of: self.view)
    rejectViewBottomConstraintOriginalConstant = rejectViewBottomConstraint?.constant
    rejectView.leftToSuperview()
    rejectView.rightToSuperview()
    rejectView.height(UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT)
    self.rejectView = rejectView
    
    //rejectBaseView
    let rejectBaseView = UIView()
    rejectBaseView.backgroundColor = ANIColor.emerald
    rejectView.addSubview(rejectBaseView)
    rejectBaseView.edgesToSuperview(excluding: .top)
    rejectBaseView.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    self.rejectBaseView = rejectBaseView
    
    //rejectLabel
    let rejectLabel = UILabel()
    rejectLabel.textAlignment = .center
    rejectLabel.textColor = .white
    rejectLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
    rejectLabel.text = "登録されていないメールアドレスです！"
    rejectLabel.textAlignment = .center
    rejectBaseView.addSubview(rejectLabel)
    rejectLabel.edgesToSuperview()
    self.rejectLabel = rejectLabel
  }
  
  //MARK: action
  @objc private func back() {
    self.navigationController?.popViewController(animated: true)
  }
}

//MARK: ANIForgetPasswordViewDelegate
extension ANIForgetPasswordViewController: ANIForgetPasswordViewDelegate {
  func reject(notiText: String) {
    guard let rejectViewBottomConstraint = self.rejectViewBottomConstraint,
          !isRejectAnimating,
          let rejectLabel = self.rejectLabel else { return }
    
    rejectLabel.text = notiText
    
    rejectViewBottomConstraint.constant = UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
      self.isRejectAnimating = true
      self.view.layoutIfNeeded()
    }) { (complete) in
      guard let rejectViewBottomConstraint = self.rejectViewBottomConstraint,
            let rejectViewBottomConstraintOriginalConstant = self.rejectViewBottomConstraintOriginalConstant else { return }
      
      rejectViewBottomConstraint.constant = rejectViewBottomConstraintOriginalConstant
      UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseInOut, animations: {
        self.view.layoutIfNeeded()
      }, completion: { (complete) in
        self.isRejectAnimating = false
      })
    }
  }
  
  func startAnimaing() {
    self.activityIndicatorView?.startAnimating()
  }
  
  func stopAnimating() {
    self.activityIndicatorView?.stopAnimating()
  }
}
