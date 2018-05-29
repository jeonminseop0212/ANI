//
//  User.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import Salada

class User: Salada.Object {
  
  typealias user = User
  
  @objc dynamic var uid: String?
  @objc dynamic var profileImage: File?
  @objc dynamic var name: String?
  @objc dynamic var familyImages: [File]?
  @objc dynamic var kind: String?
  @objc dynamic var introduce: String?
}
