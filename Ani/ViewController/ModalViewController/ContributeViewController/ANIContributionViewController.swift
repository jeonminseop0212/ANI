//
//  ANIContributeViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import Gallery
import TinyConstraints

enum ContributionMode {
  case story
  case qna
}

protocol ANIContributionViewControllerDelegate {
  func contributionButtonTapped(story: Story)
  func contributionButtonTapped(qna: Qna)
}

class ANIContributionViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBarBase: UIView?
  private weak var dismissButton: UIButton?
  private weak var titleLabel: UILabel?
  private weak var contributionButtonBG: UIView?
  private weak var contributionButton: UIButton?
  
  private var contributionViewOriginalBottomConstraintConstant: CGFloat?
  private var contributionViewBottomConstraint: Constraint?
  private weak var contriButionView: ANIContributionView?
  
  private var imagePickGallery = GalleryController()
  
  var navigationTitle: String?
  
  var selectedContributionMode: ContributionMode?
  
  var delegate: ANIContributionViewControllerDelegate?

  override func viewDidLoad() {
    setup()
    setupImagePickGalleryController()
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
    
    //myNavigationBarBase
    let myNavigationBarBase = UIView()
    myNavigationBar.addSubview(myNavigationBarBase)
    myNavigationBarBase.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    myNavigationBarBase.bottomToSuperview()
    myNavigationBarBase.leftToSuperview()
    myNavigationBarBase.rightToSuperview()
    self.myNavigationBarBase = myNavigationBarBase
    
    //dismissButton
    let dismissButton = UIButton()
    let dismissButtonImage = UIImage(named: "dismissButton")?.withRenderingMode(.alwaysTemplate)
    dismissButton.setImage(dismissButtonImage, for: .normal)
    dismissButton.tintColor = ANIColor.dark
    dismissButton.addTarget(self, action: #selector(contributeDismiss), for: .touchUpInside)
    myNavigationBarBase.addSubview(dismissButton)
    dismissButton.width(UIViewController.NAVIGATION_BAR_HEIGHT)
    dismissButton.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    dismissButton.leftToSuperview()
    dismissButton.centerYToSuperview()
    self.dismissButton = dismissButton
    
    //titleLabel
    let titleLabel = UILabel()
    titleLabel.text = navigationTitle
    titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    titleLabel.textColor = ANIColor.dark
    myNavigationBarBase.addSubview(titleLabel)
    titleLabel.centerInSuperview()
    self.titleLabel = titleLabel
    
    //contributionButtonBG
    let contributionButtonBG = UIView()
    contributionButtonBG.layer.cornerRadius = (UIViewController.NAVIGATION_BAR_HEIGHT - 10.0) / 2
    contributionButtonBG.layer.masksToBounds = true
    contributionButtonBG.backgroundColor = ANIColor.green
    myNavigationBarBase.addSubview(contributionButtonBG)
    contributionButtonBG.centerYToSuperview()
    contributionButtonBG.rightToSuperview(offset: 10.0)
    contributionButtonBG.width(70.0)
    contributionButtonBG.height(UIViewController.NAVIGATION_BAR_HEIGHT - 10.0)
    self.contributionButtonBG = contributionButtonBG
    
    //contributionButton
    let contributionButton = UIButton()
    contributionButton.setTitle("投稿", for: .normal)
    contributionButton.setTitleColor(.white, for: .normal)
    contributionButton.addTarget(self, action: #selector(contribute), for: .touchUpInside)
    contributionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
    contributionButtonBG.addSubview(contributionButton)
    contributionButton.centerInSuperview()
    contributionButton.size(to: contributionButtonBG)
    self.contributionButton = contributionButton
    
    //contriButionView
    let contriButionView = ANIContributionView()
    contriButionView.delegate = self
    self.view.addSubview(contriButionView)
    contriButionView.topToBottom(of: myNavigationBar)
    contriButionView.leftToSuperview()
    contriButionView.rightToSuperview()
    contributionViewBottomConstraint = contriButionView.bottomToSuperview()
    contributionViewOriginalBottomConstraintConstant = contributionViewBottomConstraint?.constant
    self.contriButionView = contriButionView
  }
  
  private func setupImagePickGalleryController() {
    imagePickGallery.delegate = self
    Gallery.Config.initialTab = .imageTab
    Gallery.Config.PageIndicator.backgroundColor = .white
    Gallery.Config.Camera.oneImageMode = false
    Config.Camera.imageLimit = 10
    Gallery.Config.Font.Main.regular = UIFont.boldSystemFont(ofSize: 17)
    Gallery.Config.Grid.ArrowButton.tintColor = ANIColor.dark
    Gallery.Config.Grid.FrameView.borderColor = ANIColor.green
    Gallery.Config.Grid.previewRatio = 1.0
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(keyboardWillChangeFrame: self, selector: #selector(keyboardWillChangeFrame))
    ANINotificationManager.receive(keyboardWillHide: self, selector: #selector(keyboardWillHide))
  }
  
  private func contentImagesPick(animation: Bool) {
    let imagePickgalleryNV = UINavigationController(rootViewController: imagePickGallery)
    present(imagePickgalleryNV, animated: animation, completion: nil)
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
          let contributionViewBottomConstraint = self.contributionViewBottomConstraint else { return }
    
    let h = keyboardFrame.height
    
    contributionViewBottomConstraint.constant = -h
    
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
          let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
          let contributionViewOriginalBottomConstraintConstant = self.contributionViewOriginalBottomConstraintConstant,
          let contributionViewBottomConstraint = self.contributionViewBottomConstraint else { return }
    
    contributionViewBottomConstraint.constant = contributionViewOriginalBottomConstraintConstant
    
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  //MARK: action
  @objc private func contributeDismiss() {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @objc private func contribute() {
    guard let selectedContributionMode = self.selectedContributionMode,
          let contriButionView = self.contriButionView,
          let contentTextView = contriButionView.contentTextView else { return }
    
    switch selectedContributionMode {
    case ContributionMode.story:
      let user = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")

      let story = Story(storyImages: contriButionView.contentImages, story: contentTextView.text, user: user, loveCount: 0, commentCount: 0)
      self.delegate?.contributionButtonTapped(story: story)
      
      self.dismiss(animated: true, completion: nil)
    case ContributionMode.qna:
      let user = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")

      let qna = Qna(qnaImages: contriButionView.contentImages, subTitle: contentTextView.text, user: user, loveCount: 0, commentCount: 0)
      self.delegate?.contributionButtonTapped(qna: qna)
      
      self.dismiss(animated: true, completion: nil)
    }
  }
}

//MARK: GalleryControllerDelegate
extension ANIContributionViewController: GalleryControllerDelegate {
  func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
    
    Image.resolve(images: images) { (myImages) in
      let imageFilteriewController = ANIImageFilterViewController()
      imageFilteriewController.images = self.getCropImages(images: myImages, items: images)
      imageFilteriewController.delegate = self
      controller.navigationController?.pushViewController(imageFilteriewController, animated: true)
    }
  }
  
  func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
    controller.dismiss(animated: true, completion: nil)
  }
  
  func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
    controller.dismiss(animated: true, completion: nil)
  }
  
  func galleryControllerDidCancel(_ controller: GalleryController) {
    controller.dismiss(animated: true, completion: nil)
  }
}

//MARK: ANIImageFilterViewControllerDelegate
extension ANIContributionViewController: ANIImageFilterViewControllerDelegate {
  func doneFilterImages(filteredImages: [UIImage?]) {
    guard let contriButionView = self.contriButionView,
          !filteredImages.isEmpty else { return }
    
    contriButionView.contentImages = filteredImages
  }
}

//MARK: ANIContributionViewDelegate
extension ANIContributionViewController: ANIContributionViewDelegate {
  func imagesPickCellTapped() {
    contentImagesPick(animation: true)
  }
  
  func imageDeleteButtonTapped(index: Int) {
    imagePickGallery.cart.images.remove(at: index)
  }
}
