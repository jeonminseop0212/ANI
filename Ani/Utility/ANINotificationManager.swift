//
//  ANINotificationManager.swift
//  Ani
//
//  Created by jeonminseop on 2018/04/23.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//
import UIKit

class ANINotificationManager: NSObject {
  
  //MARK: - Base remove
  static func remove(_ observer:Any) {
    NotificationCenter.default.removeObserver(observer)
  }
  
  //MARK: - Base Post
  private static func post(notificationName:NSNotification.Name, object:Any?, userInfo:[AnyHashable: Any]?) {
    NotificationCenter.default.post(name: notificationName, object: object, userInfo: userInfo)
  }
  private static func post(name:String, object:Any?, userInfo:[AnyHashable: Any]? = nil) {
    self.post(notificationName: NSNotification.Name(name), object: object, userInfo: userInfo)
  }
  
  //MARK: - Base Receive
  private static func receive(notificationName:NSNotification.Name, observer:Any, selector:Selector) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName, object: nil)
  }
  private static func receive(name:String, observer:Any, selector:Selector) {
    self.receive(notificationName:NSNotification.Name(name), observer:observer, selector:selector)
  }
  
  //MARK: - view scroll
  private static let N_VIEW_SCROLLED = "N_VIEW_SCROLLED"
  static func postViewScrolled() { self.post(name: N_VIEW_SCROLLED, object: nil, userInfo:nil) }
  static func receive(viewScrolled observer:Any, selector:Selector) { receive(name: N_VIEW_SCROLLED, observer: observer, selector: selector) }
}
