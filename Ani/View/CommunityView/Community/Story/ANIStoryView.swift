//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIStoryView: UIView {
  
  var storyTableView: UITableView?
  
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
    let tableView = UITableView()
    tableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: UIViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT, right: 0)
    let id = NSStringFromClass(ANIStoryViewCell.self)
    tableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: id)
    tableView.separatorStyle = .none
    tableView.dataSource = self
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.storyTableView = tableView
  }
  
  private func setupTestData() {
    let cat1 = UIImage(named: "storyCat1")!
    let cat2 = UIImage(named: "storyCat2")!
    let cat3 = UIImage(named: "storyCat3")!
    let cat4 = UIImage(named: "storyCat1")!
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let story1 = Story(storyImages: [cat1, cat2, cat3], subTitle: "あれこれ内容を書くところだよおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user1, loveCount: 10, commentCount: 10)
    let story2 = Story(storyImages: [cat2, cat1, cat3, cat4], subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user2, loveCount: 5, commentCount: 8)
    let story3 = Story(storyImages: [cat3, cat2, cat1], subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user3, loveCount: 15, commentCount: 20)
    self.testStoryLists = [story1, story2, story3, story1, story2, story3]
  }
}

extension ANIStoryView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return testStoryLists.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIStoryViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIStoryViewCell
    cell.storyImagesView.images = testStoryLists[indexPath.item].storyImages
    cell.storyImagesView.pageControl?.numberOfPages = testStoryLists[indexPath.item].storyImages.count
    cell.subTitleLabel.text = testStoryLists[indexPath.item].subTitle
    cell.profileImageView.image = testStoryLists[indexPath.item].user.profileImage
    cell.userNameLabel.text = testStoryLists[indexPath.item].user.name
    cell.loveCountLabel.text = "\(testStoryLists[indexPath.item].loveCount)"
    cell.commentCountLabel.text = "\(testStoryLists[indexPath.item].commentCount)"
    return cell
  }
}

