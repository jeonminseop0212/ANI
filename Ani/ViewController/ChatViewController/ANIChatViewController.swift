//
//  ANIChatViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/27.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints
import FirebaseDatabase
import CodableFirebase

protocol ANIChatViewControllerDelegate {
  func chatViewWillDismiss()
}

class ANIChatViewController: UIViewController {
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBase: UIView?
  private weak var backButton: UIButton?
  private weak var navigationTitleLabel: UILabel?
  
  private weak var chatView: ANIChatView?
  
  private var chatBarBottomConstraint: Constraint?
  private var chatBarOriginalBottomConstraintConstant: CGFloat?
  private weak var chatBar: ANIChatBar?
  
  var user: FirebaseUser? {
    didSet {
      checkGroup()
    }
  }
  
  private var chatGroupId: String? {
    didSet {
      guard let chatView = self.chatView,
            let chatBar = self.chatBar else { return }
      
      chatView.chatGroupId = chatGroupId
      chatView.user = user
      chatBar.chatGroupId = chatGroupId
      chatBar.user = user
    }
  }
  
  private var isHaveGroup: Bool = false {
    didSet {
      guard let chatBar = self.chatBar else { return }
      
      chatBar.isHaveGroup = isHaveGroup
    }
  }
  
  var isPush: Bool = false
  
  var delegate: ANIChatViewControllerDelegate?
  
  override func viewDidLoad() {
    setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
    setupNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    removeNotifications()
    removeGroup()
  }
    
  private func setup() {
    //basic
    self.view.backgroundColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false
    
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
    
    //backButton
    let backButton = UIButton()
    if isPush {
      let backButtonImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate)
      backButton.setImage(backButtonImage, for: .normal)
    } else {
      let backButtonImage = UIImage(named: "dismissButton")?.withRenderingMode(.alwaysTemplate)
      backButton.setImage(backButtonImage, for: .normal)
    }
    backButton.tintColor = ANIColor.dark
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    myNavigationBase.addSubview(backButton)
    backButton.width(44.0)
    backButton.height(44.0)
    backButton.leftToSuperview()
    backButton.centerYToSuperview()
    self.backButton = backButton
    
    //navigationTitleLabel
    let navigationTitleLabel = UILabel()
    if let user = self.user, let userName = user.userName {
      navigationTitleLabel.text = userName
    }
    navigationTitleLabel.textColor = ANIColor.dark
    navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    myNavigationBase.addSubview(navigationTitleLabel)
    navigationTitleLabel.centerInSuperview()
    self.navigationTitleLabel = navigationTitleLabel
    
    //chatBar
    let chatBar = ANIChatBar()
    if let chatGroupId = self.chatGroupId {
      chatBar.user = user
      chatBar.chatGroupId = chatGroupId
    }
    self.view.addSubview(chatBar)
    chatBar.leftToSuperview()
    chatBar.rightToSuperview()
    chatBarBottomConstraint = chatBar.bottomToSuperview(usingSafeArea: true)
    chatBarOriginalBottomConstraintConstant = chatBarBottomConstraint?.constant
    self.chatBar = chatBar
    
    //chatView
    let chatView = ANIChatView()
    if let chatGroupId = self.chatGroupId {
      chatView.user = user
      chatView.chatGroupId = chatGroupId
    }
    self.view.addSubview(chatView)
    chatView.topToBottom(of: myNavigationBar)
    chatView.leftToSuperview()
    chatView.rightToSuperview()
    chatView.bottomToTop(of: chatBar)
    self.chatView = chatView
  }
  
  private func checkGroup() {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid,
          let user = self.user,
          let userId = user.uid else { return }
    
    let databaseRef = Database.database().reference()
    databaseRef.child(KEY_CHAT_GROUP_IDS).child(currentUserUid).observeSingleEvent(of: .value) { (snapshot) in
      if let chatGroupIds = snapshot.value as? [String: String] {
        for (index, chatGroupId) in chatGroupIds.keys.enumerated() {
          databaseRef.child(KEY_CHAT_GROUPS).child(chatGroupId).child(KEY_CHAT_MEMBER_IDS).observeSingleEvent(of: .value) { (snapshot) in
            if let memberIdsDic = snapshot.value as? [String: Bool] {
              if memberIdsDic.keys.contains(userId) {
                self.chatGroupId = chatGroupId
                self.isHaveGroup = true
              } else if index == (chatGroupIds.count - 1), self.chatGroupId == nil {
                self.createGroup()
              }
            } else {
              self.createGroup()
            }
          }
        }
      } else {
        self.createGroup()
      }
    }
  }
  
  private func createGroup() {
    let databaseRef = Database.database().reference()
    let databaseChatGroupRef = databaseRef.child(KEY_CHAT_GROUPS).childByAutoId()
    let id = databaseChatGroupRef.key
    let date = ANIFunction.shared.getToday()
    let group = FirebaseChatGroup(groupId:id, memberIds: nil, updateDate: date, lastMessage: "")
    
    DispatchQueue.global().async {
      do {
        if let data = try FirebaseEncoder().encode(group) as? [String : AnyObject] {
          databaseChatGroupRef.updateChildValues(data)
          
          self.chatGroupId = id
        }
      } catch let error {
        print(error)
      }
    }
  }
  
  private func removeGroup() {
    guard let chatGroupId = self.chatGroupId else { return }
    
    let databaseRef = Database.database().reference()
    
    databaseRef.child(KEY_CHAT_GROUPS).child(chatGroupId).child(KEY_CHAT_LAST_MESSAGE).observeSingleEvent(of: .value) { (snapshot) in
      guard let snapshot = snapshot.value as? String else { return }
      
      if snapshot == "" {
        databaseRef.child(KEY_CHAT_GROUPS).child(chatGroupId).removeValue()
        
        self.chatGroupId = nil
      }
    }
  }
  
  //MARK: notification
  private func setupNotifications() {
    ANINotificationManager.receive(keyboardWillChangeFrame: self, selector: #selector(keyboardWillChangeFrame))
    ANINotificationManager.receive(keyboardWillHide: self, selector: #selector(keyboardWillHide))
    ANINotificationManager.receive(profileImageViewTapped: self, selector: #selector(pushOtherProfile))
    ANINotificationManager.receive(applicationWillResignActive: self, selector: #selector(willResignActivity))
    ANINotificationManager.receive(applicationWillEnterForeground: self, selector: #selector(willEnterForeground))
  }
  
  private func removeNotifications() {
    ANINotificationManager.remove(self)
  }
  
  @objc private func keyboardWillChangeFrame(_ notification: Notification) {
    guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
          let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
          let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
          let commentBarBottomConstraint = self.chatBarBottomConstraint,
          let window = UIApplication.shared.keyWindow,
          let chatView = self.chatView else { return }
    
    let h = keyboardFrame.height
    let bottomSafeArea = window.safeAreaInsets.bottom
    
    commentBarBottomConstraint.constant = -h + bottomSafeArea
    
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
    
    chatView.scrollToBottom()
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
          let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
          let commentBarOriginalBottomConstraintConstant = self.chatBarOriginalBottomConstraintConstant,
          let commentBarBottomConstraint = self.chatBarBottomConstraint else { return }
    
    commentBarBottomConstraint.constant = commentBarOriginalBottomConstraintConstant
    
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @objc private func pushOtherProfile(_ notification: NSNotification) {
    guard let userId = notification.object as? String else { return }

    let otherProfileViewController = ANIOtherProfileViewController()
    otherProfileViewController.hidesBottomBarWhenPushed = true
    otherProfileViewController.userId = userId
    self.navigationController?.pushViewController(otherProfileViewController, animated: true)
  }
  
  @objc private func willResignActivity() {
    if !isHaveGroup {
      removeGroup()
    }
  }
  
  @objc private func willEnterForeground() {
    if !isHaveGroup {
      checkGroup()
    }
  }
  
  //MARK: Action
  @objc private func back() {
    self.view.endEditing(true)
    self.delegate?.chatViewWillDismiss()
    
    if isPush {
      self.navigationController?.popViewController(animated: true)
    } else {
      self.dismiss(animated: true)
    }
  }
}
