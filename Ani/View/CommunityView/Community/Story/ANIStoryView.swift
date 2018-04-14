//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIStoryView: UIView {
  
  var storyCollectionView: UICollectionView?
  
  private var testStoryLists = [Story]()
  
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
    let id = NSStringFromClass(ANIStoryViewCell.self)
    collectionView.register(ANIStoryViewCell.self, forCellWithReuseIdentifier: id)
    collectionView.backgroundColor = .white
    collectionView.alwaysBounceVertical = true
    collectionView.dataSource = self
    collectionView.delegate = self
    addSubview(collectionView)
    collectionView.edgesToSuperview()
    self.storyCollectionView = collectionView
  }
  
  private func setupTestData() {
    let cat1 = UIImage(named: "storyCat1")!
    let cat2 = UIImage(named: "storyCat2")!
    let cat3 = UIImage(named: "storyCat3")!
    let cat4 = UIImage(named: "storyCat1")!
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let story1 = Story(storyImages: [cat1, cat2, cat3], title: "우리 고양이가 침대에 똥을 쌌어!!", subTitle: "이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어놓을꺼야 으흐므흐므흠", user: user1, loveCount: 10, commentCount: 10)
    let story2 = Story(storyImages: [cat2, cat1, cat3, cat4], title: "우리 고양이가 침대에 똥을 쌌어!!", subTitle: "이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어놓을꺼야 으흐므흐므흠", user: user2, loveCount: 5, commentCount: 8)
    let story3 = Story(storyImages: [cat3, cat2, cat1], title: "우리 고양이가 침대에 똥을 쌌어!!", subTitle: "이것저것 내용을 적을꺼야 으흐므흐믛 내용이 생각안나니까 대충적어놓을꺼야 으흐므흐므흠", user: user3, loveCount: 15, commentCount: 20)
    self.testStoryLists = [story1, story2, story3]
  }
}

extension ANIStoryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testStoryLists.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIStoryViewCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIStoryViewCell
    cell.storyImagesView.images = testStoryLists[indexPath.item].storyImages
    cell.storyImagesView.pageControl?.numberOfPages = testStoryLists[indexPath.item].storyImages.count
    cell.titleLabel.text = testStoryLists[indexPath.item].title
    cell.subTitleTextView.text = testStoryLists[indexPath.item].subTitle
    cell.profileImageView.image = testStoryLists[indexPath.item].user.profileImage
    cell.userNameLabel.text = testStoryLists[indexPath.item].user.name
    cell.loveCountLabel.text = "\(testStoryLists[indexPath.item].loveCount)"
    cell.commentCountLabel.text = "\(testStoryLists[indexPath.item].commentCount)"
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 400.0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
}

