//
//  ANIMessageView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/15.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIMessageView: UIView {
  
  private weak var messageCollectionView: UICollectionView?
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
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = 10.0
    let messageCollectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
    let id = NSStringFromClass(ANIMessageViewCell.self)
    messageCollectionView.register(ANIMessageViewCell.self, forCellWithReuseIdentifier: id)
    messageCollectionView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + ANICommunityViewController.STATUS_BAR_HEIGHT, right: 0)
    messageCollectionView.scrollIndicatorInsets  = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + ANICommunityViewController.STATUS_BAR_HEIGHT, right: 0)
    messageCollectionView.backgroundColor = ANIColor.bg
    messageCollectionView.alwaysBounceVertical = true
    messageCollectionView.dataSource = self
    messageCollectionView.delegate = self
    addSubview(messageCollectionView)
    messageCollectionView.edgesToSuperview()
    self.messageCollectionView = messageCollectionView
  }
  
  private func setupTestData() {
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let message1 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user1)
    let message2 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user2)
    let message3 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user3)
    let message4 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user1)
    let message5 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user2)
    let message6 = Message(subtitle: "俺とお話でもしようかああああああああああ？？？？？", user: user3)
    
    self.testMessageData = [message1, message2, message3, message4, message5, message6]
  }
}

extension ANIMessageView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testMessageData.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIMessageViewCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIMessageViewCell
    cell.profileImageView?.image = testMessageData[indexPath.item].user.profileImage
    cell.userNameLabel?.text = testMessageData[indexPath.item].user.name
    cell.subTitleLabel?.text = testMessageData[indexPath.item].subtitle
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: collectionView.frame.width, height: 80)
    return size
  }
}
