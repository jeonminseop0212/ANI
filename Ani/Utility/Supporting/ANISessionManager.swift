//
//  ANISessionManager.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/31.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import InstantSearchClient

class ANISessionManager: NSObject {
  static let shared = ANISessionManager()
  
  var currentUser: FirebaseUser? {
    didSet {
      guard let currentUser = self.currentUser,
            let checkNotiDate = currentUser.checkNotiDate else { return }
      
      self.checkNotiDate = checkNotiDate
    }
  }
  
  var isHaveUnreadNoti: Bool = false {
    didSet {
      ANINotificationManager.postChangeIsHaveUnreadNoti()
    }
  }
  
  var checkNotiDate: String?
  
  var currentUserUid: String?
  
  var isAnonymous: Bool = false
  
  #if DEBUG
  let client = Client(appID: "RBJYX5VF88", apiKey: "ebf262fa4367637cd49431402d70455c")
  #else
  let client = Client(appID: "NF5ORAYV5G", apiKey: "e34e8cb3865dd2fe25a02fbf5b916755")
  #endif
}
