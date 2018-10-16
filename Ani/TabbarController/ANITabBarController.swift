//
//  TabBarController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/02.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class ANITabBarController: UITabBarController {
  
  private let BADGE_WIDHT: CGFloat = 5.0
  private weak var badge: UIView?
  
  private let NUMBER_OF_NOTI_TAB: Int = 2

  private var showingTabTag: Int = 0
  
  private var oldIsHaveUnreadNoti: Bool = false
  private var oldIsHaveUnreadMessage: Bool = false
  
  private var userListener: ListenerRegistration?
  private var chatGroupListener: ListenerRegistration?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //tabBar上の線を消す
    let tabBarAppearane = UITabBar.appearance()
    tabBarAppearane.backgroundImage = UIImage()
    tabBarAppearane.shadowImage = UIImage()
    tabBarAppearane.backgroundColor = UIColor(red: 255, green: 255, blue: 255, a: 0.95)
    tabBar.layer.borderWidth = 0.0
    tabBar.clipsToBounds = true
    
    setTabBar()
    setupBadge()
    
    loadUser()
    observeChatGroup()
    setupNotification()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    
    let userDefault = UserDefaults.standard
    let dic = [KEY_FIRST_LAUNCH: true]
    userDefault.register(defaults: dic)
  }
  
  private func setTabBar() {
    let recruitVC = ANIRecruitViewController()
    recruitVC.tabBarItem.image = UIImage(named: "home")?.withRenderingMode(.alwaysOriginal)
    recruitVC.tabBarItem.selectedImage = UIImage(named: "homeSelected")?.withRenderingMode(.alwaysOriginal)
    recruitVC.tabBarItem.tag = 0
    let recruitNV = UINavigationController(rootViewController: recruitVC)
    
    let communityVC = ANICommunityViewController()
    communityVC.tabBarItem.image = UIImage(named: "community")?.withRenderingMode(.alwaysOriginal)
    communityVC.tabBarItem.selectedImage = UIImage(named: "communitySelected")?.withRenderingMode(.alwaysOriginal)
    communityVC.tabBarItem.tag = 1
    let communityNV = UINavigationController(rootViewController: communityVC)
    
    let notiVC = ANINotiViewController()
    notiVC.tabBarItem.image = UIImage(named: "noti")?.withRenderingMode(.alwaysOriginal)
    notiVC.tabBarItem.selectedImage = UIImage(named: "notiSelected")?.withRenderingMode(.alwaysOriginal)
    notiVC.tabBarItem.tag = 2
    let notiNV = UINavigationController(rootViewController: notiVC)
    
    let searchVC = ANISearchViewController()
    searchVC.tabBarItem.image = UIImage(named: "search")?.withRenderingMode(.alwaysOriginal)
    searchVC.tabBarItem.selectedImage = UIImage(named: "searchSelected")?.withRenderingMode(.alwaysOriginal)
    searchVC.tabBarItem.tag = 3
    let searchNV = UINavigationController(rootViewController: searchVC)
    
    let profileVC = ANIProfileViewController()
    profileVC.tabBarItem.image = UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal)
    profileVC.tabBarItem.selectedImage = UIImage(named: "profileSelected")?.withRenderingMode(.alwaysOriginal)
    profileVC.tabBarItem.tag = 4
    let profileNV = UINavigationController(rootViewController: profileVC)
    
    setViewControllers([recruitNV, communityNV, notiNV, searchNV, profileNV], animated: false)
    
    if let items = tabBar.items {
      for item in items {
        item.imageInsets = UIEdgeInsets.init(top: 4.0, left: 0.0, bottom: -4.0, right: 0.0)
      }
    }
  }
  
  private func setupBadge() {
    if self.tabBar.subviews.count > NUMBER_OF_NOTI_TAB {
      let tabBarButton = self.tabBar.subviews[NUMBER_OF_NOTI_TAB]
      for subView in tabBarButton.subviews {
        guard let icon = subView as? UIImageView else { continue }

        let badge = UIView()
        badge.backgroundColor = ANIColor.red
        badge.layer.cornerRadius = BADGE_WIDHT / 2
        badge.layer.masksToBounds = true
        badge.alpha = 0.0
        icon.addSubview(badge)
        badge.centerX(to: icon, icon.rightAnchor)
        badge.centerY(to: icon, icon.topAnchor, offset: 2)
        badge.width(BADGE_WIDHT)
        badge.height(BADGE_WIDHT)
        self.badge = badge
        
        break
      }
    }
  }
  
  private func showInitialView() {
    let initialViewController = ANIInitialViewController()
    let initialNV = UINavigationController(rootViewController: initialViewController)
    self.present(initialNV, animated: true, completion: nil)
  }
  
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    switch item.tag {
    case 0:
      if showingTabTag == 0 {
        ANINotificationManager.postRecruitTabTapped()
      }
      showingTabTag = 0
    case 1:
      if showingTabTag == 1 {
        ANINotificationManager.postCommunityTabTapped()
      }
      showingTabTag = 1
    case 2:
      if showingTabTag == 2 {
        ANINotificationManager.postNotiTabTapped()
      }
      showingTabTag = 2
    case 3:
      if showingTabTag == 3 {
        ANINotificationManager.postSearchTabTapped()
      }
      showingTabTag = 3
    case 4:
      if showingTabTag == 4 {
        ANINotificationManager.postProfileTabTapped()
      }
      showingTabTag = 4
    default:
      DLog("default tab")
    }
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(changeIsHaveUnreadNoti: self, selector: #selector(updateBadge))
    ANINotificationManager.receive(changeIsHaveUnreadMessage: self, selector: #selector(updateBadge))
    ANINotificationManager.receive(login: self, selector: #selector(relogin))
    ANINotificationManager.receive(logout: self, selector: #selector(logout))
  }
  
  @objc private func updateBadge() {
    guard let badge = self.badge else { return }
    
    if ANISessionManager.shared.isHaveUnreadNoti || ANISessionManager.shared.isHaveUnreadMessage {
      badge.alpha = 1.0
    } else {
      badge.alpha = 0.0
    }
  }
  
  @objc private func relogin() {
    loadUser(relogin: true)
    observeChatGroup()
  }
  
  @objc private func logout() {
    guard let userListener = self.userListener,
          let chatGroupListener = self.chatGroupListener else { return }
    
    userListener.remove()
    chatGroupListener.remove()
    
    ANISessionManager.shared.isHaveUnreadNoti = false
    ANISessionManager.shared.isHaveUnreadMessage = false
    
    oldIsHaveUnreadNoti = false
    oldIsHaveUnreadMessage = false
  }
}

//MARK: data
extension ANITabBarController {
  private func loadUser(relogin: Bool = false) {
    let userDefault = UserDefaults.standard
    
    if let userListener = self.userListener {
      userListener.remove()
    }

    ANISessionManager.shared.currentUserUid = Auth.auth().currentUser?.uid
    if let currentUserUid = ANISessionManager.shared.currentUserUid {
      let database = Firestore.firestore()
      DispatchQueue.global().async {
        self.userListener = database.collection(KEY_USERS).document(currentUserUid).addSnapshotListener({ (snapshot, error) in
          guard let snapshot = snapshot, let value = snapshot.data() else { return }
          
          do {
            let user = try FirestoreDecoder().decode(FirebaseUser.self, from: value)
            
            DispatchQueue.main.async {
              if !relogin {
                ANISessionManager.shared.currentUser = user
                ANISessionManager.shared.isAnonymous = false
              }
              
              if let isHaveUnreadNoti = user.isHaveUnreadNoti {
                if self.oldIsHaveUnreadNoti != isHaveUnreadNoti {
                  ANISessionManager.shared.isHaveUnreadNoti = isHaveUnreadNoti
                }
                
                self.oldIsHaveUnreadNoti = isHaveUnreadNoti
              }
            }
          } catch let error {
            DLog(error)
          }
        })
      }
    } else {
      do {
        try Auth.auth().signOut()
      } catch let signOutError as NSError {
        DLog("signOutError \(signOutError)")
      }
      
      ANISessionManager.shared.isAnonymous = true
      
      if userDefault.bool(forKey: KEY_FIRST_LAUNCH) {
        userDefault.set(false, forKey: KEY_FIRST_LAUNCH)
        showInitialView()
      }
    }
  }
  
  private func observeChatGroup() {
    guard let crrentUserUid = ANISessionManager.shared.currentUserUid else { return }
    
    let database = Firestore.firestore()
    
    if let chatGroupListener = self.chatGroupListener {
      chatGroupListener.remove()
    }
    
    DispatchQueue.global().async {
      self.chatGroupListener = database.collection(KEY_CHAT_GROUPS).whereField(KEY_CHAT_MEMBER_IDS + "." + crrentUserUid, isEqualTo: true).whereField(KEY_IS_HAVE_UNREAD_MESSAGE + "." + crrentUserUid, isEqualTo: true).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }

        snapshot.documentChanges.forEach({ (diff) in
          if diff.type == .added {
            if self.oldIsHaveUnreadMessage != true {
              ANISessionManager.shared.isHaveUnreadMessage = true
            }
            self.oldIsHaveUnreadMessage = ANISessionManager.shared.isHaveUnreadMessage
          } else if diff.type == .modified {
            if self.oldIsHaveUnreadMessage != true {
              ANISessionManager.shared.isHaveUnreadMessage = true
            }
            self.oldIsHaveUnreadMessage = ANISessionManager.shared.isHaveUnreadMessage
          }
        })
        
        if snapshot.documents.isEmpty {
          if self.oldIsHaveUnreadMessage != false {
            ANISessionManager.shared.isHaveUnreadMessage = false
          }
          self.oldIsHaveUnreadMessage = ANISessionManager.shared.isHaveUnreadMessage
        }
      })
    }
  }
}
