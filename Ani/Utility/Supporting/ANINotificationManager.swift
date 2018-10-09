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
    let name = UIResponder.keyboardDidChangeFrameNotification
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  static func receive(keyboardDidHide observer:Any, selector:Selector) {
    let name = UIResponder.keyboardDidHideNotification
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  static func receive(keyboardWillChangeFrame observer:Any, selector:Selector) {
    let name = UIResponder.keyboardWillChangeFrameNotification
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  static func receive(keyboardWillHide observer:Any, selector:Selector) {
    let name = UIResponder.keyboardWillHideNotification
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  static func receive(keyboardWillShow observer:Any, selector:Selector) {
    let name = UIResponder.keyboardWillShowNotification
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  
  //MARK: tab tapped
  private static let N_RECRUIT_TAB_TAPPED = "N_RECRUIT_TAB_TAPPED"
  static func postRecruitTabTapped() { self.post(name: N_RECRUIT_TAB_TAPPED, object: nil, userInfo:nil) }
  static func receive(recruitTabTapped observer:Any, selector:Selector) { receive(name: N_RECRUIT_TAB_TAPPED, observer: observer, selector: selector) }
  private static let N_COMMUNITY_TAB_TAPPED = "N_COMMUNITY_TAB_TAPPED"
  static func postCommunityTabTapped() { self.post(name: N_COMMUNITY_TAB_TAPPED, object: nil, userInfo:nil) }
  static func receive(communityTabTapped observer:Any, selector:Selector) { receive(name: N_COMMUNITY_TAB_TAPPED, observer: observer, selector: selector) }
  private static let N_NOTI_TAB_TAPPED = "N_NOTI_TAB_TAPPED"
  static func postNotiTabTapped() { self.post(name: N_NOTI_TAB_TAPPED, object: nil, userInfo:nil) }
  static func receive(notiTabTapped observer:Any, selector:Selector) { receive(name: N_NOTI_TAB_TAPPED, observer: observer, selector: selector) }
  private static let N_SEARCH_TAB_TAPPED = "N_SEARCH_TAB_TAPPED"
  static func postSearchTabTapped() { self.post(name: N_SEARCH_TAB_TAPPED, object: nil, userInfo:nil) }
  static func receive(searchTabTapped observer:Any, selector:Selector) { receive(name: N_SEARCH_TAB_TAPPED, observer: observer, selector: selector) }
  private static let N_PROFILE_TAB_TAPPED = "N_PROFILE_TAB_TAPPED"
  static func postProfileTabTapped() { self.post(name: N_PROFILE_TAB_TAPPED, object: nil, userInfo:nil) }
  static func receive(profileTabTapped observer:Any, selector:Selector) { receive(name: N_PROFILE_TAB_TAPPED, observer: observer, selector: selector) }
  
  //MARK: view scroll
  private static let N_VIEW_SCROLLED = "N_VIEW_SCROLLED"
  static func postViewScrolled() { self.post(name: N_VIEW_SCROLLED, object: nil, userInfo:nil) }
  static func receive(viewScrolled observer:Any, selector:Selector) { receive(name: N_VIEW_SCROLLED, observer: observer, selector: selector) }
  
  //MARK: text view text did change
  static func receive(textViewTextDidChange observer:Any, selector:Selector) {
    let name = UITextView.textDidChangeNotification
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
  
  //MARK: profile image view tapped
  private static let N_PROFILE_IMAGE_VIEW_TAPPED = "N_PROFILE_IMAGE_VIEW_TAPPED"
  static func postProfileImageViewTapped(userId: String) { self.post(name: N_PROFILE_IMAGE_VIEW_TAPPED, object: userId, userInfo:nil) }
  static func receive(profileImageViewTapped observer:Any, selector:Selector) { receive(name: N_PROFILE_IMAGE_VIEW_TAPPED, observer: observer, selector: selector) }
  
  //MARK: logout
  private static let N_LOGOUT = "N_LOGOUT"
  static func postLogout() { self.post(name: N_LOGOUT, object: nil, userInfo:nil) }
  static func receive(logout observer:Any, selector:Selector) { receive(name: N_LOGOUT, observer: observer, selector: selector) }
  
  //MARK: login
  private static let N_LOGIN = "N_LOGIN"
  static func postLogin() { self.post(name: N_LOGIN, object: nil, userInfo:nil) }
  static func receive(login observer:Any, selector:Selector) { receive(name: N_LOGIN, observer: observer, selector: selector) }
  
  //MARK: will resignActive
  static func receive(applicationWillResignActive observer:Any, selector:Selector) {
    let name = UIApplication.willResignActiveNotification
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  
  //MARK: enter background
  static func receive(applicationWillEnterForeground observer:Any, selector:Selector) {
    let name = UIApplication.willEnterForegroundNotification
    self.receive(notificationName: name, observer: observer, selector: selector)
  }
  
  //MARK: message cell tapped
  private static let N_MESSAGE_CELL_TAPPED = "N_MESSAGE_CELL_TAPPED"
  static func postMessageCellTapped(user: FirebaseUser) { self.post(name: N_MESSAGE_CELL_TAPPED, object: user, userInfo:nil) }
  static func receive(messageCellTapped observer:Any, selector:Selector) { receive(name: N_MESSAGE_CELL_TAPPED, observer: observer, selector: selector) }
  
  //MARK: delete story
  private static let N_DELETE_STORY = "N_DELETE_STORY"
  static func postDeleteStory(id: String) { self.post(name: N_DELETE_STORY, object: id, userInfo:nil) }
  static func receive(deleteStory observer:Any, selector:Selector) { receive(name: N_DELETE_STORY, observer: observer, selector: selector) }
  
  //MARK: delete qna
  private static let N_DELETE_QNA = "N_DELETE_QNA"
  static func postDeleteQna(id: String) { self.post(name: N_DELETE_QNA, object: id, userInfo:nil) }
  static func receive(deleteQna observer:Any, selector:Selector) { receive(name: N_DELETE_QNA, observer: observer, selector: selector) }
  
  //MARK: delete recruit
  private static let N_DELETE_RECRUIT = "N_DELETE_RECRUIT"
  static func postDeleteRecruit(id: String) { self.post(name: N_DELETE_RECRUIT, object: id, userInfo:nil) }
  static func receive(deleteRecruit observer:Any, selector:Selector) { receive(name: N_DELETE_RECRUIT, observer: observer, selector: selector) }
  
  //MARK: change isHaveUnreadNoti
  private static let N_CHANGE_IS_HAVE_UNREAD_NOTI = "N_CHANGE_IS_HAVE_UNREAD_NOTI"
  static func postChangeIsHaveUnreadNoti() { self.post(name: N_CHANGE_IS_HAVE_UNREAD_NOTI, object: nil, userInfo:nil) }
  static func receive(changeIsHaveUnreadNoti observer:Any, selector:Selector) { receive(name: N_CHANGE_IS_HAVE_UNREAD_NOTI, observer: observer, selector: selector) }
}
