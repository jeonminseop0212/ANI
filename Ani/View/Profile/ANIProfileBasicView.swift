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
  enum ContentType:Int { case profile; case recruit; case story; case qna;}
  
  private var contentType:ContentType = .profile {
    didSet {
      self.basicTableView?.reloadData()
      self.layoutIfNeeded()
    }
  }
  
  private weak var basicTableView: UITableView?
  
  private var recruits = [Recruit]()
  
  private var storys = [Story]()
  
  private var qnas = [Qna]()
  
  var user: User?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupTestUser()
    setupTestRecruitData()
    setupTestStoryData()
    setupTestQnaData()
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
    let profileCellid = NSStringFromClass(ANIProfileCell.self)
    basicTableView.register(ANIProfileCell.self, forCellReuseIdentifier: profileCellid)
    let recruitCellid = NSStringFromClass(ANIRecruitViewCell.self)
    basicTableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: recruitCellid)
    let storyCellid = NSStringFromClass(ANIStoryViewCell.self)
    basicTableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellid)
    let qnaCellid = NSStringFromClass(ANIQnaViewCell.self)
    basicTableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: qnaCellid)
    addSubview(basicTableView)
    basicTableView.edgesToSuperview()
    self.basicTableView = basicTableView
  }
  
  private func setupTestUser() {
    let familyImages = [UIImage(named: "family1")!, UIImage(named: "family2")!, UIImage(named: "family3")!]
    let user = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    
    self.user = user
  }
  
  private func setupTestRecruitData() {
    let familyImages = [UIImage(named: "family1")!, UIImage(named: "family2")!, UIImage(named: "family3")!]
    let user1 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user2 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user3 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "団体", introduce: "団体で猫たちのためにボランティア活動をしています")
    
    let image1 = UIImage(named: "storyCat1")!
    let image2 = UIImage(named: "storyCat2")!
    let image3 = UIImage(named: "storyCat3")!
    let image4 = UIImage(named: "storyCat1")!
    
    let introduceImages = [image1, image2, image3, image4]
    let recruitInfo = RecruitInfo(headerImage: UIImage(named: "cat1")!, title: "かわいい猫ちゃんの里親になって >_<", kind: "ミックス", age: "１歳以下", sex: "男の子", home: "東京都", vaccine: "１回", castration: "済み", reason: "親がいない子猫を保護しました。\n家ではすでに猫を飼えないので親になってくれる方を探しています。\nよろしくお願いします。", introduce: "人懐こくて甘えん坊の可愛い子猫です。\n元気よくご飯もいっぱいたべます😍\n遊ぶのが大好きであっちこっち走り回る姿がたまらなく可愛いです。", introduceImages: introduceImages, passing: "ご自宅までお届けします！", isRecruit: true)
    let recruit1 = Recruit(recruitInfo: recruitInfo, user: user1, supportCount: 10, loveCount: 10)
    let recruit2 = Recruit(recruitInfo: recruitInfo, user: user2, supportCount: 5, loveCount: 8)
    let recruit3 = Recruit(recruitInfo: recruitInfo, user: user3, supportCount: 14, loveCount: 20)
    
    self.recruits = [recruit1, recruit2, recruit3, recruit1, recruit2, recruit3]
  }
  
  private func setupTestStoryData() {
    let cat1 = UIImage(named: "storyCat1")!
    let cat2 = UIImage(named: "storyCat2")!
    let cat3 = UIImage(named: "storyCat3")!
    let cat4 = UIImage(named: "storyCat1")!
    let familyImages = [UIImage(named: "family1")!, UIImage(named: "family2")!, UIImage(named: "family3")!]
    let user1 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user2 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user3 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "団体", introduce: "団体で猫たちのためにボランティア活動をしています")
    let comment1 = Comment(user: user1, comment: "可愛い写真ですね", loveCount: 0, commentCount: 0)
    let comment2 = Comment(user: user2, comment: "いいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよ", loveCount: 0, commentCount: 0)
    let comment3 = Comment(user: user3, comment: "コメントふふふふ", loveCount: 0, commentCount: 0)
    let story1 = Story(storyImages: [cat1, cat2, cat3], story: "あれこれ内容を書くところだよおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user1, loveCount: 10, commentCount: 10, comments: [comment1, comment2, comment3])
    let story2 = Story(storyImages: [cat2, cat1, cat3, cat4], story: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user2, loveCount: 5, commentCount: 8, comments: [comment1, comment2, comment3])
    let story3 = Story(storyImages: [cat3, cat2, cat1], story: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user3, loveCount: 15, commentCount: 20, comments: [comment1, comment2, comment3])
    self.storys = [story1, story2, story3, story1, story2, story3]
  }
  
  private func setupTestQnaData() {
    let cat1 = UIImage(named: "storyCat1")!
    let cat2 = UIImage(named: "storyCat2")!
    let cat3 = UIImage(named: "storyCat3")!
    let cat4 = UIImage(named: "storyCat1")!
    let familyImages = [UIImage(named: "family1")!, UIImage(named: "family2")!, UIImage(named: "family3")!]
    let user1 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user2 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user3 = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "団体", introduce: "団体で猫たちのためにボランティア活動をしています")
    let comment1 = Comment(user: user1, comment: "可愛い写真ですね", loveCount: 0, commentCount: 0)
    let comment2 = Comment(user: user2, comment: "いいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよ", loveCount: 0, commentCount: 0)
    let comment3 = Comment(user: user3, comment: "コメントふふふふ", loveCount: 0, commentCount: 0)
    let qna1 = Qna(qnaImages: [cat1, cat2, cat3], qna: "あれこれ内容を書くところだよおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user1, loveCount: 10, commentCount: 5, comments: [comment1, comment2, comment3])
    let qna2 = Qna(qnaImages: [cat2, cat1, cat3, cat4], qna: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user2, loveCount: 5, commentCount: 5, comments: [comment1, comment2, comment3])
    let qna3 = Qna(qnaImages: [cat3, cat2, cat1], qna: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user3, loveCount: 15, commentCount: 10, comments: [comment1, comment2, comment3])
    
    self.qnas = [qna1, qna2, qna3, qna1, qna2, qna3]
  }
}

//MARK: UITableViewDataSource
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
        return recruits.count
      } else if contentType == .story {
        return storys.count
      } else {
        return qnas.count
      }
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section

    if section == 0 {
      guard let user = self.user else { return UITableViewCell() }

      let topCellId = NSStringFromClass(ANIProfileTopCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: topCellId, for: indexPath) as! ANIProfileTopCell
      cell.delegate = self
      cell.selectedIndex = contentType.rawValue
      cell.user = user
      return cell
    } else {
      if contentType == .profile {
        guard let user = self.user else { return UITableViewCell() }
        
        let profileCellid = NSStringFromClass(ANIProfileCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCellid, for: indexPath) as! ANIProfileCell
        cell.user = user
        return cell
      } else if contentType == .recruit {
        let recruitCellid = NSStringFromClass(ANIRecruitViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: recruitCellid, for: indexPath) as! ANIRecruitViewCell
        
        cell.recruit = recruits[indexPath.row]

        return cell
      } else if contentType == .story {
        let storyCellid = NSStringFromClass(ANIStoryViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: storyCellid, for: indexPath) as! ANIStoryViewCell
        
        cell.story = storys[indexPath.row]

        return cell
      } else {
        let qnaCellid = NSStringFromClass(ANIQnaViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: qnaCellid, for: indexPath) as! ANIQnaViewCell
        
        cell.qna = qnas[indexPath.row]

        return cell
      }
    }
  }
}

//MARK: ANIProfileMenuBarDelegate
extension ANIProfileBasicView: ANIProfileMenuBarDelegate {
  func didSelecteMenuItem(selectedIndex: Int) {
    guard let basicTableView = self.basicTableView else { return }
    
    switch selectedIndex {
    case ContentType.profile.rawValue:
      contentType = .profile
    case ContentType.story.rawValue:
      contentType = .story
    case ContentType.recruit.rawValue:
      contentType = .recruit
    case ContentType.qna.rawValue:
      contentType = .qna
    default:
      print("default")
    }

    basicTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
  }
}
