//
//  ViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/02.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIRecruitViewController: ScrollingNavigationViewController {
  
  private weak var categoriesView: ANIRecruitCategoriesView?
  private let CATEGORIES_VIEW_HEIGHT: CGFloat = 45.0
  
  private weak var recruitView: ANIRecuruitView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if let navigationController = self.navigationController as? ScrollingNavigationController,
      let recruitView = self.recruitView,
      let categoriesView = self.categoriesView,
      let recruitCollectionView = recruitView.recruitCollectionView {
      navigationController.followScrollView(recruitCollectionView, delay: 0.0, followers: [categoriesView])
      navigationController.scrollingNavbarDelegate = self
    }
  }
  
  private func setup() {
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
    
    //rcruitView
    let recruitView = ANIRecuruitView()
    self.view.addSubview(recruitView)
    recruitView.topToSuperview()
    recruitView.leftToSuperview()
    recruitView.rightToSuperview()
    recruitView.bottomToSuperview()
    self.recruitView = recruitView
    
    //categoriesView
    let categoriesView = ANIRecruitCategoriesView()
    self.view.addSubview(categoriesView)
    categoriesView.topToSuperview()
    categoriesView.leftToSuperview()
    categoriesView.rightToSuperview()
    categoriesView.height(CATEGORIES_VIEW_HEIGHT)
    self.categoriesView = categoriesView
  }
}

extension ANIRecruitViewController: ScrollingNavigationControllerDelegate {
  func scrollingNavigationController(_ controller: ScrollingNavigationController, willChangeState state: NavigationBarState) {
    view.needsUpdateConstraints()
  }
}
