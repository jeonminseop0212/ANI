//
//  FirebaseComment.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

struct FirebaseComment: Codable {
  let userId: String
  let comment: String
  let loveCount: Int
  let commentCount: Int
}
