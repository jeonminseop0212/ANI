//
//  ANIProfileViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints
import FirebaseAuth
import FirebaseDatabase

class ANIProfileViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBase: UIView?
  private weak var navigationTitleLabel: UILabel?
  
  private weak var profileBasicView: ANIProfileBasicView?
  
  private var qnas = [Qna]()
  private var currentUser: FirebaseUser? { return ANISessionManager.shared.currentUser }
  private var user: User?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTestUser()
    setupTestQnaData()
    setup()
    setupNotification()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
  }
  
  private func setup() {
    //basic
    self.view.backgroundColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false
    ANIOrientation.lockOrientation(.portrait)
    
    //myNavigationBar
    let myNavigationBar = UIView()
    myNavigationBar.backgroundColor = .white
    self.view.addSubview(myNavigationBar)
    myNavigationBar.topToSuperview()
    myNavigationBar.leftToSuperview()
    myNavigationBar.rightToSuperview()
    myNavigationBar.height(UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBar = myNavigationBar
    
    //myNavigationBase
    let myNavigationBase = UIView()
    myNavigationBar.addSubview(myNavigationBase)
    myNavigationBase.edgesToSuperview(excluding: .top)
    myNavigationBase.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBase = myNavigationBase
    
    //navigationTitleLabel
    let navigationTitleLabel = UILabel()
    navigationTitleLabel.text = "プロフィール"
    navigationTitleLabel.textColor = ANIColor.dark
    navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    myNavigationBase.addSubview(navigationTitleLabel)
    navigationTitleLabel.centerInSuperview()
    self.navigationTitleLabel = navigationTitleLabel
    
    //profileBasicView
    let profileBasicView = ANIProfileBasicView()
    profileBasicView.qnas = qnas
    profileBasicView.user = user
    profileBasicView.currentUser = currentUser
    profileBasicView.delegate = self
    self.view.addSubview(profileBasicView)
    profileBasicView.topToBottom(of: myNavigationBar)
    profileBasicView.edgesToSuperview(excluding: .top)
    self.profileBasicView = profileBasicView
  }
  
  private func setupTestUser() {
    let familyImages = [UIImage(named: "family1")!, UIImage(named: "family2")!, UIImage(named: "family3")!]
    let user = User(id: "jeonminseop", password: "aaaaa", profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    
    self.user = user
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
//    imageBrowserViewController.images = images
    imageBrowserViewController.modalPresentationStyle = .overCurrentContext
    //overCurrentContextだとtabBarが消えないのでtabBarからpresentする
    self.tabBarController?.present(imageBrowserViewController, animated: false, completion: nil)
  }
  
  @objc private func openProfileEdit() {
    let profileEditViewController = ANIProfileEditViewController()
    profileEditViewController.delegate = self
    profileEditViewController.currentUser = currentUser
    self.present(profileEditViewController, animated: true, completion: nil)
  }
}

//MARK: ANIProfileBasicViewDelegate
extension ANIProfileViewController: ANIProfileBasicViewDelegate {
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit) {
    let recruitDetailViewController = ANIRecruitDetailViewController()
    recruitDetailViewController.hidesBottomBarWhenPushed = true
    recruitDetailViewController.recruit = selectedRecruit
    self.navigationController?.pushViewController(recruitDetailViewController, animated: true)
  }
  
  func storyViewCellDidSelect(selectedStory: FirebaseStory) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.story
    commentViewController.story = selectedStory
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
  
  func qnaViewCellDidSelect(index: Int) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.qna
    commentViewController.qna = qnas[index]
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
}

extension ANIProfileViewController: ANIProfileEditViewControllerDelegate {
  func didEdit() {
    guard let profileBasicView = self.profileBasicView else { return }
    profileBasicView.currentUser = currentUser
  }
}
