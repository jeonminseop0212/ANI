//
//  CommunityViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints
import FirebaseFirestore
import CodableFirebase
import FirebaseStorage

class ANICommunityViewController: UIViewController {
  
  private weak var menuBar: ANICommunityMenuBar?
  private weak var containerCollectionView: UICollectionView?
  
  private let CONTRIBUTION_BUTTON_HEIGHT: CGFloat = 55.0
  private weak var contributionButon: ANIImageButtonView?
  
  private var rejectViewBottomConstraint: Constraint?
  private var rejectViewBottomConstraintOriginalConstant: CGFloat?
  private weak var rejectView: ANIRejectView?
  private var isRejectAnimating: Bool = false
  private var rejectTapView: UIView?
  
  private var selectedIndex: Int = 0
  
  private var contentType: ContentType?
  private var contributionId: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
    UIApplication.shared.isStatusBarHidden = false
    setupNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    removeNotifications()
  }
  
  private func setup() {
    //basic
    ANIOrientation.lockOrientation(.portrait)
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
    
    //rejectView
    let rejectView = ANIRejectView()
    rejectView.setRejectText("ログインが必要です。")
    self.view.addSubview(rejectView)
    rejectViewBottomConstraint = rejectView.bottomToTop(of: self.view)
    rejectViewBottomConstraintOriginalConstant = rejectViewBottomConstraint?.constant
    rejectView.leftToSuperview()
    rejectView.rightToSuperview()
    self.rejectView = rejectView
    
    //rejectTapView
    let rejectTapView = UIView()
    rejectTapView.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rejectViewTapped))
    rejectTapView.addGestureRecognizer(tapGesture)
    rejectTapView.isHidden = true
    rejectTapView.backgroundColor = .clear
    self.view.addSubview(rejectTapView)
    rejectTapView.size(to: rejectView)
    rejectTapView.topToSuperview()
    self.rejectTapView = rejectTapView
  }
  
  //MAKR: notification
  private func setupNotification() {
    ANINotificationManager.receive(imageCellTapped: self, selector: #selector(presentImageBrowser(_:)))
    ANINotificationManager.receive(profileImageViewTapped: self, selector: #selector(pushOtherProfile))
  }
  
  private func removeNotifications() {
    ANINotificationManager.remove(self)
  }
  
  @objc private func pushOtherProfile(_ notification: NSNotification) {
    guard let userId = notification.object as? String else { return }
    
    if let currentUserUid = ANISessionManager.shared.currentUserUid, currentUserUid == userId {
      let profileViewController = ANIProfileViewController()
      profileViewController.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(profileViewController, animated: true)
      profileViewController.isBackButtonHide = false
    } else {
      let otherProfileViewController = ANIOtherProfileViewController()
      otherProfileViewController.hidesBottomBarWhenPushed = true
      otherProfileViewController.userId = userId
      self.navigationController?.pushViewController(otherProfileViewController, animated: true)
    }
  }
  
  @objc private func presentImageBrowser(_ notification: NSNotification) {
    guard let item = notification.object as? (Int, [String]) else { return }
    let selectedIndex = item.0
    let imageUrls = item.1
    let imageBrowserViewController = ANIImageBrowserViewController()
    imageBrowserViewController.selectedIndex = selectedIndex
    imageBrowserViewController.imageUrls = imageUrls
    imageBrowserViewController.modalPresentationStyle = .overCurrentContext
    imageBrowserViewController.delegate = self
    //overCurrentContextだとtabBarが消えないのでtabBarからpresentする
    self.tabBarController?.present(imageBrowserViewController, animated: false, completion: nil)
  }
  
  //action
  @objc private func rejectViewTapped() {
    let initialViewController = ANIInitialViewController()
    let navigationController = UINavigationController(rootViewController: initialViewController)
    self.present(navigationController, animated: true, completion: nil)
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
      cell.delegate = self
      return cell
    } else {
      let qnaId = NSStringFromClass(ANICommunityQnaCell.self)
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: qnaId, for: indexPath) as! ANICommunityQnaCell
      cell.frame.origin.y = collectionView.frame.origin.y
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
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let cell = cell as? ANICommunityStoryCell {
      cell.isCellSelected = true
    } else if let cell = cell as? ANICommunityQnaCell {
      cell.isCellSelected = true
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let cell = cell as? ANICommunityStoryCell {
      cell.isCellSelected = false
    } else if let cell = cell as? ANICommunityQnaCell {
      cell.isCellSelected = false
    }
  }
}

//MARK: ANIButtonViewDelegate
extension ANICommunityViewController: ANIButtonViewDelegate{
  func buttonViewTapped(view: ANIButtonView) {
    
    if view === self.contributionButon {
      if ANISessionManager.shared.isAnonymous == false {
        if selectedIndex == 0 {
          let contributionViewController = ANIContributionViewController()
          contributionViewController.navigationTitle = "STORY"
          contributionViewController.selectedContributionMode = ContributionMode.story
          let contributionNV = UINavigationController(rootViewController: contributionViewController)
          self.present(contributionNV, animated: true, completion: nil)
        } else {
          let contributionViewController = ANIContributionViewController()
          contributionViewController.navigationTitle = "Q&A"
          contributionViewController.selectedContributionMode = ContributionMode.qna
          let contributionNV = UINavigationController(rootViewController: contributionViewController)
          self.present(contributionNV, animated: true, completion: nil)
        }
      } else {
        reject()
      }
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
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.story
    commentViewController.story = selectedStory
    commentViewController.user = user
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
  
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    let recruitDetailViewController = ANIRecruitDetailViewController()
    recruitDetailViewController.hidesBottomBarWhenPushed = true
    recruitDetailViewController.recruit = recruit
    recruitDetailViewController.user = user
    self.navigationController?.pushViewController(recruitDetailViewController, animated: true)
  }
  
  func reject() {
    guard let rejectViewBottomConstraint = self.rejectViewBottomConstraint,
      !isRejectAnimating,
      let rejectTapView = self.rejectTapView else { return }
    
    rejectViewBottomConstraint.constant = UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT
    rejectTapView.isHidden = false
    
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
      self.isRejectAnimating = true
      self.view.layoutIfNeeded()
    }) { (complete) in
      guard let rejectViewBottomConstraint = self.rejectViewBottomConstraint,
        let rejectViewBottomConstraintOriginalConstant = self.rejectViewBottomConstraintOriginalConstant else { return }
      
      rejectViewBottomConstraint.constant = rejectViewBottomConstraintOriginalConstant
      UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseInOut, animations: {
        self.view.layoutIfNeeded()
      }, completion: { (complete) in
        self.isRejectAnimating = false
        rejectTapView.isHidden = true
      })
    }
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.contentType = contentType
    self.contributionId = id
    
    let popupOptionViewController = ANIPopupOptionViewController()
    popupOptionViewController.modalPresentationStyle = .overCurrentContext
    popupOptionViewController.isMe = isMe
    popupOptionViewController.delegate = self
    self.tabBarController?.present(popupOptionViewController, animated: false, completion: nil)
  }
}

//MARK: ANIQnaViewDelegate
extension ANICommunityViewController: ANIQnaViewDelegate {
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user: FirebaseUser) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.qna
    commentViewController.qna = selectedQna
    commentViewController.user = user
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
}

//MARK: ANIImageBrowserViewControllerDelegate
extension ANICommunityViewController: ANIImageBrowserViewControllerDelegate {
  func imageBrowserDidDissmiss() {
    UIApplication.shared.statusBarStyle = .default
  }
}

//MARK: ANIPopupOptionViewControllerDelegate
extension ANICommunityViewController: ANIPopupOptionViewControllerDelegate {
  func deleteContribution() {
    let alertController = UIAlertController(title: nil, message: "投稿を削除しますか？", preferredStyle: .alert)
    
    let logoutAction = UIAlertAction(title: "削除", style: .default) { (action) in
      self.deleteData()
    }
    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
    
    alertController.addAction(logoutAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  func reportContribution() {
    let alertController = UIAlertController(title: nil, message: "投稿を通報しますか？", preferredStyle: .alert)
    
    let logoutAction = UIAlertAction(title: "通報", style: .default) { (action) in
      self.reportData()
    }
    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
    
    alertController.addAction(logoutAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
}

//MAKR: data
extension ANICommunityViewController {
  private func deleteData() {
    guard let contentType = self.contentType, let contributionId = self.contributionId, let containerCollectionView = self.containerCollectionView else { return }
      
    let database = Firestore.firestore()
    
    var collection = ""
    
    if contentType == .story {
      collection = KEY_STORIES
    } else if contentType == .qna {
      collection = KEY_QNAS
    }
    
    DispatchQueue.global().async {
      database.collection(collection).document(contributionId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          print("get document error \(error)")
          
          return
        }
        
        database.collection(collection).document(contributionId).delete()
        
        DispatchQueue.main.async {
          if contentType == .story {
            ANINotificationManager.postDeleteStory(id: contributionId)
          } else if contentType == .qna {
            ANINotificationManager.postDeleteQna(id: contributionId)
          }
        }
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          if contentType == .story {
            let story = try FirestoreDecoder().decode(FirebaseStory.self, from: data)
            
            if let urls = story.storyImageUrls {
              for url in urls {
                let storage = Storage.storage()
                let storageRef = storage.reference(forURL: url)
                
                storageRef.delete { error in
                  if let error = error {
                    print(error)
                  }
                }
              }
            }
          } else if contentType == .qna {
            let qna = try FirestoreDecoder().decode(FirebaseQna.self, from: data)
            
            if let urls = qna.qnaImageUrls {
              for url in urls {
                let storage = Storage.storage()
                let storageRef = storage.reference(forURL: url)
                
                storageRef.delete { error in
                  if let error = error {
                    print(error)
                  }
                }
              }
            }
          }
        } catch let error {
          print(error)
        }
      })
    }
    
    DispatchQueue.global().async {
      database.collection(collection).document(contributionId).collection(KEY_LOVE_IDS).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Get document error \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          database.collection(collection).document(contributionId).collection(KEY_LOVE_IDS).document(document.documentID).delete()
        }
      })
      
      database.collection(collection).document(contributionId).collection(KEY_COMMENTS).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Get document error \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          database.collection(collection).document(contributionId).collection(KEY_COMMENTS).document(document.documentID).delete()
        }
      })
    }
  }
  
  private func reportData() {
    guard let contentType = self.contentType, let contributionId = self.contributionId else { return }
    
    let database = Firestore.firestore()
    
    var contentTypeString = ""

    if contentType == .recruit {
      contentTypeString = "recurit"
    } else if contentType == .story {
      contentTypeString = "story"
    } else if contentType == .qna {
      contentTypeString = "qna"
    }
    
    let date = ANIFunction.shared.getToday()
    let values = ["contentType": contentTypeString, "date": date]
    database.collection(KEY_REPORTS).document(contributionId).collection(KEY_REPORT).addDocument(data: values)
  }
}
