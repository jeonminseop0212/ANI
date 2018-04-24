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
  
  private weak var searchBar: UISearchBar?
  
  private let CONTRIBUTION_BUTTON_HEIGHT:CGFloat = 55.0
  private weak var contributionButon: ANIImageButtonView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    setupNotifications()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if let navigationController = self.navigationController as? ScrollingNavigationController,
      let recruitView = self.recruitView,
      let categoriesView = self.categoriesView,
      let recruitTableView = recruitView.recruitTableView {
      navigationController.followScrollView(recruitTableView, delay: 0.0, followers: [categoriesView])
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
    searchBar.delegate = self
    self.searchBar = searchBar
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
    
    //contributionButon
    let contributionButon = ANIImageButtonView()
    contributionButon.image = UIImage(named: "contributionButton")
    contributionButon.superViewCornerRadius(radius: CONTRIBUTION_BUTTON_HEIGHT / 2)
    contributionButon.superViewDropShadow(opacity: 0.13)
    contributionButon.delegate = self
    self.view.addSubview(contributionButon)
    let tabBarHeight = UITabBarController().tabBar.frame.height
    contributionButon.rightToSuperview(offset: 15.0)
    contributionButon.bottomToSuperview(offset: -(15.0 + tabBarHeight))
    self.contributionButon = contributionButon
  }
  
  @objc func filter() {
    print("filtering")
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
  
  //MARK: - Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(viewScrolled: self, selector: #selector(hideKeyboard))
  }
}

extension ANIRecruitViewController: ScrollingNavigationControllerDelegate {
  func scrollingNavigationController(_ controller: ScrollingNavigationController, willChangeState state: NavigationBarState) {
    view.needsUpdateConstraints()
  }
}

extension ANIRecruitViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let searchBarTextField = searchBar.textField else { return }
    if searchBarTextField.isFirstResponder {
      searchBarTextField.resignFirstResponder()
    }
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    guard let searchBarTextField = searchBar.textField else { return }
    if searchBarTextField.isFirstResponder {
      searchBarTextField.resignFirstResponder()
    }
  }
}

extension ANIRecruitViewController:ANIButtonViewDelegate{
  func buttonViewTapped(view: ANIButtonView) {
    if view === self.contributionButon {
      print("recruit contribution tapped")
    }
  }
}
