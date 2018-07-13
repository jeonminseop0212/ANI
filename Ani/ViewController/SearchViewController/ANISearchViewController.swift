//
//  ANISearchViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

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
    categoriesView.height(ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT)
    self.categoriesView = categoriesView
  }
  
  //MARK: Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(viewScrolled: self, selector: #selector(hideKeyboard))
    ANINotificationManager.receive(profileImageViewTapped: self, selector: #selector(pushOtherProfile))
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
    
    let topHeight = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT
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
}

//MARK: ANISearchCategoriesViewDelegate
extension ANISearchViewController: ANISearchCategoriesViewDelegate {
  func didSelectedCell(index: Int) {
    selectedIndex = index
  }
}
