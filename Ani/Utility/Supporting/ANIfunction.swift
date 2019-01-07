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
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = format
    return formatter.string(from: now as Date)
  }
  
  func dateFromString(string: String, format: String = "yyyy/MM/dd HH:mm:ss.SSS") -> Date {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = format
    if let date = formatter.date(from: string) {
      return date
    } else {
      return Date()
    }
  }
  
  func getCurrentLocaleDateFromString(string: String, format: String = "yyyy/MM/dd HH:mm:ss.SSS") -> String {
    let date = dateFromString(string: string)
    let currentformatter = DateFormatter()
    currentformatter.timeZone = TimeZone.current
    currentformatter.locale = Locale.current
    currentformatter.dateFormat = format
    return currentformatter.string(from: date)
  }
  
  func webURLScheme(urlString: String) -> String {
    guard urlString.count > 0 else { return "" }
    
    let castUrlString = urlString.lowercased()
    if castUrlString.hasPrefix("http://") || castUrlString.hasPrefix("https://") {
      return castUrlString
    } else {
      return "https://" + castUrlString
    }
  }
}
