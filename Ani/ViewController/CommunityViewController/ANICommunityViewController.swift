//
//  CommunityViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANICommunityViewController: UIViewController {
  
  private weak var menuBar: ANICommunityMenuBar?
  private weak var containerCollectionView: UICollectionView?
  
  private let CONTRIBUTION_BUTTON_HEIGHT: CGFloat = 55.0
  private weak var contributionButon: ANIImageButtonView?
  
  private var selectedIndex: Int = 0
  
  private var storys: [Story]? {
    didSet {
      guard let containerCollectionView = self.containerCollectionView else { return }
      containerCollectionView.reloadData()
    }
  }
  
  private var qnas: [Qna]? {
    didSet {
      guard let containerCollectionView = self.containerCollectionView else { return }
      containerCollectionView.reloadData()
    }
  }
  
  private var me: User?

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    setupMe()
    setupTestStoryData()
    setupTestQnaData()
    setupNotification()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
  }
  
  private func setup() {
    //basic
    Orientation.lockOrientation(.portrait)
    navigationController?.setNavigationBarHidden(true, animated: false)
    
    //container
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let containerCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: flowLayout)
    containerCollectionView.dataSource = self
    containerCollectionView.delegate = self
    containerCollectionView.showsHorizontalScrollIndicator = false
    containerCollectionView.backgroundColor = ANIColor.bg
    containerCollectionView.isPagingEnabled = true
    let storyId = NSStringFromClass(ANICommunityStoryCell.self)
    containerCollectionView.register(ANICommunityStoryCell.self, forCellWithReuseIdentifier: storyId)
    let qnaId = NSStringFromClass(ANICommunityQnaCell.self)
    containerCollectionView.register(ANICommunityQnaCell.self, forCellWithReuseIdentifier: qnaId)
    self.view.addSubview(containerCollectionView)
    containerCollectionView.edgesToSuperview()
    self.containerCollectionView = containerCollectionView
    
    //menuBar
    let menuBar = ANICommunityMenuBar()
    menuBar.delegate = self
    self.view.addSubview(menuBar)
    let menuBarHeight = UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT
    menuBar.topToSuperview()
    menuBar.leftToSuperview()
    menuBar.rightToSuperview()
    menuBar.height(menuBarHeight)
    self.menuBar = menuBar
    
    //contributionButon
    let contributionButon = ANIImageButtonView()
    contributionButon.image = UIImage(named: "contributionButton")
    contributionButon.superViewCornerRadius(radius: CONTRIBUTION_BUTTON_HEIGHT / 2)
    contributionButon.superViewDropShadow(opacity: 0.13)
    contributionButon.delegate = self
    self.view.addSubview(contributionButon)
    contributionButon.width(CONTRIBUTION_BUTTON_HEIGHT)
    contributionButon.height(CONTRIBUTION_BUTTON_HEIGHT)
    contributionButon.rightToSuperview(offset: 15.0)
    contributionButon.bottomToSuperview(offset: -15.0, usingSafeArea: true)
    self.contributionButon = contributionButon
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(imageCellTapped: self, selector: #selector(presentImageBrowser(_:)))
  }
  
  private func setupTestStoryData() {
    let cat1 = UIImage(named: "storyCat1")!
    let cat2 = UIImage(named: "storyCat2")!
    let cat3 = UIImage(named: "storyCat3")!
    let cat4 = UIImage(named: "storyCat1")!
    let familyImages = [UIImage(named: "family1")!, UIImage(named: "family2")!, UIImage(named: "family3")!]
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "団体", introduce: "団体で猫たちのためにボランティア活動をしています")
    let comment1 = Comment(user: user1, comment: "可愛い写真ですね", loveCount: 0, commentCount: 0)
    let comment2 = Comment(user: user2, comment: "いいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよ", loveCount: 0, commentCount: 0)
    let comment3 = Comment(user: user3, comment: "コメントふふふふ", loveCount: 0, commentCount: 0)
    let comment4 = Comment(user: user1, comment: "可愛い写真ですね", loveCount: 0, commentCount: 0)
    let comment5 = Comment(user: user2, comment: "いいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよいいですねえええええええええコメントだよ", loveCount: 0, commentCount: 0)
    let comment6 = Comment(user: user3, comment: "コメントふふふふ", loveCount: 0, commentCount: 0)
    let story1 = Story(storyImages: [cat1, cat2, cat3], story: "あれこれ内容を書くところだよおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user1, loveCount: 10, commentCount: 10, comments: [comment1, comment2, comment3, comment4, comment5, comment6])
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
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "団体", introduce: "団体で猫たちのためにボランティア活動をしています")
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
    let me = User(profileImage: UIImage(named: "meProfileImage")!,name: "jeon minseop", familyImages: familyImages, kind: "個人", introduce: "一人で猫たちのためにボランティア活動をしています")
    
    self.me = me
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
}


//MARK: UICollectionViewDataSource
extension ANICommunityViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.item == 0 {
      let storyId = NSStringFromClass(ANICommunityStoryCell.self)
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storyId, for: indexPath) as! ANICommunityStoryCell
      cell.frame.origin.y = collectionView.frame.origin.y
      cell.storys = storys
      cell.delegate = self
      return cell
    } else {
      let qnaId = NSStringFromClass(ANICommunityQnaCell.self)
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: qnaId, for: indexPath) as! ANICommunityQnaCell
      cell.frame.origin.y = collectionView.frame.origin.y
      cell.qnas = qnas
      cell.delegate = self
      return cell
    }
  }
}

//MARK: UICollectionViewDelegateFlowLayout
extension ANICommunityViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    return size
  }
}

//MARK: UICollectionViewDelegate
extension ANICommunityViewController: UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let menuBar = self.menuBar, let horizontalBarleftConstraint = menuBar.horizontalBarleftConstraint else { return }
    horizontalBarleftConstraint.constant = scrollView.contentOffset.x / 2
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard let menuBar = self.menuBar else { return }
    let indexPath = IndexPath(item: Int(targetContentOffset.pointee.x / view.frame.width), section: 0)
    menuBar.menuCollectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .left)
    
    selectedIndex = indexPath.item
  }
}

//MARK: ANIButtonViewDelegate
extension ANICommunityViewController: ANIButtonViewDelegate{
  func buttonViewTapped(view: ANIButtonView) {
    guard let me = self.me else { return }
    
    if view === self.contributionButon {
      if selectedIndex == 0 {
        let contributionViewController = ANIContributionViewController()
        contributionViewController.navigationTitle = "STORY"
        contributionViewController.selectedContributionMode = ContributionMode.story
        contributionViewController.delegate = self
        contributionViewController.me = me
        let contributionNV = UINavigationController(rootViewController: contributionViewController)
        self.present(contributionNV, animated: true, completion: nil)
      } else {
        let contributionViewController = ANIContributionViewController()
        contributionViewController.navigationTitle = "Q&A"
        contributionViewController.selectedContributionMode = ContributionMode.qna
        contributionViewController.delegate = self
        contributionViewController.me = me
        let contributionNV = UINavigationController(rootViewController: contributionViewController)
        self.present(contributionNV, animated: true, completion: nil)
      }
    }
  }
}

//MARK: ANIContributionViewControllerDelegate
extension ANICommunityViewController: ANIContributionViewControllerDelegate {
  func contributionButtonTapped(story: Story) {
    if self.storys != nil {
      storys?.insert(story, at: 0)
    } else {
      storys = [story]
    }
  }
  
  func contributionButtonTapped(qna: Qna) {
    if self.qnas != nil {
      qnas?.insert(qna, at: 0)
    } else {
      qnas = [qna]
    }
  }
}

//MARK: ANICommunityMenuBarDelegate
extension ANICommunityViewController: ANICommunityMenuBarDelegate {
  func didSelectCell(index: IndexPath) {
    guard let containerCollectionView = self.containerCollectionView else { return }
    containerCollectionView.scrollToItem(at: index, at: .left, animated: true)
    selectedIndex = index.item
  }
}

//MARK: ANIStoryViewDelegate
extension ANICommunityViewController: ANIStoryViewDelegate {
  func storyViewCellDidSelect(index: Int) {
    guard let storys = self.storys else { return }
    
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.story
    commentViewController.story = storys[index]
    commentViewController.me = me
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
}

//MARK: ANIQnaViewDelegate
extension ANICommunityViewController: ANIQnaViewDelegate {
  func qnaViewCellDidSelect(index: Int) {
    guard let qnas = self.qnas else { return }
    
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.qna
    commentViewController.qna = qnas[index]
    commentViewController.me = me
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
}
