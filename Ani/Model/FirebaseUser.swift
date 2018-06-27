//
//  FirebaseUser.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/31.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

struct FirebaseUser: Codable {
  var uid: String?
  var userName: String?
  var kind: String?
  var introduce: String?
  var profileImageUrl: String?
  var familyImageUrls: [String]?
  var postRecruitIds: [String: Bool]?
  var postStoryIds: [String: Bool]?
  var postQnaIds: [String: Bool]?
  var followingUserIds: [String: String]?
  var followerIds: [String: String]?
}
