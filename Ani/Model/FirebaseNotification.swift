//
//  FirebaseNoti.swift
//  Ani
//
//  Created by jeonminseop on 2018/07/09.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

struct FirebaseNotification: Codable {
  let userId: String
  let noti: String
  let kind: String
  let notiId: String
  let updateDate: String
}
