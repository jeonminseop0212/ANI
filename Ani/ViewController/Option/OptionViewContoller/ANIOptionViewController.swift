//
//  ANIOptionViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/22.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class ANIOptionViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBase: UIView?
  private weak var navigationTitleLabel: UILabel?
  private weak var backButton: UIButton?
  
  private weak var optionView: ANIOptionView?
  
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
    
    //myNavigationBase
    let myNavigationBase = UIView()
    myNavigationBar.addSubview(myNavigationBase)
    myNavigationBase.edgesToSuperview(excluding: .top)
    myNavigationBase.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBase = myNavigationBase
    
    //navigationTitleLabel
    let navigationTitleLabel = UILabel()
    navigationTitleLabel.text = "オプション"
    navigationTitleLabel.textColor = ANIColor.dark
    navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    myNavigationBase.addSubview(navigationTitleLabel)
    navigationTitleLabel.centerInSuperview()
    self.navigationTitleLabel = navigationTitleLabel
    
    //backButton
    let backButton = UIButton()
    let backButtonImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate)
    backButton.setImage(backButtonImage, for: .normal)
    backButton.tintColor = ANIColor.dark
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    myNavigationBase.addSubview(backButton)
    backButton.width(44.0)
    backButton.height(44.0)
    backButton.leftToSuperview()
    backButton.centerYToSuperview()
    self.backButton = backButton
    
    //optionView
    let optionView = ANIOptionView()
    optionView.delegate = self
    self.view.addSubview(optionView)
    optionView.topToBottom(of: myNavigationBase)
    optionView.edgesToSuperview(excluding: .top)
    self.optionView = optionView
  }
  
  //MARK: action
  @objc private func back() {
    self.navigationController?.popViewController(animated: true)
  }
}

//MARK: ANIOptionViewDelegate
extension ANIOptionViewController: ANIOptionViewDelegate {
  func listTapped(list: List) {
    let listViewController = ANIListViewController()
    listViewController.list = list
    self.navigationController?.pushViewController(listViewController, animated: true)
  }
  
  func logoutTapped() {
    let alertController = UIAlertController(title: "ログアウト", message: "ログアウトしますか？\nアカウントで再ログインすることができます。", preferredStyle: .alert)
    
    let logoutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
      do {
        try Auth.auth().signOut()
        
        ANISessionManager.shared.currentUser = nil
        ANISessionManager.shared.currentUserUid = nil
        ANISessionManager.shared.isAnonymous = true
        ANISessionManager.shared.blockUserIds = nil
        ANISessionManager.shared.blockingUserIds = nil
        
        ANINotificationManager.postLogout()
        
        self.navigationController?.popViewController(animated: true)
      } catch let signOutError as NSError {
        DLog("signOutError \(signOutError)")
      }
    }
    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
    
    alertController.addAction(logoutAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  func blockUserTapped() {
    let blockUserViewController = ANIBlockUserViewController()
    self.navigationController?.pushViewController(blockUserViewController, animated: true)
  }
  
  func opinionBoxTapped() {
    let opinionBoxViewController = ANIOpinionBoxViewController()
    self.navigationController?.pushViewController(opinionBoxViewController, animated: true)
  }
  
  func contactTapped() {
    let adminUserId = ANISessionManager.shared.adminUserId
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_USERS).document(adminUserId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          return
        }
        
        guard let snapshot = snapshot,
          let data = snapshot.data() else { return }
        
        do {
          let adminUser = try FirestoreDecoder().decode(FirebaseUser.self, from: data)
          
          let chatViewController = ANIChatViewController()
          chatViewController.user = adminUser
          chatViewController.isPush = true
          chatViewController.hidesBottomBarWhenPushed = true
          self.navigationController?.pushViewController(chatViewController, animated: true)
        } catch let error {
          DLog(error)
        }
      })
    }
  }
}
