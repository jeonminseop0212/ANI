//
//  FirebaseUser.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/31.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class FirebaseUser: NSObject {
  @objc var uid: String?
  @objc var userName: String?
  @objc var kind: String?
  @objc var introduce: String?
  @objc var profileImageUrl: String?
  @objc var familyImageUrls: [String]?
}
