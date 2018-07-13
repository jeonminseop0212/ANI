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
  
  var currentUser: FirebaseUser?
  var currentUserUid: String?
  
  var isAnonymous: Bool = false
  
  let client = Client(appID: "RBJYX5VF88", apiKey: "ebf262fa4367637cd49431402d70455c")
}
