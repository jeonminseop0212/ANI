//
//  ANISearchViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANISearchViewController: ScrollingNavigationViewController {
  
  private weak var categoriesView: ANISearchCategoriesView?
  static let CATEGORIES_VIEW_HEIGHT: CGFloat = 45.0
  
  private weak var userSearchView: ANIUserSearchView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if let navigationController = self.navigationController as? ScrollingNavigationController,
      let userSearchView = self.userSearchView,
      let categoriesView = self.categoriesView,
      let userTableView = userSearchView.userTableView {
      navigationController.followScrollView(userTableView, delay: 0.0, followers: [categoriesView])
      navigationController.scrollingNavbarDelegate = self
    }
  }
  
  private func setup() {
    Orientation.lockOrientation(.portrait)
    self.view.backgroundColor = .white
    //nav barの下からviewが開始するように
    self.navigationController?.navigationBar.isTranslucent = false
    
    //searchBar
    let searchBar = UISearchBar()
    searchBar.placeholder = "Search"
    searchBar.textField?.backgroundColor = ANIColor.lightGray
    //    searchBar.showsCancelButton = true
    //    searchBar.delegate = self
    navigationItem.titleView = searchBar
    
    //userSearchView
    let userSearchView = ANIUserSearchView()
    self.view.addSubview(userSearchView)
    userSearchView.edgesToSuperview()
    self.userSearchView = userSearchView
    
    //categoriesView
    let categoriesView = ANISearchCategoriesView()
    self.view.addSubview(categoriesView)
    categoriesView.topToSuperview()
    categoriesView.leftToSuperview()
    categoriesView.rightToSuperview()
    categoriesView.height(ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT)
    self.categoriesView = categoriesView
  }
}

extension ANISearchViewController: ScrollingNavigationControllerDelegate {
  func scrollingNavigationController(_ controller: ScrollingNavigationController, willChangeState state: NavigationBarState) {
    view.needsUpdateConstraints()
  }
}
