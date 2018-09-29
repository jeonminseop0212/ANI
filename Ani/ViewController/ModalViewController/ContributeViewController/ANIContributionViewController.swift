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
import FirebaseStorage
import FirebaseFirestore
import CodableFirebase
import InstantSearchClient

enum ContributionMode {
  case story
  case qna
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
    
  private var contentImages = [UIImage?]() {
    didSet {
      guard let contriButionView = self.contriButionView else { return }
      
      contriButionView.contentImages = contentImages
    }
  }
  
  private let IMAGE_SIZE: CGSize = CGSize(width: 500.0, height: 500.0)
  
  override func viewDidLoad() {
    setup()
    setupImagePickGalleryController()
    setupNotification()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.isStatusBarHidden = false
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
    contributionButtonBG.alpha = 0.5
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
    contributionButton.isEnabled = false
    contributionButtonBG.addSubview(contributionButton)
    contributionButton.centerInSuperview()
    contributionButton.size(to: contributionButtonBG)
    self.contributionButton = contributionButton
    
    //contriButionView
    let contriButionView = ANIContributionView()
    contriButionView.selectedContributionMode = selectedContributionMode
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
    Gallery.Config.Camera.imageLimit = 10
    Gallery.Config.tabsToShow = [.imageTab, .cameraTab]
    Gallery.Config.Font.Main.regular = UIFont.boldSystemFont(ofSize: 17)
    Gallery.Config.Grid.ArrowButton.tintColor = ANIColor.dark
    Gallery.Config.Grid.FrameView.borderColor = ANIColor.green
    Gallery.Config.Grid.previewRatio = 1.0
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(keyboardWillChangeFrame: self, selector: #selector(keyboardWillChangeFrame))
    ANINotificationManager.receive(keyboardWillHide: self, selector: #selector(keyboardWillHide))
  }
  
  func uploadStory() {
    guard let contriButionView = self.contriButionView,
          let currentUser = ANISessionManager.shared.currentUser,
          let uid = currentUser.uid else { return }
    
    let storageRef = Storage.storage().reference()
    var contentImageUrls = [Int: String]()
    
    DispatchQueue.global().async {
      for (index, contentImage) in self.contentImages.enumerated() {
        if let contentImage = contentImage, let contentImageData = contentImage.jpegData(compressionQuality: 0.5) {
          let uuid = UUID().uuidString
          storageRef.child(KEY_STORY_IMAGES).child(uuid).putData(contentImageData, metadata: nil) { (metaData, error) in
            if error != nil {
              DLog("storageError")
              return
            }
            
            if let contentImageUrl = metaData?.downloadURL() {
              contentImageUrls[index] = contentImageUrl.absoluteString
              if contentImageUrls.count == self.contentImages.count {
                let sortdUrls = contentImageUrls.sorted(by: {$0.0 < $1.0})
                var urls = [String]()
                for url in sortdUrls {
                  urls.append(url.value)
                }
                
                DispatchQueue.main.async {
                  let id = NSUUID().uuidString
                  let date = ANIFunction.shared.getToday()
                  let content = contriButionView.getContent()
                  let story = FirebaseStory(id: id, storyImageUrls: urls, story: content, userId: uid, loveIds: nil, commentIds: nil, recruitId: nil, recruitTitle: nil, recruitSubTitle: nil, date: date, isLoved: nil)
                
                  self.upateStroyDatabase(story: story, id: id)
                }
              }
            }
          }
        }
      }
    }
  }
  
  func uploadQna() {
    guard let contriButionView = self.contriButionView,
          let currentUser = ANISessionManager.shared.currentUser,
          let uid = currentUser.uid else { return }
    
    let storageRef = Storage.storage().reference()
    var contentImageUrls = [Int: String]()
    
    DispatchQueue.global().async {
      if self.contentImages.isEmpty {
        DispatchQueue.main.async {
          let id = NSUUID().uuidString
          let date = ANIFunction.shared.getToday()
          let content = contriButionView.getContent()
          let qna = FirebaseQna(id: id, qnaImageUrls: nil, qna: content, userId: uid, loveIds: nil, commentIds: nil, date: date, isLoved: nil)
        
          self.upateQnaDatabase(qna: qna, id: id)
        }
      } else {
        for (index, contentImage) in self.contentImages.enumerated() {
          if let contentImage = contentImage, let contentImageData = contentImage.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            storageRef.child(KEY_QNA_IMAGES).child(uuid).putData(contentImageData, metadata: nil) { (metaData, error) in
              if error != nil {
                DLog("storageError")
                return
              }
              
              if let contentImageUrl = metaData?.downloadURL() {
                contentImageUrls[index] = contentImageUrl.absoluteString
                if contentImageUrls.count == self.contentImages.count {
                  let sortdUrls = contentImageUrls.sorted(by: {$0.0 < $1.0})
                  var urls = [String]()
                  for url in sortdUrls {
                    urls.append(url.value)
                  }
                  
                  DispatchQueue.main.async {
                    let id = NSUUID().uuidString
                    let date = ANIFunction.shared.getToday()
                    let content = contriButionView.getContent()
                    let qna = FirebaseQna(id: id, qnaImageUrls: urls, qna: content, userId: uid, loveIds: nil, commentIds: nil, date: date, isLoved: nil)
                  
                    self.upateQnaDatabase(qna: qna, id: id)
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  
  private func upateStroyDatabase(story: FirebaseStory, id: String) {
    do {
      let database = Firestore.firestore()

      let data = try FirestoreEncoder().encode(story)
      database.collection(KEY_STORIES).document(id).setData(data) { error in
        if let error = error {
          DLog("Error set document: \(error)")
          return
        }
        
        self.pushDataAlgolia(data: data as [String : AnyObject])
      }
    } catch let error {
      DLog(error)
    }
  }
  
  private func upateQnaDatabase(qna: FirebaseQna, id: String) {
    do {
      let database = Firestore.firestore()

      let data = try FirestoreEncoder().encode(qna)
      database.collection(KEY_QNAS).document(id).setData(data) { error in
        if let error = error {
          DLog("Error set document: \(error)")
          return
        }
        
        self.pushDataAlgolia(data: data as [String : AnyObject])
      }
    } catch let error {
      DLog(error)
    }
  }
  
  private func pushDataAlgolia(data: [String: AnyObject]) {
    guard let selectedContributionMode = self.selectedContributionMode else { return }
    
    var index: Index?
    switch selectedContributionMode {
    case .story:
      index = ANISessionManager.shared.client.index(withName: KEY_STORIES_INDEX)
    case .qna:
      index = ANISessionManager.shared.client.index(withName: KEY_QNAS_INDEX)
    }
    
    var newData = data
    if let objectId = data[KEY_ID] {
      newData.updateValue(objectId, forKey: KEY_OBJECT_ID)
    }
    
    DispatchQueue.global().async {
      index?.addObject(newData, completionHandler: { (content, error) -> Void in
        if error == nil {
          DLog("Object IDs: \(content!)")
        }
      })
    }
  }
  
  private func contentImagesPick(animation: Bool) {
    let imagePickgalleryNV = UINavigationController(rootViewController: imagePickGallery)
    present(imagePickgalleryNV, animated: animation, completion: nil)
  }
  
  private func getCropImages(images: [UIImage?], items: [Image]) -> [UIImage] {
    var croppedImages = [UIImage]()
    
    for (index, image) in images.enumerated() {
      if let image = image {
        let imageSize = image.size
        let scrollViewWidth = self.view.frame.width
        let widthScale =  scrollViewWidth / imageSize.width * items[index].scale
        let heightScale = scrollViewWidth / imageSize.height * items[index].scale

        let scale = 1 / min(widthScale, heightScale)
        
        let visibleRect = CGRect(x: floor(items[index].offset.x * scale), y: floor(items[index].offset.y * scale), width: scrollViewWidth * scale, height: scrollViewWidth * scale * Config.Grid.previewRatio)
        let ref: CGImage = (image.cgImage?.cropping(to: visibleRect))!
        let croppedImage:UIImage = UIImage(cgImage: ref)
        
        croppedImages.append(croppedImage)
      }
    }
    return croppedImages
  }
  
  @objc private func keyboardWillChangeFrame(_ notification: Notification) {
    guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
          let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
          let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
          let contributionViewBottomConstraint = self.contributionViewBottomConstraint else { return }
    
    let h = keyboardFrame.height
    
    contributionViewBottomConstraint.constant = -h
    
    UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
          let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
          let contributionViewOriginalBottomConstraintConstant = self.contributionViewOriginalBottomConstraintConstant,
          let contributionViewBottomConstraint = self.contributionViewBottomConstraint else { return }
    
    contributionViewBottomConstraint.constant = contributionViewOriginalBottomConstraintConstant
    
    UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  //MARK: action
  @objc private func contributeDismiss() {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @objc private func contribute() {
    guard let selectedContributionMode = self.selectedContributionMode else { return }
    
    self.view.endEditing(true)
    
    switch selectedContributionMode {
    case .story:
      uploadStory()
      
      self.dismiss(animated: true, completion: nil)
    case .qna:
      uploadQna()
      
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
    guard !filteredImages.isEmpty else { return }
    
    contentImages.removeAll()
    for filteredImage in filteredImages {
      contentImages.append(filteredImage?.resize(size: IMAGE_SIZE))
    }
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
  
  func contributionButtonOn(on: Bool) {
    guard let contributionButton = self.contributionButton,
          let contributionButtonBG = self.contributionButtonBG else { return }
    if on {
      contributionButton.isEnabled = true
      contributionButtonBG.alpha = 1.0
    } else {
      contributionButton.isEnabled = false
      contributionButtonBG.alpha = 0.5
    }
  }
}
