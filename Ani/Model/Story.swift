//
//  Story.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

struct Story {
  let storyImages: [UIImage?]
  let story: String
  let user: User
  let loveCount: Int
  let commentCount: Int
  let comments: [Comment]?
}
