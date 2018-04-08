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
  
  private var testRecruitLists = [Recurit]()
  
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
    let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
    collectionView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + ANICommunityViewController.STATUS_BAR_HEIGHT, right: 0)
    collectionView.scrollIndicatorInsets  = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + ANICommunityViewController.STATUS_BAR_HEIGHT, right: 0)
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    collectionView.backgroundColor = .white
    collectionView.register(ANIRecruitViewCell.self, forCellWithReuseIdentifier: id)
    collectionView.alwaysBounceVertical = true
    collectionView.dataSource = self
    collectionView.delegate = self
    addSubview(collectionView)
    collectionView.edgesToSuperview()
    self.qnaCollectionView = collectionView
  }
  
  private func setupTestData() {
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let recruit1 = Recurit(recruitImage: UIImage(named: "cat1")!, title: "귀여운 고양이 분양받아가세요 >_<", subTitle: "이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야", user: user1, supportCount: 10, loveCount: 10)
    let recruit2 = Recurit(recruitImage: UIImage(named: "cat2")!, title: "귀여운 고양이 분양받아가세요 >_<", subTitle: "이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야", user: user2, supportCount: 5, loveCount: 15)
    let recruit3 = Recurit(recruitImage: UIImage(named: "cat1")!, title: "귀여운 고양이 분양받아가세요 >_<", subTitle: "이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어 놓을꺼야", user: user3, supportCount: 10, loveCount: 10)
    self.testRecruitLists = [recruit1, recruit2, recruit3]
  }
}

extension ANIQnaView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testRecruitLists.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIRecruitViewCell
    cell.recruitImageView.image = testRecruitLists[indexPath.item].recruitImage
    cell.titleLabel.text = testRecruitLists[indexPath.item].title
    cell.subTitleTextView.text = testRecruitLists[indexPath.item].subTitle
    cell.profileImageView.image = testRecruitLists[indexPath.item].user.profileImage
    cell.userNameLabel.text = testRecruitLists[indexPath.item].user.name
    cell.supportCountLabel.text = "\(testRecruitLists[indexPath.item].supportCount)"
    cell.loveCountLabel.text = "\(testRecruitLists[indexPath.item].loveCount)"
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 320.0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
}


