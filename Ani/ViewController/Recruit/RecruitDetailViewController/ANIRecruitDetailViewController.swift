//
//  ANIRecruitDetailViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/04/26.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import TinyConstraints

class ANIRecruitDetailViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var backButton: UIButton?
  private weak var clipButton: ANIImageButtonView?
  
  private weak var recruitDetailView: ANIRecruitDetailView?
  
  static let APPLY_BUTTON_HEIGHT: CGFloat = 45.0
  private weak var applyButton: ANIAreaButtonView?
  private weak var applyButtonLabel: UILabel?
  
  private var rejectViewBottomConstraint: Constraint?
  private var rejectViewBottomConstraintOriginalConstant: CGFloat?
  private weak var rejectView: ANIRejectView?
  private var isRejectAnimating: Bool = false
  private var rejectTapView: UIView?
  
  private var statusBarStyle: UIStatusBarStyle = .default
  
  var recruit: FirebaseRecruit?
  
  var user: FirebaseUser?
  
  private var isBack: Bool = false
  
  private var isClipped: Bool = false
  
  private var clipButtonColor = UIColor()

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    checkClipped()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    setupNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    removeNotifications()
  }
  
  private func setup() {
    //basic
    self.navigationController?.navigationBar.tintColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false
    UIApplication.shared.statusBarStyle = .lightContent

    //recruitDetailView
    let recruitDetailView = ANIRecruitDetailView()
    recruitDetailView.headerMinHeight = UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT
    recruitDetailView.delegate = self
    recruitDetailView.recruit = recruit
    recruitDetailView.user = user
    self.view.addSubview(recruitDetailView)
    recruitDetailView.edgesToSuperview()
    self.recruitDetailView = recruitDetailView
    
    //myNavigationBar
    let myNavigationBar = UIView()
    myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
    self.view.addSubview(myNavigationBar)
    myNavigationBar.topToSuperview()
    myNavigationBar.leftToSuperview()
    myNavigationBar.rightToSuperview()
    myNavigationBar.height(UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBar = myNavigationBar
    
    //backButton
    let backButton = UIButton()
    let backButtonImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate)
    backButton.setImage(backButtonImage, for: .normal)
    backButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    myNavigationBar.addSubview(backButton)
    backButton.width(44.0)
    backButton.height(44.0)
    backButton.leftToSuperview()
    backButton.bottomToSuperview()
    self.backButton = backButton
    
    //clipButton
    let clipButton = ANIImageButtonView()
    let clipButtonImage = UIImage(named: "clipButton")?.withRenderingMode(.alwaysTemplate)
    clipButton.image = clipButtonImage
    clipButton.delegate = self
    clipButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    myNavigationBar.addSubview(clipButton)
    clipButton.width(44.0)
    clipButton.height(44.0)
    clipButton.rightToSuperview()
    clipButton.bottomToSuperview()
    self.clipButton = clipButton
    
    //applyButton
    let applyButton = ANIAreaButtonView()
    applyButton.base?.backgroundColor = ANIColor.green
    applyButton.baseCornerRadius = ANIRecruitDetailViewController.APPLY_BUTTON_HEIGHT / 2
    applyButton.dropShadow(opacity: 0.2)
    applyButton.delegate = self
    self.view.addSubview(applyButton)
    applyButton.bottomToSuperview(offset: -10.0)
    applyButton.leftToSuperview(offset: 100.0)
    applyButton.rightToSuperview(offset: 100.0)
    applyButton.height(ANIRecruitDetailViewController.APPLY_BUTTON_HEIGHT)
    self.applyButton = applyButton
    
    //applyButtonLabel
    let applyButtonLabel = UILabel()
    applyButtonLabel.text = "お話ししたい"
    applyButtonLabel.textAlignment = .center
    applyButtonLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    applyButtonLabel.textColor = .white
    applyButton.addContent(applyButtonLabel)
    applyButtonLabel.edgesToSuperview()
    self.applyButtonLabel = applyButtonLabel
    
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
  
  private func presentImageBrowser(index: Int, imageUrls: [String]) {
    let imageBrowserViewController = ANIImageBrowserViewController()
    imageBrowserViewController.selectedIndex = index
    imageBrowserViewController.imageUrls = imageUrls
    imageBrowserViewController.modalPresentationStyle = .overCurrentContext
    imageBrowserViewController.delegate = self
    self.present(imageBrowserViewController, animated: false, completion: nil)
  }
  
  private func clip() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let clipButton = self.clipButton else { return }

    if !ANISessionManager.shared.isAnonymous {
      let database = Firestore.firestore()

      if !isClipped {
        DispatchQueue.global().async {
          database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_CLIP_IDS).document(currentUserId).setData([currentUserId: true])
          let date = ANIFunction.shared.getToday()
          database.collection(KEY_USERS).document(currentUserId).collection(KEY_CLIP_RECRUIT_IDS).document(recuritId).setData([KEY_DATE: date])

          DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15) {
              clipButton.tintColor = ANIColor.green
              self.isClipped = true
            }
          }
        }
      } else {
        DispatchQueue.global().async {
          database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_CLIP_IDS).document(currentUserId).delete()
          database.collection(KEY_USERS).document(currentUserId).collection(KEY_CLIP_RECRUIT_IDS).document(recuritId).delete()

          DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15) {
              clipButton.tintColor = self.clipButtonColor
              self.isClipped = false
            }
          }
        }
      }
    } else {
      self.reject()
    }
  }
  
  private func checkClipped() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUserId = ANISessionManager.shared.currentUserUid else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_CLIP_IDS).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          if document.documentID == currentUserId {
            self.isClipped = true
            UIView.animate(withDuration: 0.15) {
              self.clipButton?.tintColor = ANIColor.green
            }
          }
        }
      })
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
  
  //MARK: Action
  @objc private func back() {
    isBack = true
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc private func apply() {
    print("apply")
  }
  
  @objc private func rejectViewTapped() {
    let initialViewController = ANIInitialViewController()
    let navigationController = UINavigationController(rootViewController: initialViewController)
    self.present(navigationController, animated: true, completion: nil)
  }
}

//MARK: ANIRecruitDetailViewDelegate
extension ANIRecruitDetailViewController: ANIRecruitDetailViewDelegate {
  func recruitDetailViewDidScroll(offset: CGFloat) {
    guard let myNavigationBar = self.myNavigationBar,
          let backButton = self.backButton,
          let clipButton = self.clipButton,
          !isBack else { return }
    
    if offset > 1 {
      let backGroundColorOffset: CGFloat = 1.0
      let tintColorOffset = 1.0 - offset
      backButton.tintColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
      clipButtonColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
      if !isClipped {
        clipButton.tintColor = clipButtonColor
      }
      myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: backGroundColorOffset)
      UIApplication.shared.statusBarStyle = .default
      statusBarStyle = .default
    } else {
      let tintColorOffset = 1.0 - offset
      let ANIColorDarkBrightness: CGFloat = 0.18
      if tintColorOffset > ANIColorDarkBrightness {
        backButton.tintColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
        clipButtonColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
        if !isClipped {
          clipButton.tintColor = clipButtonColor
        }
      } else {
        backButton.tintColor = UIColor(hue: 0, saturation: 0, brightness: ANIColorDarkBrightness, alpha: 1)
        clipButtonColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
        if !isClipped {
          clipButton.tintColor = clipButtonColor
        }
      }
     
      myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
      UIApplication.shared.statusBarStyle = .lightContent
      statusBarStyle = .lightContent
    }
  }
  
  func imageCellTapped(index: Int, introduceImageUrls: [String]) {
    presentImageBrowser(index: index, imageUrls: introduceImageUrls)
  }
}

//MARK: ANIButtonViewDelegate
extension ANIRecruitDetailViewController: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === self.clipButton {
      clip()
    }
    if view === self.applyButton {      
      let chatViewController = ANIChatViewController()
      let navigationContoller = UINavigationController(rootViewController: chatViewController)
      chatViewController.user = user
      chatViewController.isPush = false
      chatViewController.delegate = self
      self.present(navigationContoller, animated: true, completion: nil)
    }
  }
}

//MARK: ANIImageBrowserViewControllerDelegate
extension ANIRecruitDetailViewController: ANIImageBrowserViewControllerDelegate {
  func imageBrowserDidDissmiss() {
    UIApplication.shared.statusBarStyle = statusBarStyle
  }
}

//MARK: ANIChatViewControllerDelegate
extension ANIRecruitDetailViewController: ANIChatViewControllerDelegate {
  func chatViewWillDismiss() {
    UIApplication.shared.statusBarStyle = statusBarStyle
  }
}
