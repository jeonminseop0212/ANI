//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIRecruitViewDelegate {
  func recruitRowTap()
  func recruitViewDidScroll(scrollY: CGFloat)
}

class ANIRecuruitView: UIView {

  weak var recruitTableView: UITableView?
  
  private var testRecruitLists = [Recurit]()

  var delegate:ANIRecruitViewDelegate?
  
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
    tableView.separatorStyle = .none
    let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT
    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.backgroundColor = .white
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    tableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.delegate = self
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.recruitTableView = tableView
  }
  
  private func setupTestData() {
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let recruit1 = Recurit(recruitImage: UIImage(named: "cat1")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお", user: user1, supportCount: 10, loveCount: 10)
    let recruit2 = Recurit(recruitImage: UIImage(named: "cat2")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user2, supportCount: 5, loveCount: 15)
    let recruit3 = Recurit(recruitImage: UIImage(named: "cat1")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user3, supportCount: 10, loveCount: 10)
    self.testRecruitLists = [recruit1, recruit2, recruit3, recruit1, recruit2, recruit3]
  }
}

extension ANIRecuruitView: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return testRecruitLists.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIRecruitViewCell
    cell.recruitImageView.image = testRecruitLists[indexPath.item].recruitImage
    cell.titleLabel.text = testRecruitLists[indexPath.item].title
    cell.subTitleLabel.text = testRecruitLists[indexPath.item].subTitle
    cell.profileImageView.image = testRecruitLists[indexPath.item].user.profileImage
    cell.userNameLabel.text = testRecruitLists[indexPath.item].user.name
    cell.supportCountLabel.text = "\(testRecruitLists[indexPath.item].supportCount)"
    cell.loveCountLabel.text = "\(testRecruitLists[indexPath.item].loveCount)"
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.delegate?.recruitRowTap()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ANINotificationManager.postViewScrolled()
    
    //navigation bar animation
    let scrollY = scrollView.contentOffset.y
    self.delegate?.recruitViewDidScroll(scrollY: scrollY)
  }
}
