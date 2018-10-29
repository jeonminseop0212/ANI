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

  func getToday(format:String = "yyyy/MM/dd HH:mm:ss.SSS") -> String {
    let now = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: now as Date)
  }
  
  func dateFromString(string: String, format: String = "yyyy/MM/dd HH:mm:ss.SSS") -> Date {
    let formatter: DateFormatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = format
    if let date = formatter.date(from: string) {
      return date
    } else {
      return Date()
    }
  }
}
