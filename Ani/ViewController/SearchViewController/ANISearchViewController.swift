//
//  ANISearchViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints
import FirebaseFirestore
import CodableFirebase
import FirebaseStorage
import InstantSearchClient

class ANISearchViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBarTopConstroint: Constraint?
  
  private weak var categoriesView: ANISearchCategoriesView?
  static let CATEGORIES_VIEW_HEIGHT: CGFloat = 47.0
  
  private weak var searchBar: UISearchBar?
  private weak var searchView: ANISearchView?
  
  private var selectedIndex: Int = 0 {
    didSet {
      guard let searchView = self.searchView else { return }

      if selectedIndex == 0 {
        searchView.selectedCategory = .user
      } else if selectedIndex == 1 {
        searchView.selectedCategory = .story
      } else {
        searchView.selectedCategory = .qna
      }
    }
  }
  
  private var searchText: String = "" {
    didSet {
      guard let searchView = self.searchView else { return }

      searchView.searchText = searchText
    }
  }
  
  private var rejectViewBottomConstraint: Constraint?
  private var rejectViewBottomConstraintOriginalConstant: CGFloat?
  private weak var rejectView: ANIRejectView?
  private var isRejectAnimating: Bool = false
  private var rejectTapView: UIView?
  
  private var contentType: ContentType?
  private var contributionId: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
    setupNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    removeNotifications()
  }
  
  private func setup() {
    //basic
    ANIOrientation.lockOrientation(.portrait)
    self.view.backgroundColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false
    
    //searchView
    let searchView = ANISearchView()
    searchView.delegate = self
    self.view.addSubview(searchView)
    searchView.topToSuperview(usingSafeArea: true)
    searchView.edgesToSuperview(excluding: .top)
    self.searchView = searchView
    
    //myNavigationBar
    let myNavigationBar = UIView()
    myNavigationBar.backgroundColor = .white
    self.view.addSubview(myNavigationBar)
    myNavigationBarTopConstroint = myNavigationBar.topToSuperview(usingSafeArea: true)
    myNavigationBar.leftToSuperview()
    myNavigationBar.rightToSuperview()
    myNavigationBar.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBar = myNavigationBar
    
    //searchBar
    let searchBar = UISearchBar()
    searchBar.placeholder = "Search"
    searchBar.textField?.backgroundColor = ANIColor.lightGray
    searchBar.delegate = self
    searchBar.backgroundImage = UIImage()
    searchBar.tintColor = ANIColor.darkGray
    myNavigationBar.addSubview(searchBar)
    searchBar.topToSuperview()
    searchBar.leftToSuperview()
    searchBar.rightToSuperview()
    searchBar.bottomToSuperview()
    self.searchBar = searchBar
    
    //categoriesView
    let categoriesView = ANISearchCategoriesView()
    categoriesView.delegate = self
    self.view.addSubview(categoriesView)
    categoriesView.topToBottom(of: myNavigationBar)
    categoriesView.leftToSuperview()
    categoriesView.rightToSuperview()
    categoriesView.height(ANIRecruitViewController.FILTERS_VIEW_HEIGHT)
    self.categoriesView = categoriesView
    
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
  
  //MARK: Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(viewScrolled: self, selector: #selector(hideKeyboard))
    ANINotificationManager.receive(profileImageViewTapped: self, selector: #selector(pushOtherProfile))
    ANINotificationManager.receive(imageCellTapped: self, selector: #selector(presentImageBrowser(_:)))
  }
  
  private func removeNotifications() {
    ANINotificationManager.remove(self)
  }
  
  @objc private func hideKeyboard() {
    guard let searchBar = self.searchBar,
      let searchBarTextField = searchBar.textField else { return }
    if searchBarTextField.isFirstResponder {
      searchBarTextField.resignFirstResponder()
      searchBar.setShowsCancelButton(false, animated: true)
      
      if let searchCancelButton = searchBar.cancelButton {
        searchCancelButton.alpha = 0.0
      }
    }
  }
  
  @objc private func pushOtherProfile(_ notification: NSNotification) {
    guard let userId = notification.object as? String else { return }
    
    let otherProfileViewController = ANIOtherProfileViewController()
    otherProfileViewController.hidesBottomBarWhenPushed = true
    otherProfileViewController.userId = userId
    self.navigationController?.pushViewController(otherProfileViewController, animated: true)
  }
  
  @objc private func rejectViewTapped() {
    let initialViewController = ANIInitialViewController()
    let navigationController = UINavigationController(rootViewController: initialViewController)
    self.present(navigationController, animated: true, completion: nil)
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
}

//MARK: UISearchBarDelegate
extension ANISearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let searchBarTextField = searchBar.textField,
          let text = searchBarTextField.text else { return }
    if searchBarTextField.isFirstResponder {
      searchBarTextField.resignFirstResponder()
      
      self.searchText = text
    }
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    guard let searchBarTextField = searchBar.textField else { return }
    if searchBarTextField.isFirstResponder {
      searchBarTextField.resignFirstResponder()
    }
    
    searchBar.setShowsCancelButton(false, animated: true)
    if let searchCancelButton = searchBar.cancelButton {
      searchCancelButton.alpha = 0.0
    }
  }

  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.setShowsCancelButton(true, animated: true)
    if let searchCancelButton = searchBar.cancelButton {
      searchCancelButton.alpha = 1.0
    }
    return true
  }
}

//MARK: ANIUserSearchViewDelegate
extension ANISearchViewController: ANISearchViewDelegate {
  func searchViewDidScroll(scrollY: CGFloat) {
    guard let myNavigationBarTopConstroint = self.myNavigationBarTopConstroint else { return }
    
    let topHeight = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.FILTERS_VIEW_HEIGHT
    let newScrollY = topHeight + scrollY
    
    //navigation animate
    if topHeight < newScrollY {
      if scrollY < topHeight {
        myNavigationBarTopConstroint.constant = -scrollY
        self.view.layoutIfNeeded()
        
        let alpha = 1 - (scrollY / topHeight)
        searchBar?.alpha = alpha
        categoriesView?.categoryCollectionView?.alpha = alpha
      } else {
        myNavigationBarTopConstroint.constant = -topHeight
        searchBar?.alpha = 0.0
        categoriesView?.categoryCollectionView?.alpha = 0.0
        self.view.layoutIfNeeded()
      }
    } else {
      myNavigationBarTopConstroint.constant = 0.0
      self.view.layoutIfNeeded()
      
      searchBar?.alpha = 1.0
      categoriesView?.categoryCollectionView?.alpha = 1.0
    }
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

//MARK: ANISearchCategoriesViewDelegate
extension ANISearchViewController: ANISearchCategoriesViewDelegate {
  func didSelectedCell(index: Int) {
    selectedIndex = index
  }
}

//MARK: ANIImageBrowserViewControllerDelegate
extension ANISearchViewController: ANIImageBrowserViewControllerDelegate {
  func imageBrowserDidDissmiss() {
    UIApplication.shared.statusBarStyle = .default
  }
}

//MARK: ANIPopupOptionViewControllerDelegate
extension ANISearchViewController: ANIPopupOptionViewControllerDelegate {
  func deleteContribution() {
    let alertController = UIAlertController(title: nil, message: "投稿を削除しますか？", preferredStyle: .alert)
    
    let deleteAction = UIAlertAction(title: "削除", style: .default) { (action) in
      self.deleteData()
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
  }
}

//MAKR: data
extension ANISearchViewController {
  private func deleteData() {
    guard let contentType = self.contentType, let contributionId = self.contributionId else { return }
    
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
        self.delegateDataAlgolia(contentType: contentType, contributionId: contributionId)
        
        DispatchQueue.main.async {
          guard let searchView = self.searchView else { return }
          
          searchView.deleteData(id: contributionId)
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
  
  private func delegateDataAlgolia(contentType: ContentType, contributionId: String) {
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
}

