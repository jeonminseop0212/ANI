//
//  FirebaseStory.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

struct FirebaseStory: Codable {
  var id: String?
  let storyImageUrls: [String]?
  let story: String
  let userId: String
  let loveIds: [String: Bool]?
  var commentIds: [String: Bool]?
  let recruitId: String?
  let recruitTitle: String?
  let recruitSubTitle: String?
  let date: String
}

