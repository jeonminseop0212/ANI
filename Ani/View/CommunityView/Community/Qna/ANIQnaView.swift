//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIQnaView: UIView {
  
  var qnaTableView: UITableView?
  
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
    let tableView = UITableView()
    tableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + ANICommunityViewController.STATUS_BAR_HEIGHT, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + ANICommunityViewController.STATUS_BAR_HEIGHT, right: 0)
    tableView.backgroundColor = ANIColor.bg
    let id = NSStringFromClass(ANIQnaViewCell.self)
    tableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.separatorStyle = .none
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.qnaTableView = tableView
  }
  
  private func setupTestData() {
    let cat1 = UIImage(named: "storyCat1")!
    let cat2 = UIImage(named: "storyCat2")!
    let cat3 = UIImage(named: "storyCat3")!
    let cat4 = UIImage(named: "storyCat1")!
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let qna1 = Qna(qnaImages: [cat1, cat2, cat3], subTitle: "あれこれ内容を書くところだよおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user1, loveCount: 10, commentCount: 5)
    let qna2 = Qna(qnaImages: [cat2, cat1, cat3, cat4], subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user2, loveCount: 5, commentCount: 5)
    let qna3 = Qna(qnaImages: [cat3, cat2, cat1], subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user3, loveCount: 15, commentCount: 10)
    
    self.testQnaLists = [qna1, qna2, qna3, qna1, qna2, qna3]
  }
}

extension ANIQnaView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return testQnaLists.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIQnaViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIQnaViewCell
    cell.subTitleLabel.text = testQnaLists[indexPath.item].subTitle
    cell.qnaImageView.image = testQnaLists[indexPath.item].qnaImages[0]
    cell.profileImageView.image = testQnaLists[indexPath.item].user.profileImage
    cell.userNameLabel.text = testQnaLists[indexPath.item].user.name
    cell.loveCountLabel.text = "\(testQnaLists[indexPath.item].loveCount)"
    cell.commentCountLabel.text = "\(testQnaLists[indexPath.item].commentCount)"
    return cell
  }
}


