//
//  ANINotiDetailViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/07/09.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import FirebaseStorage
import InstantSearchClient

class ANINotiDetailViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBase: UIView?
  private weak var navigationTitleLabel: UILabel?
  private weak var backButton: UIButton?
  
  private weak var notiDetailView: ANINotiDetailView?
  
  var navigationTitle: String = ""
  
  private var isMe: Bool?
  var contributionKind: ContributionKind?
  var notiKind: NotiKind?
  var noti: FirebaseNotification?
  
  private var contentType: ContentType?
  private var contributionId: String?
  
  private weak var activityIndicatorView: ANIActivityIndicator?
  
  override func viewDidLoad() {
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if #available(iOS 13.0, *) {
      UIApplication.shared.statusBarStyle = .darkContent
    } else {
      UIApplication.shared.statusBarStyle = .default
    }
    UIApplication.shared.isStatusBarHidden = false
    setupNotifications()
    
    playVideo()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    stopVideo()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    removeNotifications()
  }
  
  private func setup() {
    //basic
    self.view.backgroundColor = .white
    
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
    navigationTitleLabel.textColor = ANIColor.dark
    navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    navigationTitleLabel.text = navigationTitle
    myNavigationBase.addSubview(navigationTitleLabel)
    navigationTitleLabel.centerInSuperview()
    self.navigationTitleLabel = navigationTitleLabel
    
    //backButton
    let backButton = UIButton()
    let backButtonImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate)
    backButton.setImage(backButtonImage, for: .normal)
    backButton.tintColor = ANIColor.dark
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    myNavigationBase.addSubview(backButton)
    backButton.width(44.0)
    backButton.height(44.0)
    backButton.leftToSuperview()
    backButton.centerYToSuperview()
    self.backButton = backButton
    
    //notiDetailView
    let notiDetailView = ANINotiDetailView()
    notiDetailView.contributionKind = contributionKind
    notiDetailView.notiKind = notiKind
    notiDetailView.noti = noti
    notiDetailView.delegate = self
    self.view.addSubview(notiDetailView)
    notiDetailView.topToBottom(of: myNavigationBase)
    notiDetailView.edgesToSuperview(excluding: .top)
    self.notiDetailView = notiDetailView
    
    //activityIndicatorView
    let activityIndicatorView = ANIActivityIndicator()
    activityIndicatorView.isFull = true
    self.tabBarController?.view.addSubview(activityIndicatorView)
    activityIndicatorView.edgesToSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  func playVideo() {
    guard let notiDetailView = self.notiDetailView else { return }

    notiDetailView.playVideo()
  }
  
  private func stopVideo() {
    guard let notiDetailView = self.notiDetailView else { return }

    notiDetailView.stopVideo()
  }
  
  //MARK: Notifications
  private func setupNotifications() {
    removeNotifications()
    ANINotificationManager.receive(profileImageViewTapped: self, selector: #selector(pushOtherProfile))
    ANINotificationManager.receive(imageCellTapped: self, selector: #selector(presentImageBrowser(_:)))
    ANINotificationManager.receive(tapHashtag: self, selector: #selector(pushHashtagList))
  }
  
  private func removeNotifications() {
    ANINotificationManager.remove(self)
  }
  
  @objc private func back() {
    self.navigationController?.popViewController(animated: true)
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
  
  @objc private func pushHashtagList(_ notification: NSNotification) {
    if let userInfo = notification.userInfo,
      let contributionKind = userInfo[KEY_CONTRIBUTION_KIND] as? String,
      let hashtag = userInfo[KEY_HASHTAG] as? String {
      let hashtagListViewController = ANIHashtagListViewController()
      hashtagListViewController.hashtag = hashtag
      if contributionKind == KEY_CONTRIBUTION_KIND_STROY {
        hashtagListViewController.hashtagList = .story
      } else if contributionKind == KEY_CONTRIBUTION_KIND_QNA {
        hashtagListViewController.hashtagList = .question
      }
      hashtagListViewController.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(hashtagListViewController, animated: true)
    }
  }
}

//MARK: ANINotiDetailViewDelegate
extension ANINotiDetailViewController: ANINotiDetailViewDelegate {
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit, user: FirebaseUser) {
    let recruitDetailViewController = ANIRecruitDetailViewController()
    recruitDetailViewController.hidesBottomBarWhenPushed = true
    recruitDetailViewController.recruit = selectedRecruit
    recruitDetailViewController.user = user
    self.navigationController?.pushViewController(recruitDetailViewController, animated: true)
  }
  
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser) {
    let supportViewController = ANISupportViewController()
    supportViewController.modalPresentationStyle = .overCurrentContext
    supportViewController.recruit = supportRecruit
    supportViewController.user = user
    self.tabBarController?.present(supportViewController, animated: false, completion: nil)
  }
  
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
  
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user: FirebaseUser) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.qna
    commentViewController.qna = selectedQna
    commentViewController.user = user
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.isMe = isMe
    self.contentType = contentType
    self.contributionId = id
    let popupOptionViewController = ANIPopupOptionViewController()
    popupOptionViewController.modalPresentationStyle = .overCurrentContext
    popupOptionViewController.isMe = isMe
    if !isMe {
      popupOptionViewController.options = ["非表示"]
      if contentType == ContentType.story {
        popupOptionViewController.options?.insert("シェア", at: 0)
      }
    } else {
      if contentType == ContentType.story {
        popupOptionViewController.options = ["シェア"]
      }
    }
    popupOptionViewController.delegate = self
    self.tabBarController?.present(popupOptionViewController, animated: false, completion: nil)
  }
  
  func popupCommentOptionView(isMe: Bool, commentId: String) {
    self.contentType = .comment
    
    let popupOptionViewController = ANIPopupOptionViewController()
    popupOptionViewController.modalPresentationStyle = .overCurrentContext
    popupOptionViewController.isMe = isMe
    popupOptionViewController.delegate = self
    self.tabBarController?.present(popupOptionViewController, animated: false, completion: nil)
  }
  
  func commentCellTapped(story: FirebaseStory, storyUser: FirebaseUser, comment: FirebaseComment, commentUser: FirebaseUser) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.story
    commentViewController.story = story
    commentViewController.user = storyUser
    commentViewController.selectedComment = comment
    commentViewController.selectedCommentUser = commentUser
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
  
  func commentCellTapped(qna: FirebaseQna, qnaUser: FirebaseUser, comment: FirebaseComment, commentUser: FirebaseUser) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.qna
    commentViewController.qna = qna
    commentViewController.user = qnaUser
    commentViewController.selectedComment = comment
    commentViewController.selectedCommentUser = commentUser
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
}

//MARK: ANIImageBrowserViewControllerDelegate
extension ANINotiDetailViewController: ANIImageBrowserViewControllerDelegate {
  func imageBrowserDidDissmiss() {
    if #available(iOS 13.0, *) {
      UIApplication.shared.statusBarStyle = .darkContent
    } else {
      UIApplication.shared.statusBarStyle = .default
    }
  }
}

//MARK: ANIPopupOptionViewControllerDelegate
extension ANINotiDetailViewController: ANIPopupOptionViewControllerDelegate {
  func deleteContribution() {
    let alertController = UIAlertController(title: nil, message: "投稿を削除しますか？", preferredStyle: .alert)
    
    let deleteAction = UIAlertAction(title: "削除", style: .default) { (action) in
      guard let contentType = self.contentType else { return }
      
      if contentType == .comment {
        self.deleteComment()
      } else {
        self.deleteData()
      }
    }
    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
    
    alertController.addAction(deleteAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  func reportContribution() {
    let alertController = UIAlertController(title: nil, message: "投稿を通報しますか？", preferredStyle: .alert)
    
    let reportAction = UIAlertAction(title: "通報", style: .default) { (action) in
      self.reportData()
    }
    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
    
    alertController.addAction(reportAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  func optionTapped(index: Int) {
    guard let isMe = self.isMe,
          let contentType = self.contentType,
          let contributionId = self.contributionId else { return }
    
    var alertTitle = ""
    var alertMessage = ""
    var collection = ""
    
    if contentType == .story {
      if isMe {
        if index == 0 {
          let activityItems = [ANIActivityItemSorce(shareContent: "https://myaurelease.page.link/?link=https://ani-release.firebaseapp.com/story/\(contributionId)/&isi=1441739235&ibi=com.gmail-jeonminsopdev.MYAU")]
          let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
          self.present(activityViewController, animated: true)
        }
      } else {
        if index == 0 {
          let activityItems = [ANIActivityItemSorce(shareContent: "https://myaurelease.page.link/?link=https://ani-release.firebaseapp.com/story/\(contributionId)/&isi=1441739235&ibi=com.gmail-jeonminsopdev.MYAU")]
          let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
          self.present(activityViewController, animated: true)
        } else if index == 1 {
          alertTitle = "このストーリーを非表示にしますか？"
          alertMessage = "非表示にしたストーリーはアプリの中で見えなくなります。後から非表示を解除することは出来ません。"
          collection = KEY_STORIES
          
          self.hideContribution(contentType: contentType, collection: collection, contributionId: contributionId, title: alertTitle, message: alertMessage)
        }
      }
    } else if contentType == .qna {
      if index == 0 {
        alertTitle = "この質問を非表示にしますか？"
        alertMessage = "非表示にした質問はアプリの中で見えなくなります。後から非表示を解除することは出来ません。"
        collection = KEY_QNAS
        
        self.hideContribution(contentType: contentType, collection: collection, contributionId: contributionId, title: alertTitle, message: alertMessage)
      }
    }
  }
  
  private func hideContribution(contentType: ContentType, collection: String, contributionId: String, title: String, message: String) {
    guard let currentUserId = ANISessionManager.shared.currentUserUid else {
      return
    }
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let hideAction = UIAlertAction(title: "非表示", style: .default) { (action) in
      let database = Firestore.firestore()
      
      self.activityIndicatorView?.startAnimating()
      
      DispatchQueue.global().async {
        database.collection(collection).document(contributionId).getDocument(completion: { (snapshot, error) in
          if let error = error {
            DLog("Error get document: \(error)")
            return
          }
          
          guard let snapshot = snapshot, let data = snapshot.data() else { return }
          
          if contentType == .story {
            do {
              let story = try FirestoreDecoder().decode(FirebaseStory.self, from: data)
              
              if let hideUserIds = story.hideUserIds {
                var hideUserIdsTemp = hideUserIds
                hideUserIdsTemp.append(currentUserId)
                
                database.collection(collection).document(contributionId).updateData([KEY_HIDE_USER_IDS: hideUserIdsTemp])
                
                self.updateDataAlgolia(objectId: contributionId, data: [KEY_HIDE_USER_IDS: hideUserIdsTemp as AnyObject], indexName: KEY_STORIES_INDEX)
              } else {
                let hideUserIds = [currentUserId]
                
                database.collection(collection).document(contributionId).updateData([KEY_HIDE_USER_IDS: hideUserIds])
                
                self.updateDataAlgolia(objectId: contributionId, data: [KEY_HIDE_USER_IDS: hideUserIds as AnyObject], indexName: KEY_STORIES_INDEX)
              }
              
              DispatchQueue.main.async {
                self.activityIndicatorView?.stopAnimating()
                
                ANINotificationManager.postDeleteStory(id: contributionId)
              }
            } catch let error {
              DLog(error)
            }
          } else if contentType == .qna {
            do {
              let qna = try FirestoreDecoder().decode(FirebaseQna.self, from: data)
              
              if let hideUserIds = qna.hideUserIds {
                var hideUserIdsTemp = hideUserIds
                hideUserIdsTemp.append(currentUserId)
                
                database.collection(collection).document(contributionId).updateData([KEY_HIDE_USER_IDS: hideUserIdsTemp])
                
                self.updateDataAlgolia(objectId: contributionId, data: [KEY_HIDE_USER_IDS: hideUserIdsTemp as AnyObject], indexName: KEY_QNAS_INDEX)
              } else {
                let hideUserIds = [currentUserId]
                
                database.collection(collection).document(contributionId).updateData([KEY_HIDE_USER_IDS: hideUserIds])
                
                self.updateDataAlgolia(objectId: contributionId, data: [KEY_HIDE_USER_IDS: hideUserIds as AnyObject], indexName: KEY_QNAS_INDEX)
              }
              
              DispatchQueue.main.async {
                self.activityIndicatorView?.stopAnimating()
                
                ANINotificationManager.postDeleteQna(id: contributionId)
              }
            } catch let error {
              DLog(error)
            }
          }
        })
      }
    }
    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
    
    alertController.addAction(hideAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  private func updateDataAlgolia(objectId: String, data: [String: AnyObject], indexName: String) {
    let index = ANISessionManager.shared.client.index(withName: indexName)
    
    DispatchQueue.global().async {
      index.partialUpdateObject(data, withID: objectId, completionHandler: { (content, error) -> Void in
        if error == nil {
          DLog("Object IDs: \(content!)")
        }
      })
    }
  }
}

//MAKR: data
extension ANINotiDetailViewController {
  private func deleteData() {
    guard let contentType = self.contentType,
          let noti = self.noti else { return }
    
    let database = Firestore.firestore()
    
    var collection = ""
    var loveIDsCollection = ""
    
    if contentType == .story {
      collection = KEY_STORIES
      loveIDsCollection = KEY_LOVE_STORY_IDS
    } else if contentType == .qna {
      collection = KEY_QNAS
      loveIDsCollection = KEY_LOVE_QNA_IDS
    }
    
    DispatchQueue.global().async {
      database.collection(collection).document(noti.notiId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          DLog("get document error \(error)")
          
          return
        }
        
        database.collection(collection).document(noti.notiId).delete()
        self.deleteDataAlgolia(contentType: contentType, contributionId: noti.notiId)
        
        DispatchQueue.main.async {
          self.navigationController?.popViewController(animated: true)
        }
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          if contentType == .story {
            let story = try FirestoreDecoder().decode(FirebaseStory.self, from: data)
            let storage = Storage.storage()

            if let urls = story.storyImageUrls {
              for url in urls {
                let storageRef = storage.reference(forURL: url)
                
                storageRef.delete { error in
                  if let error = error {
                    DLog(error)
                  }
                }
              }
            }
            
            if let videoUrl = story.storyVideoUrl {
              let storageRef = storage.reference(forURL: videoUrl)
              
              storageRef.delete { error in
                if let error = error {
                  DLog(error)
                }
              }
            }
            
            if let thumbnailImageUrl = story.thumbnailImageUrl {
              let storageRef = storage.reference(forURL: thumbnailImageUrl)
              
              storageRef.delete { error in
                if let error = error {
                  DLog(error)
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
                    DLog(error)
                  }
                }
              }
            }
          }
        } catch let error {
          DLog(error)
        }
      })
    }
    
    DispatchQueue.global().async {
      database.collection(collection).document(noti.notiId).collection(KEY_LOVE_IDS).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Get document error \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
         database.collection(KEY_USERS).document(document.documentID).collection(loveIDsCollection).document(noti.notiId).delete()
          database.collection(collection).document(noti.notiId).collection(KEY_LOVE_IDS).document(document.documentID).delete()
        }
      })
      
      database.collection(collection).document(noti.notiId).collection(KEY_COMMENTS).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Get document error \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          database.collection(collection).document(noti.notiId).collection(KEY_COMMENTS).document(document.documentID).delete()
        }
      })
    }
  }
  
  private func deleteDataAlgolia(contentType: ContentType, contributionId: String) {
    var index: Index?
    
    if contentType == .story {
      index = ANISessionManager.shared.client.index(withName: KEY_STORIES_INDEX)
    } else if contentType == .qna {
      index = ANISessionManager.shared.client.index(withName: KEY_QNAS_INDEX)
    }
    
    DispatchQueue.global().async {
      index?.deleteObject(withID: contributionId)
    }
  }
  
  private func deleteComment() {
    guard let noti = self.noti,
          let contributionKind = self.contributionKind,
          let commentId = noti.commentId else { return }
    
    var collection = ""
    if contributionKind == .storyComment {
      collection = KEY_STORIES
    } else {
      collection = KEY_QNAS
    }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(collection).document(noti.notiId).collection(KEY_COMMENTS).document(commentId).delete()

      DispatchQueue.main.async {
        self.navigationController?.popViewController(animated: true)
      }
    }
    
    DispatchQueue.global().async {
      database.collection(collection).document(noti.notiId).collection(KEY_COMMENTS).document(commentId).collection(KEY_LOVE_IDS).getDocuments { (snapshot, error) in
        if let error = error {
          DLog("get documments error \(error)")
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          database.collection(collection).document(noti.notiId).collection(KEY_COMMENTS).document(commentId).collection(KEY_LOVE_IDS).document(document.documentID).delete()
        }
      }
    }
  }
  
  private func reportData() {
    guard let contentType = self.contentType, let contributionId = self.contributionId else { return }
    
    let database = Firestore.firestore()
    
    var contentTypeString = ""

    if contentType == .recruit {
      contentTypeString = KEY_RECRUIT
    } else if contentType == .story {
      contentTypeString = KEY_STORY
    } else if contentType == .qna {
      contentTypeString = KEY_QNA
    }
    
    let date = ANIFunction.shared.getToday()
    let values = [KEY_CONTENT_TYPE: contentTypeString, KEY_DATE: date]
    database.collection(KEY_REPORTS).document(contributionId).collection(KEY_REPORT).addDocument(data: values)
  }
}
