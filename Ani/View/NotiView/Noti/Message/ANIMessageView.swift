//
//  ANIMessageView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/15.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIMessageView: UIView {
  
  private weak var messageTableView: UITableView?
  
  private var testMessageData = [Message]()
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupTestData()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = ANIColor.bg
    let window = UIApplication.shared.keyWindow
    var bottomSafeArea: CGFloat = 0.0
    if let windowUnrap = window {
      bottomSafeArea = windowUnrap.safeAreaInsets.bottom
    }
    
    //messageTableView
    let messageTableView = UITableView()
    messageTableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    messageTableView.scrollIndicatorInsets  = UIEdgeInsets(top: UIViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    let id = NSStringFromClass(ANIMessageViewCell.self)
    messageTableView.register(ANIMessageViewCell.self, forCellReuseIdentifier: id)
    messageTableView.backgroundColor = ANIColor.bg
    messageTableView.separatorStyle = .none
    messageTableView.alwaysBounceVertical = true
    messageTableView.dataSource = self
    messageTableView.delegate = self
    addSubview(messageTableView)
    messageTableView.edgesToSuperview()
    self.messageTableView = messageTableView
  }
  
  private func setupTestData() {
    let familyImages = [UIImage(named: "family1")!, UIImage(named: "family2")!, UIImage(named: "family3")!]
    let user1 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user2 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user3 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "団体", introduce: "団体で猫たちのためにボランティア活動をしています")
    let message1 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user1)
    let message2 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user2)
    let message3 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user3)
    let message4 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user1)
    let message5 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user2)
    let message6 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user3)
    let message7 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user1)
    let message8 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user2)
    let message9 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user3)
    let message10 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user1)
    let message11 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user2)
    let message12 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user3)
    
    self.testMessageData = [message1, message2, message3, message4, message5, message6, message7, message8, message9, message10, message11, message12]
  }
}

//MARK: UITableViewDataSource
extension ANIMessageView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return testMessageData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIMessageViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIMessageViewCell
    
    cell.profileImageView?.image = testMessageData[indexPath.item].user.profileImage
    cell.userNameLabel?.text = testMessageData[indexPath.item].user.name
    cell.subTitleLabel?.text = testMessageData[indexPath.item].subtitle
    
    return cell
  }
}

//MARK: UITableViewDelegate
extension ANIMessageView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}
