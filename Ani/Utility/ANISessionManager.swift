//
//  ANISessionManager.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/31.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANISessionManager: NSObject {
  static let shared = ANISessionManager()
  
  var currentUser: FirebaseUser?
}
