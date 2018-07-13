//
//  TabBarController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/02.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CodableFirebase
import NVActivityIndicatorView

class ANITabBarController: UITabBarController, NVActivityIndicatorViewable {
  
  private var showingTabTag: Int = 0
  
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
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    
    let userDefault = UserDefaults.standard
    let dic = [KEY_FIRST_LAUNCH: true]
    userDefault.register(defaults: dic)
    
    ANISessionManager.shared.currentUserUid = Auth.auth().currentUser?.uid
    if let currentUserUid = ANISessionManager.shared.currentUserUid {
      let activityData = ActivityData(size: CGSize(width: 40.0, height: 40.0),type: .lineScale, color: ANIColor.green)
      NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
      
      DispatchQueue.global().async {
        Database.database().reference().child(KEY_USERS).child(currentUserUid).observe(.value, with: { (snapshot) in
          guard let value = snapshot.value else { return }
          do {
            let user = try FirebaseDecoder().decode(FirebaseUser.self, from: value)
            DispatchQueue.main.async {
              ANISessionManager.shared.currentUser = user
              ANISessionManager.shared.isAnonymous = false
              
              NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            }
          } catch let error {
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
          }
        })
      }
    } else {
      do {
        try Auth.auth().signOut()
      } catch let signOutError as NSError {
        print("signOutError \(signOutError)")
      }
      
      ANISessionManager.shared.isAnonymous = true
      
      if userDefault.bool(forKey: KEY_FIRST_LAUNCH) {
        userDefault.set(false, forKey: KEY_FIRST_LAUNCH)
        showInitialView()
      }
    }
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
        item.imageInsets = UIEdgeInsetsMake(4.0, 0.0, -4.0, 0.0)
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
      print("default tab")
    }
  }
}
