//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIQnaView: UIView {
  
  var qnaCollectionView: UICollectionView?
  
  private var testQnaLists = [Qna]()
  
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
    flowLayout.scrollDirection = .vertical
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    flowLayout.minimumLineSpacing = 10.0
    let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
    collectionView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + ANICommunityViewController.STATUS_BAR_HEIGHT, right: 0)
    collectionView.scrollIndicatorInsets  = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + ANICommunityViewController.STATUS_BAR_HEIGHT, right: 0)
    collectionView.backgroundColor = ANIColor.bg
    let id = NSStringFromClass(ANIQnaViewCell.self)
    collectionView.register(ANIQnaViewCell.self, forCellWithReuseIdentifier: id)
    collectionView.alwaysBounceVertical = true
    collectionView.dataSource = self
    collectionView.delegate = self
    addSubview(collectionView)
    collectionView.edgesToSuperview()
    self.qnaCollectionView = collectionView
  }
  
  private func setupTestData() {
    let cat1 = UIImage(named: "storyCat1")!
    let cat2 = UIImage(named: "storyCat2")!
    let cat3 = UIImage(named: "storyCat3")!
    let cat4 = UIImage(named: "storyCat1")!
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let qna1 = Qna(qnaImages: [cat1, cat2, cat3], subTitle: "이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야", user: user1, loveCount: 10, commentCount: 5)
    let qna2 = Qna(qnaImages: [cat2, cat1, cat3, cat4], subTitle: "이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야", user: user2, loveCount: 5, commentCount: 5)
    let qna3 = Qna(qnaImages: [cat3, cat2, cat1], subTitle: "이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야", user: user3, loveCount: 15, commentCount: 10)
    
    self.testQnaLists = [qna1, qna2, qna3]
  }
}

extension ANIQnaView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testQnaLists.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIQnaViewCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIQnaViewCell
    cell.subTitleTextView.text = testQnaLists[indexPath.item].subTitle
    cell.qnaImageView.image = testQnaLists[indexPath.item].qnaImages[0]
    cell.profileImageView.image = testQnaLists[indexPath.item].user.profileImage
    cell.userNameLabel.text = testQnaLists[indexPath.item].user.name
    cell.loveCountLabel.text = "\(testQnaLists[indexPath.item].loveCount)"
    cell.commentCountLabel.text = "\(testQnaLists[indexPath.item].commentCount)"
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 310.0)
  }
}


