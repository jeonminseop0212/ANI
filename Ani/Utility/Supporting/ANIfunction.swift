//
//  ANIfunction.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/25.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIFunction: NSObject {
  static let shared = ANIFunction()

  func getToday(format:String = "yyyy/MM/dd HH:mm:ss") -> String {
    
    let now = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: now as Date)
  }
}
