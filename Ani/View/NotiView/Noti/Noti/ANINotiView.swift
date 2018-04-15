
//
//  ANINotiNotiView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/15.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANINotiView: UIView {
  
  private weak var notiCollectionView: UICollectionView?
  private var testNotiData = [Noti]()
  
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
    let notiCollectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
    let id = NSStringFromClass(ANINotiViewCell.self)
    notiCollectionView.register(ANINotiViewCell.self, forCellWithReuseIdentifier: id)
    notiCollectionView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + ANICommunityViewController.STATUS_BAR_HEIGHT, right: 0)
    notiCollectionView.scrollIndicatorInsets  = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + ANICommunityViewController.STATUS_BAR_HEIGHT, right: 0)
    notiCollectionView.backgroundColor = ANIColor.bg
    notiCollectionView.alwaysBounceVertical = true
    notiCollectionView.dataSource = self
    notiCollectionView.delegate = self
    addSubview(notiCollectionView)
    notiCollectionView.edgesToSuperview()
    self.notiCollectionView = notiCollectionView
  }
  
  private func setupTestData() {
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let noti1 = Noti(subtitle: "あなたの投稿に『いいね』しました", user: user1)
    let noti2 = Noti(subtitle: "あなたの投稿に『いいね』しました", user: user2)
    let noti3 = Noti(subtitle: "あなたの投稿に『いいね』しました", user: user3)
    let noti4 = Noti(subtitle: "あなたの投稿に『いいね』しました", user: user1)
    let noti5 = Noti(subtitle: "あなたの投稿に『いいね』しました", user: user2)
    let noti6 = Noti(subtitle: "あなたの投稿に『いいね』しました", user: user3)
    
    self.testNotiData = [noti1, noti2, noti3, noti4, noti5, noti6]
  }
}

extension ANINotiView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testNotiData.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANINotiViewCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANINotiViewCell
    cell.profileImageView?.image = testNotiData[indexPath.item].user.profileImage
    cell.subTitleLabel?.text = "\(testNotiData[indexPath.item].user.name)さんが\(testNotiData[indexPath.item].subtitle)。"
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: collectionView.frame.width, height: 70)
    return size
  }
}
