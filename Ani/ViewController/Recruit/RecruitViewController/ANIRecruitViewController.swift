//
//  ViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/02.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

enum FilterPickMode: Int {
  case home;
  case kind;
  case age;
  case sex;
}

class ANIRecruitViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBarTopConstroint: Constraint?
  private weak var navigaitonTitleLabel: UILabel?

  private weak var filtersView: ANIRecruitFiltersView?
  static let FILTERS_VIEW_HEIGHT: CGFloat = 47.0
  
  private weak var recruitView: ANIRecuruitView?
  
  private let pickUpItem = PickUpItem()
  private var pickMode: FilterPickMode?
  
  private let CONTRIBUTION_BUTTON_HEIGHT:CGFloat = 55.0
  private weak var contributionButon: ANIImageButtonView?
  
  private var rejectViewBottomConstraint: Constraint?
  private var rejectViewBottomConstraintOriginalConstant: CGFloat?
  private weak var rejectView: ANIRejectView?
  private var isRejectAnimating: Bool = false
  private var rejectTapView: UIView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
    UIApplication.shared.isStatusBarHidden = false
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
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    
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
    
    //navigaitonTitleLabel
    let navigaitonTitleLabel = UILabel()
    navigaitonTitleLabel.text = "A N I"
    navigaitonTitleLabel.textColor = ANIColor.dark
    navigaitonTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
    myNavigationBar.addSubview(navigaitonTitleLabel)
    navigaitonTitleLabel.centerInSuperview()
    self.navigaitonTitleLabel = navigaitonTitleLabel
    
    //filtersView
    let filtersView = ANIRecruitFiltersView()
    filtersView.delegate = self
    self.view.addSubview(filtersView)
    filtersView.topToBottom(of: myNavigationBar)
    filtersView.leftToSuperview()
    filtersView.rightToSuperview()
    filtersView.height(ANIRecruitViewController.FILTERS_VIEW_HEIGHT)
    self.filtersView = filtersView
    
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
    ANINotificationManager.receive(profileImageViewTapped: self, selector: #selector(pushOtherProfile))
    ANINotificationManager.receive(pickerViewDidSelect: self, selector: #selector(updateFilter))
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
  
  @objc private func updateFilter(_ notification: NSNotification) {
    guard let pickMode = self.pickMode,
          let pickItem = notification.object as? String,
          let filtersView = self.filtersView,
          let recruitView = self.recruitView else { return }
    
    filtersView.pickMode = pickMode
    filtersView.pickItem = pickItem
    
    recruitView.pickMode = pickMode
    recruitView.pickItem = pickItem
  }
  
  //MARK: Action
  @objc private func rejectViewTapped() {
    let initialViewController = ANIInitialViewController()
    let navigationController = UINavigationController(rootViewController: initialViewController)
    self.present(navigationController, animated: true, completion: nil)
  }
}

//MARK: ButtonViewDelegate
extension ANIRecruitViewController:ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === self.contributionButon {
      if ANISessionManager.shared.isAnonymous == false {
        let recruitContribtionViewController = ANIRecruitContributionViewController()
        let recruitContributionNV = UINavigationController(rootViewController: recruitContribtionViewController)
        self.navigationController?.present(recruitContributionNV, animated: true, completion: nil)
      } else {
        reject()
      }
    }
  }
}

//ANIRecruitViewDelegate
extension ANIRecruitViewController: ANIRecruitViewDelegate {
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser) {
    let supportViewController = ANISupportViewController()
    supportViewController.modalPresentationStyle = .overCurrentContext
    supportViewController.recruit = supportRecruit
    supportViewController.user = user
    self.tabBarController?.present(supportViewController, animated: false, completion: nil)
  }
  
  func recruitCellTap(selectedRecruit: FirebaseRecruit, user: FirebaseUser) {
    let recruitDetailViewController = ANIRecruitDetailViewController()
    recruitDetailViewController.hidesBottomBarWhenPushed = true
    recruitDetailViewController.recruit = selectedRecruit
    recruitDetailViewController.user = user
    self.navigationController?.pushViewController(recruitDetailViewController, animated: true)
  }
  
  func recruitViewDidScroll(scrollY: CGFloat) {
    guard let myNavigationBarTopConstroint = self.myNavigationBarTopConstroint,
          let filtersView = self.filtersView,
          let filterCollectionView = filtersView.filterCollectionView,
          let navigaitonTitleLabel = self.navigaitonTitleLabel else { return }
    
    let topHeight = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.FILTERS_VIEW_HEIGHT
    let newScrollY = topHeight + scrollY
    
    //navigation animate
    if topHeight < newScrollY {
      if scrollY < topHeight {
        myNavigationBarTopConstroint.constant = -scrollY
        self.view.layoutIfNeeded()
        
        let alpha = 1 - (scrollY / topHeight)
        navigaitonTitleLabel.alpha = alpha * alpha
        filterCollectionView.alpha = alpha * alpha
      } else {
        myNavigationBarTopConstroint.constant = -topHeight
        navigaitonTitleLabel.alpha = 0.0
        filterCollectionView.alpha = 0.0
        self.view.layoutIfNeeded()
      }
    } else {
      myNavigationBarTopConstroint.constant = 0.0
      self.view.layoutIfNeeded()
      
      navigaitonTitleLabel.alpha = 1.0
      filterCollectionView.alpha = 1.0
    }
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
}

//MARK: ANIRecruitFiltersViewDelegate
extension ANIRecruitViewController: ANIRecruitFiltersViewDelegate {
  func didSelectedItem(index: Int) {
    let popupPickerViewController = ANIPopupPickerViewController()

    switch index {
    case FilterPickMode.home.rawValue:
      var home = pickUpItem.home
      home.insert("選択しない", at: 0)
      pickMode = .home
      
      popupPickerViewController.pickerItem = home
    case FilterPickMode.kind.rawValue:
      var kind = pickUpItem.kind
      kind.insert("選択しない", at: 0)
      pickMode = .kind
      
      popupPickerViewController.pickerItem = kind
    case FilterPickMode.age.rawValue:
      var age = pickUpItem.age
      age.insert("選択しない", at: 0)
      pickMode = .age
      
      popupPickerViewController.pickerItem = age
    case FilterPickMode.sex.rawValue:
      var sex = pickUpItem.sex
      sex.insert("選択しない", at: 0)
      pickMode = .sex
      
      popupPickerViewController.pickerItem = sex
    default:
      DLog("filter default")
    }
    
    popupPickerViewController.modalPresentationStyle = .overCurrentContext
    self.tabBarController?.present(popupPickerViewController, animated: false, completion: nil)
  }
}

//MARK: UIGestureRecognizerDelegate
extension ANIRecruitViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
