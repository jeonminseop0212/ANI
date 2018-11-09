//
//  ANIInitialViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/23.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseAuth
import SafariServices

class ANIInitialViewController: UIViewController {
  
  private weak var initialView: ANIInitialView?
  
  override func viewDidLoad() {
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBar?.alpha = 0.0
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    UIApplication.shared.statusBar?.alpha = 1.0
  }
  
  private func setup() {
    //basic
    ANIOrientation.lockOrientation(.portrait)
    self.view.backgroundColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    
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
  
  func startAnonymous() {
    self.dismiss(animated: true, completion: nil)
    
    do {
      try Auth.auth().signOut()
      
      ANISessionManager.shared.currentUser = nil
      ANISessionManager.shared.currentUserUid = nil
      ANISessionManager.shared.isAnonymous = true
      
      ANINotificationManager.postLogout()
      
    } catch let signOutError as NSError {
      DLog("signOutError \(signOutError)")
    }
  }
  
  func showPrivacyPolicy() {
    let urlString = "https://myau5.webnode.jp/プライバシーポリシー/"
    guard let privacyPolicyUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
          let url = URL(string: privacyPolicyUrl) else { return }
    
    let safariVC = SFSafariViewController(url: url)
    present(safariVC, animated: true, completion: nil)
  }
}

//MARK: UIGestureRecognizerDelegate
extension ANIInitialViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
