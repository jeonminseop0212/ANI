//
//  ViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/02.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIRecruitViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBarTopConstroint: Constraint?

  private weak var categoriesView: ANIRecruitCategoriesView?
  static let CATEGORIES_VIEW_HEIGHT: CGFloat = 47.0
  
  private weak var recruitView: ANIRecuruitView?
  
  private weak var searchBar: UISearchBar?
  
  private let CONTRIBUTION_BUTTON_HEIGHT:CGFloat = 55.0
  private weak var contributionButon: ANIImageButtonView?
  
  private var testRecruitLists = [Recruit]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTestData()
    setup()
    setupNotifications()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
  }
  
  private func setup() {
    //basic
    Orientation.lockOrientation(.portrait)
    self.view.backgroundColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false
    
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
    recruitView.delegate = self
    recruitView.testRecruitLists = testRecruitLists
    self.view.addSubview(recruitView)
    recruitView.edgesToSuperview()
    self.recruitView = recruitView
    
    //myNavigationBar
    let myNavigationBar = UIView()
    myNavigationBar.backgroundColor = .white
    self.view.addSubview(myNavigationBar)
    myNavigationBarTopConstroint = myNavigationBar.topToSuperview()
    myNavigationBar.leftToSuperview()
    myNavigationBar.rightToSuperview()
    myNavigationBar.height(UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBar = myNavigationBar
    
    //searchBar
    let searchBar = UISearchBar()
    searchBar.placeholder = "Search"
    searchBar.textField?.backgroundColor = ANIColor.lightGray
    //    searchBar.showsCancelButton = true
    searchBar.delegate = self
    searchBar.backgroundImage = UIImage()
    myNavigationBar.addSubview(searchBar)
    searchBar.topToSuperview(offset: UIViewController.STATUS_BAR_HEIGHT)
    searchBar.leftToSuperview()
    searchBar.rightToSuperview()
    searchBar.bottomToSuperview()
    self.searchBar = searchBar
    
    //categoriesView
    let categoriesView = ANIRecruitCategoriesView()
    self.view.addSubview(categoriesView)
    categoriesView.topToBottom(of: myNavigationBar)
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
    contributionButon.width(CONTRIBUTION_BUTTON_HEIGHT)
    contributionButon.height(CONTRIBUTION_BUTTON_HEIGHT)
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
  
  private func setupTestData() {
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let recruit1 = Recruit(recruitImage: UIImage(named: "cat1")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお", user: user1, supportCount: 10, loveCount: 10)
    let recruit2 = Recruit(recruitImage: UIImage(named: "cat2")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user2, supportCount: 5, loveCount: 15)
    let recruit3 = Recruit(recruitImage: UIImage(named: "cat1")!, title: "かわいい猫ちゃんの里親になって >_<", subTitle: "あれこれ内容を書くところだよおおおおおおおお今は思い出せないから適当なものを描いてる明けだよおおおおおおおお", user: user3, supportCount: 10, loveCount: 10)
    self.testRecruitLists = [recruit1, recruit2, recruit3, recruit1, recruit2, recruit3]
  }
  
  //MARK: - Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(viewScrolled: self, selector: #selector(hideKeyboard))
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

extension ANIRecruitViewController: ANIRecruitViewDelegate {
  func recruitRowTap(tapRowIndex: Int) {
    let recruitDetailViewController = ANIRecruitDetailViewController()
    recruitDetailViewController.hidesBottomBarWhenPushed = true
    recruitDetailViewController.testRecruit = testRecruitLists[tapRowIndex]
    self.navigationController?.pushViewController(recruitDetailViewController, animated: true)
  }
  
  func recruitViewDidScroll(scrollY: CGFloat) {
    guard let myNavigationBarTopConstroint = self.myNavigationBarTopConstroint else { return }
    
    let topHeight = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT
    let newScrollY = topHeight + scrollY + UIViewController.STATUS_BAR_HEIGHT
    
    //navigation animate
    if topHeight < newScrollY {
      if scrollY + UIViewController.STATUS_BAR_HEIGHT < topHeight {
        myNavigationBarTopConstroint.constant = -scrollY - UIViewController.STATUS_BAR_HEIGHT
        self.view.layoutIfNeeded()
        
        let alpha = 1 - ((scrollY + UIViewController.STATUS_BAR_HEIGHT) / topHeight)
        searchBar?.alpha = alpha
        categoriesView?.categoryCollectionView?.alpha = alpha
      } else {
        myNavigationBarTopConstroint.constant = -topHeight
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
