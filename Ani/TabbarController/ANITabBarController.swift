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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //tabBar上の線を消す
    let tabBarAppearane = UITabBar.appearance()
    tabBarAppearane.barTintColor = .white
    tabBar.alpha = 0.95
    tabBar.layer.borderWidth = 0.0
    tabBar.clipsToBounds = true
    
    let recruitVC = ANIRecruitViewController()
    recruitVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)
    let recruitNV = UINavigationController(rootViewController: recruitVC)
    
    let communityVC = ANICommunityViewController()
    communityVC.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
    let communityNV = UINavigationController(rootViewController: communityVC)
    
    let notiVC = ANINotiViewController()
    notiVC.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 3)
    let notiNV = UINavigationController(rootViewController: notiVC)
    
    let searchVC = ANISearchViewController()
    searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 4)
    let searchNV = UINavigationController(rootViewController: searchVC)
    
    let profileVC = ANIProfileViewController()
    profileVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 5)
    let profileNV = UINavigationController(rootViewController: profileVC)
    
    setViewControllers([recruitNV, communityNV, notiNV, searchNV, profileNV], animated: false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    
//    do {
//      try Auth.auth().signOut()
//    } catch let signOutError as NSError {
//      print("signOutError \(signOutError)")
//    }
    ANISessionManager.shared.currentUserUid = Auth.auth().currentUser?.uid
    if let currentUserUid = ANISessionManager.shared.currentUserUid {
      let activityData = ActivityData(size: CGSize(width: 40.0, height: 40.0),type: .lineScale, color: ANIColor.green)
      NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
      
      DispatchQueue.global().async {
        Database.database().reference().child(KEY_USERS).child(currentUserUid).observe(.value, with: { (snapshot) in
          guard let value = snapshot.value else { return }
          do {
            let user = try FirebaseDecoder().decode(FirebaseUser.self, from: value)
            DispatchQueue.main.async {
              ANISessionManager.shared.currentUser = user
              NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }
          } catch let error {
            print(error)
          }
        })
      }
    } else {
      do {
        try Auth.auth().signOut()
      } catch let signOutError as NSError {
        print("signOutError \(signOutError)")
      }
      
      showInitialView()
    }
  }
  
  private func showInitialView() {
    let initialViewController = ANIInitialViewController()
    let initialNV = UINavigationController(rootViewController: initialViewController)
    self.present(initialNV, animated: true, completion: nil)
  }
}
