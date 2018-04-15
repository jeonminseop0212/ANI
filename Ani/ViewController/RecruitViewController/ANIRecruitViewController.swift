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
  static let CATEGORIES_VIEW_HEIGHT: CGFloat = 45.0
  
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
    
    //navigation bar right item
    let filterImage = UIImage(named: "filter")?.withRenderingMode(.alwaysOriginal)
    let filterButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    filterButton.setImage(filterImage, for: .normal)
    filterButton.addTarget(self, action: #selector(filter), for: .touchUpInside)
    let rightBarButton = UIBarButtonItem()
    rightBarButton.customView = filterButton
    navigationItem.rightBarButtonItem = rightBarButton
    
    //rcruitView
    let recruitView = ANIRecuruitView()
    self.view.addSubview(recruitView)
    recruitView.edgesToSuperview()
    self.recruitView = recruitView
    
    //categoriesView
    let categoriesView = ANIRecruitCategoriesView()
    self.view.addSubview(categoriesView)
    categoriesView.topToSuperview()
    categoriesView.leftToSuperview()
    categoriesView.rightToSuperview()
    categoriesView.height(ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT)
    self.categoriesView = categoriesView
  }
  
  @objc func filter() {
    print("filtering")
  }
}

extension ANIRecruitViewController: ScrollingNavigationControllerDelegate {
  func scrollingNavigationController(_ controller: ScrollingNavigationController, willChangeState state: NavigationBarState) {
    view.needsUpdateConstraints()
  }
}
