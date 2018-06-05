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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    setupNotifications()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
    UIApplication.shared.isStatusBarHidden = false
  }
  
  private func setup() {
    //basic
    ANIOrientation.lockOrientation(.portrait)
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
    self.view.addSubview(recruitView)
    recruitView.topToSuperview(usingSafeArea: true)
    recruitView.edgesToSuperview(excluding: .top)
    self.recruitView = recruitView
    
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
    myNavigationBar.addSubview(searchBar)
    searchBar.topToSuperview()
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
    contributionButon.width(CONTRIBUTION_BUTTON_HEIGHT)
    contributionButon.height(CONTRIBUTION_BUTTON_HEIGHT)
    contributionButon.rightToSuperview(offset: 15.0)
    contributionButon.bottomToSuperview(offset: -15, usingSafeArea: true)
    self.contributionButon = contributionButon
  }
  
  //MARK: Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(viewScrolled: self, selector: #selector(hideKeyboard))
  }
  
  //MARK: Action
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

//MARK: ButtonViewDelegate
extension ANIRecruitViewController:ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === self.contributionButon {
      let recruitContribtionViewController = ANIRecruitContributionViewController()
      let recruitContributionNV = UINavigationController(rootViewController: recruitContribtionViewController)
      self.navigationController?.present(recruitContributionNV, animated: true, completion: nil)
    }
  }
}

//ANIRecruitViewDelegate
extension ANIRecruitViewController: ANIRecruitViewDelegate {
  func recruitRowTap(selectedRecruit: FirebaseRecruit) {
    let recruitDetailViewController = ANIRecruitDetailViewController()
    recruitDetailViewController.hidesBottomBarWhenPushed = true
    recruitDetailViewController.recruit = selectedRecruit
    self.navigationController?.pushViewController(recruitDetailViewController, animated: true)
  }
  
  func recruitViewDidScroll(scrollY: CGFloat) {
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
