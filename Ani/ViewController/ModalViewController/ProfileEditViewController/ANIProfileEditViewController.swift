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
import FirebaseFirestore
import FirebaseStorage
import CodableFirebase
import NVActivityIndicatorView

protocol ANIProfileEditViewControllerDelegate {
  func didEdit()
}

class ANIProfileEditViewController: UIViewController, NVActivityIndicatorViewable {
  
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
  
  var currentUser: FirebaseUser?
  
  private var isFamilyAdd: Bool = false
  
  var profileImage: UIImage? {
    didSet {
      guard let profileEditView = self.profileEditView,
            let profileImage = self.profileImage else { return }
      profileEditView.profileImage = profileImage
    }
  }
  
  var familyImages: [UIImage?]? {
    didSet {
      guard let profileEditView = self.profileEditView,
            let familyImages = self.familyImages else { return }
      profileEditView.familyImages = familyImages
    }
  }
  
  private var familyImagesChange: Bool = false
  
  private let IMAGE_SIZE: CGSize = CGSize(width: 500.0, height: 500.0)
  
  var delegate: ANIProfileEditViewControllerDelegate?
  
  override func viewDidLoad() {
    setFamilyImages { (images) in
      self.familyImages = images
    }
    setup()
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
    profileEditView.currentUser = currentUser
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
  
  private func getCropImages(images: [UIImage?], items: [Image]) -> [UIImage] {
    var croppedImages = [UIImage]()
    
    for (index, image) in images.enumerated() {
      let imageSize = image?.size
      let scrollViewWidth = self.view.frame.width
      let widthScale =  scrollViewWidth / (imageSize?.width)! * items[index].scale
      let heightScale = scrollViewWidth / (imageSize?.height)! * items[index].scale
      
      let scale = 1 / min(widthScale, heightScale)
      let visibleRect = CGRect(x: floor(items[index].offset.x * scale), y: floor(items[index].offset.y * scale), width: scrollViewWidth * scale, height: scrollViewWidth * scale * Config.Grid.previewRatio)
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
  
  private func updateUserData(uid: String, values: [String: AnyObject]) {
    let database = Firestore.firestore()
    database.collection(KEY_USERS).document(uid).updateData(values) { (error) in
      if let error = error {
        print("update user error \(error)")
      }
      
      self.pushDataAlgolia(data: values)
      
      database.collection(KEY_USERS).document(uid).getDocument { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          let user = try FirestoreDecoder().decode(FirebaseUser.self, from: data)
          ANISessionManager.shared.currentUser = user
          
          NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
          
          self.delegate?.didEdit()
          self.dismiss(animated: true, completion: nil)
        } catch let error {
          print(error)
        }
      }
    }
  }
  
  private func pushDataAlgolia(data: [String: AnyObject]) {
    guard let objectId = ANISessionManager.shared.currentUserUid else { return }
    
    let index = ANISessionManager.shared.client.index(withName: KEY_USERS_INDEX)
    
    var newData = data
    newData.updateValue(objectId as AnyObject, forKey: KEY_OBJECT_ID)
    
    DispatchQueue.global().async {
      index.saveObject(newData, completionHandler: { (content, error) -> Void in
        if error == nil {
          print("Object IDs: \(content!)")
        }
      })
    }
  }
  
  private func deleteFamilyImages(urls: [String]) {
    for url in urls {
      let storage = Storage.storage()
      let storageRef = storage.reference(forURL: url)
      
      storageRef.delete { error in
        if let error = error {
          print(error)
        }
      }
    }
  }
  
  private func setFamilyImages(completion:((_ images :[UIImage])->())? = nil) {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let familyImageUrls = currentUser.familyImageUrls else { return }
    
    var images = [Int: UIImage]()
    for (index, familyImageUrl) in familyImageUrls.enumerated() {
      if let url = URL(string: familyImageUrl) {
        DispatchQueue.global().async {
          if let data = try? Data(contentsOf: url) {
            let image = UIImage(data: data)
            images[index] = image
            
            let sortdImages = images.sorted(by: {$0.0 < $1.0})
            if sortdImages.count == familyImageUrls.count {
              var uiImages = [UIImage]()
              for image in sortdImages {
                uiImages.append(image.value)
              }
              DispatchQueue.main.async {
                completion?(uiImages)
              }
            }
          }
        }
      }
    }
  }
  
  private func setFamilyImageUrls(completion:((_ urls :[String])->())? = nil) {
    if let familyImages = self.familyImages {
      var familyImageUrls = [Int: String]()

      for (index, familyImage) in familyImages.enumerated() {
        if let familyImage = familyImage {
          if let familyImageData = UIImageJPEGRepresentation(familyImage, 0.5) {
            let uuid = NSUUID().uuidString
            let storageRef = Storage.storage().reference()
            storageRef.child(KEY_FAMILY_IMAGES).child(uuid).putData(familyImageData, metadata: nil) { (metaData, error) in
              if error != nil {
                print("storageError")
                return
              }
              
              if let familyImageUrl = metaData?.downloadURL() {
                familyImageUrls[index] = familyImageUrl.absoluteString
                if familyImageUrls.count == familyImages.count {
                  let sortdUrls = familyImageUrls.sorted(by: {$0.0 < $1.0})
                  var urls = [String]()
                  for url in sortdUrls {
                    urls.append(url.value)
                  }
                  completion?(urls)
                }
              }
            }
          }
        }
      }
    }
  }
  
  //MARK: Action
  @objc private func back() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc private func edit() {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let currentUserUid = ANISessionManager.shared.currentUserUid else { return }
    
    let activityData = ActivityData(size: CGSize(width: 40.0, height: 40.0),type: .lineScale, color: ANIColor.green)
    NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)

    if familyImagesChange {
      if let familyUrls = currentUser.familyImageUrls {
        deleteFamilyImages(urls: familyUrls)
      }
      
      setFamilyImageUrls(completion: { (urls) in
        let database = Firestore.firestore()
        database.collection(KEY_USERS).document(currentUserUid).updateData([KEY_FAMILY_IMAGE_URLS : urls])
        
        self.setNewUserData()
      })
    } else {
      setNewUserData()
    }
  }
  
  private func setNewUserData() {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid,
          let profileEditView = self.profileEditView,
          let updateUser = profileEditView.getUpdateUser(),
          let userName = updateUser.userName,
          let kind = updateUser.kind,
          let introduce = updateUser.introduce else { return }
    
    if let profileImage = self.profileImage, let profileImageData = UIImageJPEGRepresentation(profileImage, 0.5) {
      let storageRef = Storage.storage().reference()
      storageRef.child(KEY_PROFILE_IMAGES).child("\(currentUserUid).jpeg").putData(profileImageData, metadata: nil) { (metaData, error) in
        if error != nil {
          print("storageError")
          return
        }
        
        if let profileImageUrl = metaData?.downloadURL() {
          let values = [KEY_USER_NAME: userName, KEY_KIND: kind, KEY_INTRODUCE: introduce, KEY_PROFILE_IMAGE_URL: profileImageUrl.absoluteString] as [String : AnyObject]
          self.updateUserData(uid: currentUserUid, values: values)
        }
      }
    } else {
      let values = [KEY_USER_NAME: userName, KEY_KIND: kind, KEY_INTRODUCE: introduce] as [String : AnyObject]
      self.updateUserData(uid: currentUserUid, values: values)
    }
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
      Gallery.Config.Camera.oneImageMode = false
      Gallery.Config.Grid.previewRatio = UIViewController.HEADER_IMAGE_VIEW_RATIO
      Config.tabsToShow = [.imageTab, .cameraTab]
      Config.Camera.imageLimit = 10
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
          let filteredImage = filteredImages[0] else { return }
    
    if isFamilyAdd {
      if familyImages != nil {
        for image in filteredImages {
          familyImages?.append(image?.resize(size: IMAGE_SIZE))
        }
      } else {
        var resizeIamges = [UIImage?]()
        for image in filteredImages {
          resizeIamges.append(image?.resize(size: IMAGE_SIZE))
        }
        familyImages = resizeIamges
      }
      
      familyImagesChange = true
    } else {
      if editImageIndex == 0 {
        profileImage = filteredImage.resize(size: IMAGE_SIZE)
      } else if let editImageIndex = editImageIndex {
        self.familyImages?[editImageIndex - 1] = filteredImage.resize(size: IMAGE_SIZE)
        
        familyImagesChange = true
      }
    }
  }
}
