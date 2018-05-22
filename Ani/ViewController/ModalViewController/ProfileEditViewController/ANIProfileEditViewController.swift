//
//  ProfileEditViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import Gallery
import TinyConstraints

class ANIProfileEditViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBase: UIView?
  private weak var backButton: UIButton?
  private weak var navigationTitleLabel: UILabel?
  private weak var editButtonBG: UIView?
  private weak var editButton: UIButton?
  
  private var profileEditViewOriginalBottomConstraintConstant: CGFloat?
  private var profileEditViewBottomConstraint: Constraint?
  private weak var profileEditView: ANIProfileEditView?
  
  private var gallery: GalleryController?
  
  private var editImageIndex: Int?
  
  var user: User? {
    didSet {
      guard let profileEditView = self.profileEditView else { return }
      
      profileEditView.user = user
    }
  }
  
  private var isFamilyAdd: Bool = false
  
  override func viewDidLoad() {
    setup()
    setupNotification()
  }
  
  private func setup() {
    //basic
    self.view.backgroundColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false
    
    //myNavigationBar
    let myNavigationBar = UIView()
    myNavigationBar.backgroundColor = .white
    self.view.addSubview(myNavigationBar)
    myNavigationBar.topToSuperview()
    myNavigationBar.leftToSuperview()
    myNavigationBar.rightToSuperview()
    myNavigationBar.height(UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBar = myNavigationBar
    
    //myNavigationBase
    let myNavigationBase = UIView()
    myNavigationBar.addSubview(myNavigationBase)
    myNavigationBase.edgesToSuperview(excluding: .top)
    myNavigationBase.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBase = myNavigationBase
    
    //backButton
    let backButton = UIButton()
    let backButtonImage = UIImage(named: "dismissButton")?.withRenderingMode(.alwaysTemplate)
    backButton.setImage(backButtonImage, for: .normal)
    backButton.tintColor = ANIColor.dark
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    myNavigationBase.addSubview(backButton)
    backButton.width(44.0)
    backButton.height(44.0)
    backButton.leftToSuperview()
    backButton.centerYToSuperview()
    self.backButton = backButton
    
    //navigationTitleLabel
    let navigationTitleLabel = UILabel()
    navigationTitleLabel.text = "プロフィール設定"
    navigationTitleLabel.textColor = ANIColor.dark
    navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    myNavigationBase.addSubview(navigationTitleLabel)
    navigationTitleLabel.centerInSuperview()
    self.navigationTitleLabel = navigationTitleLabel
    
    //editButtonBG
    let editButtonBG = UIView()
    editButtonBG.layer.cornerRadius = (UIViewController.NAVIGATION_BAR_HEIGHT - 10.0) / 2
    editButtonBG.layer.masksToBounds = true
    editButtonBG.backgroundColor = ANIColor.green
    editButtonBG.alpha = 1.0
    myNavigationBase.addSubview(editButtonBG)
    editButtonBG.centerYToSuperview()
    editButtonBG.rightToSuperview(offset: 10.0)
    editButtonBG.width(70.0)
    editButtonBG.height(UIViewController.NAVIGATION_BAR_HEIGHT - 10.0)
    self.editButtonBG = editButtonBG
    
    //editButton
    let editButton = UIButton()
    editButton.setTitle("設定", for: .normal)
    editButton.setTitleColor(.white, for: .normal)
    editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)
    editButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
    editButton.isEnabled = true
    editButtonBG.addSubview(editButton)
    editButton.centerInSuperview()
    editButton.size(to: editButtonBG)
    self.editButton = editButton
    
    //profileEditView
    let profileEditView = ANIProfileEditView()
    profileEditView.delegate = self
    if let user = self.user {
      profileEditView.user = user
    }
    self.view.addSubview(profileEditView)
    profileEditView.leftToSuperview()
    profileEditView.rightToSuperview()
    profileEditViewBottomConstraint = profileEditView.bottomToSuperview()
    profileEditViewOriginalBottomConstraintConstant = profileEditViewBottomConstraint?.constant
    profileEditView.topToBottom(of: myNavigationBar)
    self.profileEditView = profileEditView
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(keyboardWillChangeFrame: self, selector: #selector(keyboardWillChangeFrame))
    ANINotificationManager.receive(keyboardWillHide: self, selector: #selector(keyboardWillHide))
  }
  
  func getCropImages(images: [UIImage?], items: [Image]) -> [UIImage] {
    var croppedImages = [UIImage]()
    
    for (index, image) in images.enumerated() {
      let imageSize = image?.size
      let scrollViewWidth = self.view.frame.width
      let widthScale =  scrollViewWidth / (imageSize?.width)! * items[index].scale
      let heightScale = scrollViewWidth / (imageSize?.height)! * items[index].scale
      
      let scale = 1 / min(widthScale, heightScale)
      let visibleRect = CGRect(x: items[index].offset.x * scale, y: items[index].offset.y * scale, width: scrollViewWidth * scale, height: scrollViewWidth * scale * Config.Grid.previewRatio)
      let ref: CGImage = (image?.cgImage?.cropping(to: visibleRect))!
      let croppedImage:UIImage = UIImage(cgImage: ref)
      
      croppedImages.append(croppedImage)
    }
    return croppedImages
  }
  
  @objc private func keyboardWillChangeFrame(_ notification: Notification) {
    guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
          let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
          let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
          let profileEditViewBottomConstraint = self.profileEditViewBottomConstraint else { return }
    
    let h = keyboardFrame.height
    
    profileEditViewBottomConstraint.constant = -h
    
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
          let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
          let profileEditViewOriginalBottomConstraintConstant = self.profileEditViewOriginalBottomConstraintConstant,
          let profileEditViewBottomConstraint = self.profileEditViewBottomConstraint else { return }
    
    profileEditViewBottomConstraint.constant = profileEditViewOriginalBottomConstraintConstant
    
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  //MARK: Action
  @objc private func back() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc private func edit() {
    //TODO: update user server
    self.dismiss(animated: true, completion: nil)
  }
}

//MARK: ANIProfileEditViewDelegate
extension ANIProfileEditViewController: ANIProfileEditViewDelegate {
  func kindSelectButtonTapped() {
    let popupPickerViewController = ANIPopupPickerViewController()
    popupPickerViewController.pickerItem = ["個人", "団体"]
    popupPickerViewController.modalPresentationStyle = .overCurrentContext
    present(popupPickerViewController, animated: false, completion: nil)
  }
  
  func editButtonEnable(enable: Bool) {
    guard let editButton = self.editButton,
          let editButtonBG = self.editButtonBG else { return }
    
    if enable {
      editButton.isEnabled = true
      editButtonBG.alpha = 1.0
    } else {
      editButton.isEnabled = false
      editButtonBG.alpha = 0.5
    }
  }
  
  func imagePickerCellTapped() {
    gallery = GalleryController()
    if let galleryUnrap = gallery {
      galleryUnrap.delegate = self
      Gallery.Config.initialTab = .imageTab
      Gallery.Config.PageIndicator.backgroundColor = .white
      Gallery.Config.Camera.oneImageMode = true
      if Gallery.Config.Camera.oneImageMode {
        Gallery.Config.Grid.previewRatio = UIViewController.HEADER_IMAGE_VIEW_RATIO
        Config.tabsToShow = [.imageTab, .cameraTab]
      }
      Gallery.Config.Font.Main.regular = UIFont.boldSystemFont(ofSize: 17)
      Gallery.Config.Grid.ArrowButton.tintColor = ANIColor.dark
      Gallery.Config.Grid.FrameView.borderColor = ANIColor.green
      Gallery.Config.Grid.previewRatio = 1.0
      
      let galleryNV = UINavigationController(rootViewController: galleryUnrap)
      self.present(galleryNV, animated: true, completion: nil)
      
      isFamilyAdd = true
    }
  }
  
  func imageEditCellTapped(index: Int) {
    gallery = GalleryController()
    if let galleryUnrap = gallery {
      galleryUnrap.delegate = self
      Gallery.Config.initialTab = .imageTab
      Gallery.Config.PageIndicator.backgroundColor = .white
      Gallery.Config.Camera.oneImageMode = true
      if Gallery.Config.Camera.oneImageMode {
        Gallery.Config.Grid.previewRatio = UIViewController.HEADER_IMAGE_VIEW_RATIO
        Config.tabsToShow = [.imageTab, .cameraTab]
      }
      Gallery.Config.Font.Main.regular = UIFont.boldSystemFont(ofSize: 17)
      Gallery.Config.Grid.ArrowButton.tintColor = ANIColor.dark
      Gallery.Config.Grid.FrameView.borderColor = ANIColor.green
      Gallery.Config.Grid.previewRatio = 1.0
      
      let galleryNV = UINavigationController(rootViewController: galleryUnrap)
      self.present(galleryNV, animated: true, completion: nil)
      
      isFamilyAdd = false
      editImageIndex = index
    }
  }
}

//MARK: GalleryControllerDelegate
extension ANIProfileEditViewController: GalleryControllerDelegate {
  func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
    
    Image.resolve(images: images) { (myImages) in
      let imageFilteriewController = ANIImageFilterViewController()
      imageFilteriewController.images = self.getCropImages(images: myImages, items: images)
      imageFilteriewController.delegate = self
      controller.navigationController?.pushViewController(imageFilteriewController, animated: true)
    }
    
    gallery = nil
  }
  
  func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
    controller.dismiss(animated: true, completion: nil)
    
    gallery = nil
  }
  
  func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
  }
  
  func galleryControllerDidCancel(_ controller: GalleryController) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
  }
}

//MARK: ANIImageFilterViewControllerDelegate
extension ANIProfileEditViewController: ANIImageFilterViewControllerDelegate {
  func doneFilterImages(filteredImages: [UIImage?]) {
    guard !filteredImages.isEmpty,
          let filteredImage = filteredImages[0],
          let user = self.user else { return }
    
    if isFamilyAdd {
      var userTemp = user
      userTemp.familyImages.append(filteredImage)
      self.user = userTemp
    } else if let editImageIndex = self.editImageIndex {
      var userTemp = user
      userTemp.familyImages[editImageIndex] = filteredImage
      self.user = userTemp
    }
  }
}
