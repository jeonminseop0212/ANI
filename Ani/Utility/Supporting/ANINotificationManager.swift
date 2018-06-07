//
//  ANINotificationManager.swift
//  Ani
//
//  Created by jeonminseop on 2018/04/23.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//
import UIKit

class ANINotificationManager: NSObject {
  
  //MARK: base remove
  static func remove(_ observer:Any) {
    NotificationCenter.default.removeObserver(observer)
  }
  
  //MARK: base post
  private static func post(notificationName:NSNotification.Name, object:Any?, userInfo:[AnyHashable: Any]?) {
    NotificationCenter.default.post(name: notificationName, object: object, userInfo: userInfo)
  }
  private static func post(name:String, object:Any?, userInfo:[AnyHashable: Any]? = nil) {
    self.post(notificationName: NSNotification.Name(name), object: object, userInfo: userInfo)
  }
  
  //MARK: base receive
  private static func receive(notificationName:NSNotification.Name, observer:Any, selector:Selector) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName, object: nil)
  }
  private static func receive(name:String, observer:Any, selector:Selector) {
    self.receive(notificationName:NSNotification.Name(name), observer:observer, selector:selector)
  }
  
  //MARK: Keyboard
  static func receive(keyboardDidChangeFrame observer:Any, selector:Selector) {
    let name = NSNotification.Name.UIKeyboardDidChangeFrame
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  static func receive(keyboardDidHide observer:Any, selector:Selector) {
    let name = NSNotification.Name.UIKeyboardDidHide
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  static func receive(keyboardWillChangeFrame observer:Any, selector:Selector) {
    let name = NSNotification.Name.UIKeyboardWillChangeFrame
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  static func receive(keyboardWillHide observer:Any, selector:Selector) {
    let name = NSNotification.Name.UIKeyboardWillHide
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  static func receive(keyboardWillShow observer:Any, selector:Selector) {
    let name = NSNotification.Name.UIKeyboardWillShow
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  
  //MARK: view scroll
  private static let N_VIEW_SCROLLED = "N_VIEW_SCROLLED"
  static func postViewScrolled() { self.post(name: N_VIEW_SCROLLED, object: nil, userInfo:nil) }
  static func receive(viewScrolled observer:Any, selector:Selector) { receive(name: N_VIEW_SCROLLED, observer: observer, selector: selector) }
  
  //MARK: text view text did change
  static func receive(textViewTextDidChange observer:Any, selector:Selector) {
    let name = NSNotification.Name.UITextViewTextDidChange
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  
  //MARK: update basic info
  private static let N_PICKER_VIEW_DID_SELECT = "N_PICKER_VIEW_DID_SELECT"
  static func postPickerViewDidSelect(pickItem: String) { self.post(name: N_PICKER_VIEW_DID_SELECT, object: pickItem, userInfo:nil) }
  static func receive(pickerViewDidSelect observer:Any, selector:Selector) { receive(name: N_PICKER_VIEW_DID_SELECT, observer: observer, selector: selector) }
  
  //MARK: image view tapped
  private static let N_IMAGE_CELL_TAPPED = "N_IMAGE_CELL_TAPPED"
  static func postImageCellTapped(tapCellItem: (Int, [String])) { self.post(name: N_IMAGE_CELL_TAPPED, object: tapCellItem, userInfo:nil) }
  static func receive(imageCellTapped observer:Any, selector:Selector) { receive(name: N_IMAGE_CELL_TAPPED, observer: observer, selector: selector) }
  
  //MARK: profile edit button tapped
  private static let N_PROFILE_EDIT_BUTTON_TAPPED = "N_PROFILE_EDIT_BUTTON_TAPPED"
  static func postProfileEditButtonTapped() { self.post(name: N_PROFILE_EDIT_BUTTON_TAPPED, object: nil, userInfo:nil) }
  static func receive(profileEditButtonTapped observer:Any, selector:Selector) { receive(name: N_PROFILE_EDIT_BUTTON_TAPPED, observer: observer, selector: selector) }
}
