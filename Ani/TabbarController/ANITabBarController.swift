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
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    
    let userDefault = UserDefaults.standard
    let dic = [KEY_FIRST_LAUNCH: true]
    userDefault.register(defaults: dic)
    
    loadUser()
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
}

//MARK: data
extension ANITabBarController {
  private func loadUser() {
    let userDefault = UserDefaults.standard

    ANISessionManager.shared.currentUserUid = Auth.auth().currentUser?.uid
    if let currentUserUid = ANISessionManager.shared.currentUserUid {
      let database = Firestore.firestore()
      DispatchQueue.global().async {
        database.collection(KEY_USERS).document(currentUserUid).addSnapshotListener({ (snapshot, error) in
          guard let snapshot = snapshot, let value = snapshot.data() else { return }
          
          do {
            let user = try FirestoreDecoder().decode(FirebaseUser.self, from: value)
            
            DispatchQueue.main.async {
              ANISessionManager.shared.currentUser = user
              ANISessionManager.shared.isAnonymous = false
              
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
}
