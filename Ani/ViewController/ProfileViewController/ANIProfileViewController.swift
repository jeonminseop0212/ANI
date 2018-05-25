//
//  ANIProfileViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIProfileViewController: UIViewController {
  
  private weak var profileBasicView: ANIProfileBasicView?
  
  private var recruits = [Recruit]()
  
  private var storys = [Story]()
  
  private var qnas = [Qna]()
  
  private var me: User?
  
  var user: User?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTestUser()
    setupTestRecruitData()
    setupTestStoryData()
    setupTestQnaData()
    setupMe()
    setup()
    setupNotification()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
  }
  
  private func setup() {
    //basic
    Orientation.lockOrientation(.portrait)
    self.view.backgroundColor = .white
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationItem.title = "PROFILE"
    self.navigationController?.navigationBar.tintColor = ANIColor.dark
    
    //profileBasicView
    let profileBasicView = ANIProfileBasicView()
    profileBasicView.recruits = recruits
    profileBasicView.storys = storys
    profileBasicView.qnas = qnas
    profileBasicView.user = user
    profileBasicView.delegate = self
    self.view.addSubview(profileBasicView)
    profileBasicView.edgesToSuperview()
    self.profileBasicView = profileBasicView
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
  
  private func setupMe() {
    let familyImages = [UIImage(named: "family1")!, UIImage(named: "family2")!, UIImage(named: "family3")!]
    let me = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "meProfileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    
    self.me = me
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(imageCellTapped: self, selector: #selector(presentImageBrowser(_:)))
    ANINotificationManager.receive(profileEditButtonTapped: self, selector: #selector(openProfileEdit))
  }
  
  //MARK: action
  @objc private func presentImageBrowser(_ notification: NSNotification) {
    guard let item = notification.object as? (Int, [UIImage?]) else { return }
    let selectedIndex = item.0
    let images = item.1
    let imageBrowserViewController = ANIImageBrowserViewController()
    imageBrowserViewController.selectedIndex = selectedIndex
    imageBrowserViewController.images = images
    imageBrowserViewController.modalPresentationStyle = .overCurrentContext
    //overCurrentContextだとtabBarが消えないのでtabBarからpresentする
    self.tabBarController?.present(imageBrowserViewController, animated: false, completion: nil)
  }
  
  @objc private func openProfileEdit() {
    guard let profileBasicView = self.profileBasicView else { return }
    
    let profileEditViewController = ANIProfileEditViewController()
    profileEditViewController.user = profileBasicView.user
    self.present(profileEditViewController, animated: true, completion: nil)
  }
}

//MARK: ANIProfileBasicViewDelegate
extension ANIProfileViewController: ANIProfileBasicViewDelegate {
  func recruitViewCellDidSelect(index: Int) {
    let recruitDetailViewController = ANIRecruitDetailViewController()
    recruitDetailViewController.hidesBottomBarWhenPushed = true
    recruitDetailViewController.testRecruit = recruits[index]
    self.navigationController?.pushViewController(recruitDetailViewController, animated: true)
  }
  
  func storyViewCellDidSelect(index: Int) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.story
    commentViewController.story = storys[index]
    commentViewController.me = me
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
  
  func qnaViewCellDidSelect(index: Int) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.qna
    commentViewController.qna = qnas[index]
    commentViewController.me = me
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
}
