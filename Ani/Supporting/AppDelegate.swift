//
//  AppDelegate.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/02.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseDynamicLinks
import FirebaseFirestore
import UserNotifications
import TwitterKit
import GoogleSignIn
import CodableFirebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var orientationLock = UIInterfaceOrientationMask.all
  private weak var tabBarController: ANITabBarController?
  private let NOTI_VIEW_CONTROLLER_INDEX: Int = 2
  
  enum SirenAlertType: String {
    case force;
    case option;
    case skip;
    case none;
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    self.orientationLock = .portrait
    
    _ = ANITwitter()
    ANIFirebaseRemoteConfigManager.shared.fetch()
    
    //notification
    application.registerForRemoteNotifications()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self
    
    let tabBarController = ANITabBarController()
    self.tabBarController = tabBarController
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = tabBarController
    window?.makeKeyAndVisible()
    
    ANIFirebaseRemoteConfigManager.shared.getShowReivewConditions { (conditions, error) in
      if error == nil, let conditions = conditions {
        ANISessionManager.shared.showReviewConditions = conditions
      }
    }
    
    //navigation bar
    let navigationBarAppearane = UINavigationBar.appearance()
    navigationBarAppearane.barTintColor = .white
    navigationBarAppearane.tintColor = ANIColor.dark
    navigationBarAppearane.setBackgroundImage(UIImage(), for: .default)
    navigationBarAppearane.shadowImage = UIImage()
    
    return true
  }
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return self.orientationLock
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    playTopViewControllerVideo()
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    let twitter =  TWTRTwitter.sharedInstance().application(app, open: url, options: options)
    let google = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) != nil ? true : false
    
    return twitter || google || dynamicLink
  }
  
  func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                   restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    
    if let webpageURL = userActivity.webpageURL {
      let handled = DynamicLinks.dynamicLinks().handleUniversalLink(webpageURL) { (dynamiclink, error) in
        if let error = error {
          DLog(error)
          return
        }
        
        guard let innerLink = webpageURL.queryValue(for: "link") else { return }
        
        let type = String(innerLink.split(separator: "/")[2])
        let id = String(innerLink.split(separator: "/")[3])
        
        self.openLink(id: id, type: type)
      }

      return handled
    } else {
      return false
    }
  }
  
  private func openLink(id: String, type: String) {
    guard let tabBarController = self.tabBarController,
          let navigationViewController = tabBarController.selectedViewController as? UINavigationController else { return }
    
    if type == KEY_STORY {
      let storyDetailViewController = ANIStoryDetailViewController()
      storyDetailViewController.storyId = id
      storyDetailViewController.hidesBottomBarWhenPushed = true
      navigationViewController.pushViewController(storyDetailViewController, animated: true)
    } else if type == KEY_RECRUIT {
      let recruitDetailViewController = ANIRecruitDetailViewController()
      recruitDetailViewController.recruitId = id
      recruitDetailViewController.hidesBottomBarWhenPushed = true
      navigationViewController.pushViewController(recruitDetailViewController, animated: true)
    } else if type == KEY_QNA {
      let qnaDetailViewController = ANIQnaDetailViewController()
      qnaDetailViewController.qnaId = id
      qnaDetailViewController.hidesBottomBarWhenPushed = true
      navigationViewController.pushViewController(qnaDetailViewController, animated: true)
    }
  }
  
  private func playTopViewControllerVideo() {
    if let topController = UIApplication.topViewController() {
      if let communityViewController = topController as? ANICommunityViewController {
        communityViewController.playVideo()
      }
      if let rankingStoryDetailViewController = topController as? ANIRankingStoryDetailViewController {
        rankingStoryDetailViewController.playVideo()
      }
      if let storyDetailViewController = topController as? ANIStoryDetailViewController {
        storyDetailViewController.playVideo()
      }
      if let notiDetailViewController = topController as? ANINotiDetailViewController {
        notiDetailViewController.playVideo()
      }
      if let profileViewController = topController as? ANIProfileViewController {
        profileViewController.playVideo()
      }
      if let otherProfileViewController = topController as? ANIOtherProfileViewController {
        otherProfileViewController.playVideo()
      }
      if let listViewController = topController as? ANIListViewController {
        listViewController.playVideo()
      }
    }
  }
  
  private func showEventIfNeeded() {
    let database = Firestore.firestore()
    
    let userDefaults = UserDefaults.standard
    
    if ANISessionManager.shared.isHiddenInitial && ANISessionManager.shared.isHiddenSplash {
      DispatchQueue.global().async {
        database.collection(KEY_EVENTS).getDocuments(completion: { (snapshot, error) in
          if let error = error {
            DLog("get event document error \(error)")
            return
          }
          
          guard let snapshot = snapshot else { return }
          
          for document in snapshot.documents {
            do {
              let event = try FirestoreDecoder().decode(FirebaseEvent.self, from: document.data())
              
              if userDefaults.object(forKey: KEY_SHOW_EVENT) == nil {
                let showEvents = [Int]()
                userDefaults.set(showEvents, forKey: KEY_SHOW_EVENT)
              }
              
              if let eventId = Int(event.id),
                let showEvents = userDefaults.object(forKey: KEY_SHOW_EVENT) as? [Int],
                !showEvents.contains(eventId) {
                let eventPopupViewController = ANIEventPopupViewController()
                eventPopupViewController.event = event
                eventPopupViewController.modalPresentationStyle = .overCurrentContext
                self.tabBarController?.present(eventPopupViewController, animated: false, completion: nil)
                
                userDefaults.set([eventId], forKey: KEY_SHOW_EVENT)
                
                ANISessionManager.shared.isShowEvent = true
              }
            } catch let error {
              DLog(error)
            }
          }
        })
      }
    }
  }
}

//MARK: UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
    let userInfo = notification.request.content.userInfo
    
    if let notificationKind = userInfo[AnyHashable("notificationKind")] as? String,
      notificationKind == PushNotificationKind.message.rawValue,
      let chatGroupId = userInfo[AnyHashable("chatGroupId")] as? String,
      ANISessionManager.shared.onlineChatGroupId == chatGroupId {
      completionHandler([])
      return
    }
    
    completionHandler([.badge])
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    Messaging.messaging().appDidReceiveMessage(userInfo)
    
    completionHandler(.newData)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    guard let tabBarController = self.tabBarController,
          let viewControllers = tabBarController.viewControllers,
          let notiNavigationController = viewControllers[NOTI_VIEW_CONTROLLER_INDEX] as? UINavigationController,
          let notiViewController = notiNavigationController.viewControllers.first as? ANINotiViewController else { return }
    
    ANISessionManager.shared.isLaunchNoti = true
    
    let userInfo = response.notification.request.content.userInfo
    if let notificationKind = userInfo[AnyHashable("notificationKind")] as? String {
      tabBarController.selectedIndex = NOTI_VIEW_CONTROLLER_INDEX

      if notificationKind == PushNotificationKind.noti.rawValue {
        notiViewController.pushNotificationKind = .noti
      } else if notificationKind == PushNotificationKind.message.rawValue, let sendUserId = userInfo[AnyHashable("sendUserId")] as? String {
        notiViewController.pushNotificationKind = .message
        notiViewController.sendPushNotificationUserId = sendUserId
      }
    }
    
    completionHandler()
  }
}

// MARK: MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    UserDefaults.standard.set(fcmToken, forKey: KEY_FCM_TOKEN)
    UserDefaults.standard.synchronize()
  }
  
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
  }
}
