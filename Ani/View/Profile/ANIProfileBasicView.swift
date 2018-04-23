//
//  ANIProfileBasicView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIProfileBasicView: UIView {
  
  enum SectionType:Int { case top = 0; case content = 1 }
  enum ContentType:Int { case profile; case recruit; case love; case clip;}
  
  private var contentType:ContentType = .profile {
    didSet {
      self.basicTableView?.reloadData()
      self.layoutIfNeeded()
    }
  }
  
  private weak var basicTableView: UITableView?
  
  private var testRecruitLists = [Recurit]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupRecruitTestData()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let basicTableView = UITableView()
    basicTableView.separatorStyle = .none
    basicTableView.dataSource = self
    let topCellId = NSStringFromClass(ANIProfileTopCell.self)
    basicTableView.register(ANIProfileTopCell.self, forCellReuseIdentifier: topCellId)
    let profileCellid = NSStringFromClass(ANIProfileProfileCell.self)
    basicTableView.register(ANIProfileProfileCell.self, forCellReuseIdentifier: profileCellid)
    let recruitCellid = NSStringFromClass(ANIProfileRecruitCell.self)
    basicTableView.register(ANIProfileRecruitCell.self, forCellReuseIdentifier: recruitCellid)
    let loveCellid = NSStringFromClass(ANIProfileLoveCell.self)
    basicTableView.register(ANIProfileLoveCell.self, forCellReuseIdentifier: loveCellid)
    let clipCellid = NSStringFromClass(ANIProfileClipCell.self)
    basicTableView.register(ANIProfileClipCell.self, forCellReuseIdentifier: clipCellid)
    addSubview(basicTableView)
    basicTableView.edgesToSuperview()
    self.basicTableView = basicTableView
  }
  
  private func setupRecruitTestData() {
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let recruit1 = Recurit(recruitImage: UIImage(named: "cat1")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお", user: user1, supportCount: 10, loveCount: 10)
    let recruit2 = Recurit(recruitImage: UIImage(named: "cat2")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user2, supportCount: 5, loveCount: 15)
    let recruit3 = Recurit(recruitImage: UIImage(named: "cat1")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user3, supportCount: 10, loveCount: 10)
    self.testRecruitLists = [recruit1, recruit2, recruit3, recruit1, recruit2, recruit3]
  }
}

extension ANIProfileBasicView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else {
      if contentType == .profile {
        return 1
      } else if contentType == .recruit {
        return testRecruitLists.count
      } else if contentType == .love {
        return 1
      } else {
        return testRecruitLists.count
      }
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section

    if section == 0 {
      let topCellId = NSStringFromClass(ANIProfileTopCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: topCellId, for: indexPath) as! ANIProfileTopCell
      cell.delegate = self
      cell.selectedIndex = contentType.rawValue
      return cell
    } else {
      if contentType == .profile {
        let profileCellid = NSStringFromClass(ANIProfileProfileCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCellid, for: indexPath) as! ANIProfileProfileCell
        return cell
      } else if contentType == .recruit {
        let recruitCellid = NSStringFromClass(ANIProfileRecruitCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: recruitCellid, for: indexPath) as! ANIProfileRecruitCell
        cell.recruitImageView.image = testRecruitLists[indexPath.item].recruitImage
        cell.titleLabel.text = testRecruitLists[indexPath.item].title
        cell.subTitleLabel.text = testRecruitLists[indexPath.item].subTitle
        cell.profileImageView.image = testRecruitLists[indexPath.item].user.profileImage
        cell.userNameLabel.text = testRecruitLists[indexPath.item].user.name
        cell.supportCountLabel.text = "\(testRecruitLists[indexPath.item].supportCount)"
        cell.loveCountLabel.text = "\(testRecruitLists[indexPath.item].loveCount)"
        return cell
      } else if contentType == .love {
        let loveCellid = NSStringFromClass(ANIProfileLoveCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: loveCellid, for: indexPath) as! ANIProfileLoveCell
        return cell
      } else {
        let clipCellid = NSStringFromClass(ANIProfileClipCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: clipCellid, for: indexPath) as! ANIProfileClipCell
        cell.recruitImageView.image = testRecruitLists[indexPath.item].recruitImage
        cell.titleLabel.text = testRecruitLists[indexPath.item].title
        cell.subTitleLabel.text = testRecruitLists[indexPath.item].subTitle
        cell.profileImageView.image = testRecruitLists[indexPath.item].user.profileImage
        cell.userNameLabel.text = testRecruitLists[indexPath.item].user.name
        cell.supportCountLabel.text = "\(testRecruitLists[indexPath.item].supportCount)"
        cell.loveCountLabel.text = "\(testRecruitLists[indexPath.item].loveCount)"
        return cell
      }
    }
  }
}

extension ANIProfileBasicView: ANIProfileMenuBarDelegate {
  func didSelecteMenuItem(selectedIndex: Int) {
    guard let basicTableView = self.basicTableView else { return }
    
    switch selectedIndex {
    case ContentType.profile.rawValue:
      contentType = .profile
    case ContentType.love.rawValue:
      contentType = .love
    case ContentType.recruit.rawValue:
      contentType = .recruit
    case ContentType.clip.rawValue:
      contentType = .clip
    default:
      print("default")
    }

    basicTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
  }
}
