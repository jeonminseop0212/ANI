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
    }
  }
  
  var delegate: ANIChatViewControllerDelegate?
  
  override func viewDidLoad() {
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
    let backButtonImage = UIImage(named: "dismissButton")?.withRenderingMode(.alwaysTemplate)
    backButton.setImage(backButtonImage, for: .normal)
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
    self.view.addSubview(chatBar)
    chatBar.leftToSuperview()
    chatBar.rightToSuperview()
    chatBarBottomConstraint = chatBar.bottomToSuperview(usingSafeArea: true)
    chatBarOriginalBottomConstraintConstant = chatBarBottomConstraint?.constant
    self.chatBar = chatBar
    
    //chatView
    let chatView = ANIChatView()
    self.view.addSubview(chatView)
    chatView.topToBottom(of: myNavigationBar)
    chatView.leftToSuperview()
    chatView.rightToSuperview()
    chatView.bottomToTop(of: chatBar)
    self.chatView = chatView
  }
  
  override func viewDidAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
    setupNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    removeNotifications()
  }
  
  private func checkGroup() {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let currentUserUid = ANISessionManager.shared.currentUserUid,
          let user = self.user,
          let userId = user.uid else { return }
    
    if let chatGroupIds = currentUser.chatGroupIds {
      let databaseRef = Database.database().reference()
      
      DispatchQueue.global().async {
        for chatGroupId in chatGroupIds {
          databaseRef.child(KEY_CHAT_GROUPS).child(chatGroupId.key).child(KEY_CHAT_MEMBER_IDS).observeSingleEvent(of: .value) { (snapshot) in
            guard let memberIdsDic = snapshot.value as? [String: Bool] else { return }
            
            for memberId in memberIdsDic.keys {
              if memberId == userId {
                self.chatGroupId = chatGroupId.key
              } else if memberId != currentUserUid {
                self.createGroup()
              }
            }
          }
        }
      }
    } else {
      createGroup()
    }
  }
  
  private func createGroup() {
    guard let user = self.user,
          let userId = user.uid,
          let currentUserUid = ANISessionManager.shared.currentUserUid else { return }
    
    let databaseRef = Database.database().reference()
    let databaseChatGroupRef = databaseRef.child(KEY_CHAT_GROUPS).childByAutoId()
    let id = databaseChatGroupRef.key
    let memberIds = [userId: true, currentUserUid: true]
    let date = ANIFunction.shared.getToday()
    let group = FirebaseChatGroup(groupId:id, memberIds: memberIds, updateDate: date, lastMessage: nil)
    
    DispatchQueue.global().async {
      do {
        if let data = try FirebaseEncoder().encode(group) as? [String : AnyObject] {
          databaseChatGroupRef.updateChildValues(data)
          
          do {
            if let currentUserUid = ANISessionManager.shared.currentUserUid {
              let detabaseUsersRef = databaseRef.child(KEY_USERS).child(currentUserUid).child(KEY_CHAT_GROUP_IDS)
              let value: [String: Bool] = [id: true]
              detabaseUsersRef.updateChildValues(value)
            }
          }
          
          do {
            if let user = self.user, let userId = user.uid {
              let detabaseUsersRef = databaseRef.child(KEY_USERS).child(userId).child(KEY_CHAT_GROUP_IDS)
              let value: [String: Bool] = [id: true]
              detabaseUsersRef.updateChildValues(value)
            }
          }
        }
      } catch let error {
        print(error)
      }
    }
  }
  
  //MARK: notification
  private func setupNotification() {
    ANINotificationManager.receive(keyboardWillChangeFrame: self, selector: #selector(keyboardWillChangeFrame))
    ANINotificationManager.receive(keyboardWillHide: self, selector: #selector(keyboardWillHide))
    ANINotificationManager.receive(profileImageViewTapped: self, selector: #selector(pushOtherProfile))
  }
  
  private func removeNotifications() {
    ANINotificationManager.remove(self)
  }
  
  @objc private func keyboardWillChangeFrame(_ notification: Notification) {
    guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
      let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
      let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
      let commentBarBottomConstraint = self.chatBarBottomConstraint,
      let window = UIApplication.shared.keyWindow else { return }
    
    let h = keyboardFrame.height
    let bottomSafeArea = window.safeAreaInsets.bottom
    
    commentBarBottomConstraint.constant = -h + bottomSafeArea
    
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
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
  
  //MARK: Action
  @objc private func back() {
    self.view.endEditing(true)
    self.delegate?.chatViewWillDismiss()
    self.dismiss(animated: true)
  }
}
