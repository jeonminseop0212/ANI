//
//  RecruitContributionViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/11.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import Gallery
import TinyConstraints

enum BasicInfoPickMode: String {
  case kind
  case age
  case sex
  case home
  case vaccine
  case castration
}

class ANIRecruitContributionViewController: UIViewController {
  
  private var gallery: GalleryController?
  var myImages = [UIImage]()
  
  private weak var myNavigationBar: UIView?
  private weak var dismissButton: UIButton?
  
  private var recruitContributeViewOriginalBottomConstraintConstant: CGFloat?
  private var recruitContributeViewBottomConstraint: Constraint?
  private weak var recruitContributeView: ANIRecruitContributeView?
  
  static let CONTRIBUTE_BUTTON_HEIGHT: CGFloat = 45.0
  private weak var contributeButton: ANIAreaButtonView?
  private weak var contributeButtonLabel: UILabel?
  
  var pickMode: BasicInfoPickMode? {
    didSet {
      guard let recruitContributeView = self.recruitContributeView else { return }
      
      recruitContributeView.pickMode = pickMode
    }
  }
  
  private var isHaderImagePick: Bool = false
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    
    //recruitContributeView
    let recruitContributeView = ANIRecruitContributeView()
    recruitContributeView.headerMinHeight = UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT
    recruitContributeView.delegate = self
    self.view.addSubview(recruitContributeView)
    recruitContributeViewBottomConstraint = recruitContributeView.bottomToSuperview()
    recruitContributeViewOriginalBottomConstraintConstant = recruitContributeViewBottomConstraint?.constant
    recruitContributeView.edgesToSuperview(excluding: .bottom)
    self.recruitContributeView = recruitContributeView
    
    //myNavigationBar
    let myNavigationBar = UIView()
    myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
    self.view.addSubview(myNavigationBar)
    myNavigationBar.topToSuperview()
    myNavigationBar.leftToSuperview()
    myNavigationBar.rightToSuperview()
    myNavigationBar.height(UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBar = myNavigationBar
    
    //dismissButton
    let dismissButton = UIButton()
    let dismissButtonImage = UIImage(named: "dismissButton")?.withRenderingMode(.alwaysTemplate)
    dismissButton.setImage(dismissButtonImage, for: .normal)
    dismissButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    dismissButton.addTarget(self, action: #selector(recruitContributeDismiss), for: .touchUpInside)
    myNavigationBar.addSubview(dismissButton)
    dismissButton.width(44.0)
    dismissButton.height(44.0)
    dismissButton.leftToSuperview()
    dismissButton.bottomToSuperview()
    self.dismissButton = dismissButton
    
    //contributeButton
    let contributeButton = ANIAreaButtonView()
    contributeButton.base?.backgroundColor = ANIColor.green
    contributeButton.baseCornerRadius = ANIRecruitContributionViewController.CONTRIBUTE_BUTTON_HEIGHT / 2
    contributeButton.dropShadow(opacity: 0.2)
    contributeButton.delegate = self
    self.view.addSubview(contributeButton)
    contributeButton.bottomToSuperview(offset: -10.0)
    contributeButton.leftToSuperview(offset: 100.0)
    contributeButton.rightToSuperview(offset: 100.0)
    contributeButton.height(ANIRecruitContributionViewController.CONTRIBUTE_BUTTON_HEIGHT)
    self.contributeButton = contributeButton
    
    //ontributeButtonLabel
    let contributeButtonLabel = UILabel()
    contributeButtonLabel.text = "投稿する"
    contributeButtonLabel.textAlignment = .center
    contributeButtonLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    contributeButtonLabel.textColor = .white
    contributeButton.addContent(contributeButtonLabel)
    contributeButtonLabel.edgesToSuperview()
    self.contributeButtonLabel = contributeButtonLabel
    
//    galleryControllerOn(animation: false)
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(keyboardWillChangeFrame: self, selector: #selector(keyboardWillChangeFrame))
    ANINotificationManager.receive(keyboardWillHide: self, selector: #selector(keyboardWillHide))
  }
  
  @objc private func keyboardWillChangeFrame(_ notification: Notification) {
    guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
          let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
          let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
          let window = UIApplication.shared.keyWindow,
          let recruitContributeViewBottomConstraint = self.recruitContributeViewBottomConstraint else { return }
    
    let bottomSafeArea = window.safeAreaInsets.bottom
    let h = keyboardFrame.height - bottomSafeArea
    
    recruitContributeViewBottomConstraint.constant = -h  + 10.0 + ANIRecruitContributionViewController.CONTRIBUTE_BUTTON_HEIGHT

    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
          let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
          let recruitContributeViewOriginalBottomConstraintConstant = self.recruitContributeViewOriginalBottomConstraintConstant,
          let recruitContributeViewBottomConstraint = self.recruitContributeViewBottomConstraint else { return }
    
    recruitContributeViewBottomConstraint.constant = recruitContributeViewOriginalBottomConstraintConstant
    
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  private func recruitHeaderImagePick(animation: Bool) {
    gallery = GalleryController()
    
    if let galleryUnrap = gallery {
      galleryUnrap.delegate = self
      Gallery.Config.initialTab = .imageTab
      Gallery.Config.PageIndicator.backgroundColor = .white
      //    Gallery.Config.Camera.imageLimit = 10
      Gallery.Config.Camera.oneImageMode = true
      Gallery.Config.Font.Main.regular = UIFont.boldSystemFont(ofSize: 17)
      Gallery.Config.Grid.ArrowButton.tintColor = ANIColor.dark
      Gallery.Config.Grid.FrameView.borderColor = ANIColor.green
      if Gallery.Config.Camera.oneImageMode {
        Gallery.Config.Grid.previewRatio = UIViewController.HEADER_IMAGE_VIEW_RATIO
        Config.tabsToShow = [.imageTab]
      }
      let galleryNV = UINavigationController(rootViewController: galleryUnrap)
      present(galleryNV, animated: animation, completion: nil)
      
      isHaderImagePick = true
    }
  }
  
  private func recruitIntroduceImagesPick(animation: Bool) {
    gallery = GalleryController()
    
    if let galleryUnrap = gallery {
      galleryUnrap.delegate = self
      Gallery.Config.initialTab = .imageTab
      Gallery.Config.PageIndicator.backgroundColor = .white
      Gallery.Config.Camera.oneImageMode = false
      Gallery.Config.Font.Main.regular = UIFont.boldSystemFont(ofSize: 17)
      Gallery.Config.Grid.ArrowButton.tintColor = ANIColor.dark
      Gallery.Config.Grid.FrameView.borderColor = ANIColor.green
      Gallery.Config.Grid.previewRatio = 1.0
      let galleryNV = UINavigationController(rootViewController: galleryUnrap)
      present(galleryNV, animated: animation, completion: nil)
      
      isHaderImagePick = false
    }
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
  
  //MARK: Action
  @objc private func recruitContributeDismiss() {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}

//MARK: GalleryControllerDelegate
extension ANIRecruitContributionViewController: GalleryControllerDelegate {
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
extension ANIRecruitContributionViewController: ANIImageFilterViewControllerDelegate {
  func doneFilterImages(filteredImages: [UIImage?]) {
    guard let recruitContributeView = self.recruitContributeView,
          !filteredImages.isEmpty else { return }
    
    if isHaderImagePick {
      if let filteredImage = filteredImages[0] {
        recruitContributeView.headerImage = filteredImage
      }
    } else {
      if recruitContributeView.introduceImages.isEmpty {
        recruitContributeView.introduceImages = filteredImages
      } else {
        for filteredImage in filteredImages {
          recruitContributeView.introduceImages.append(filteredImage)
        }
      }
    }
  }
}

//MARK: ANIRecruitContributeViewDelegate
extension ANIRecruitContributionViewController: ANIRecruitContributeViewDelegate {
  func recruitContributeViewDidScroll(offset: CGFloat) {
    guard let myNavigationBar = self.myNavigationBar,
      let dismissButton = self.dismissButton else { return }
    
    if offset > 1 {
      let backGroundColorOffset: CGFloat = 1.0
      let tintColorOffset = 1.0 - offset
      dismissButton.tintColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
      myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: backGroundColorOffset)
      UIApplication.shared.statusBarStyle = .default
    } else {
      let tintColorOffset = 1.0 - offset
      let ANIColorDarkBrightness: CGFloat = 0.18
      if tintColorOffset > ANIColorDarkBrightness {
        dismissButton.tintColor = UIColor(hue: 0, saturation: 0, brightness: tintColorOffset, alpha: 1)
      } else {
        dismissButton.tintColor = UIColor(hue: 0, saturation: 0, brightness: ANIColorDarkBrightness, alpha: 1)
      }
      
      myNavigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
      UIApplication.shared.statusBarStyle = .lightContent
    }
  }
  
  func imagePickButtonTapped() {
    recruitHeaderImagePick(animation: true)
  }
  
  func kindSelectButtonTapped() {
    let popupPickerViewController = ANIPopupPickerViewController()
    popupPickerViewController.pickerItem = ["わからない", "ミックス", "ブリティッシュショートヘア", "シャム", "ペルシャ", "ラグドール", "メインクーン", "ベンガル", "スフィンクス", "アビシニアン", "ロシアンブルー", "エキゾチックショートヘア", "アメリカン・ショートヘア", "スコティッシュフォールド", "バーマン", "ノルウェージャンフォレストキャット", "アメリカンカール", "マンチカン"]
    popupPickerViewController.modalPresentationStyle = .overCurrentContext
    pickMode = BasicInfoPickMode.kind
    present(popupPickerViewController, animated: false, completion: nil)
  }
  
  func ageSelectButtonTapped() {
    let popupPickerViewController = ANIPopupPickerViewController()
    popupPickerViewController.pickerItem = ["わからない", "1歳未満", "１〜２歳", "２〜３歳", "３〜４歳", "４〜５歳", "５〜６歳", "６〜７歳", "７〜８歳", "８〜９歳", "９〜１０歳", "１０歳以上"]
    pickMode = BasicInfoPickMode.age
    popupPickerViewController.modalPresentationStyle = .overCurrentContext
    present(popupPickerViewController, animated: false, completion: nil)
  }
  
  func sexSelectButtonTapped() {
    let popupPickerViewController = ANIPopupPickerViewController()
    popupPickerViewController.pickerItem = ["わからない", "男の子", "女の子"]
    pickMode = BasicInfoPickMode.sex
    popupPickerViewController.modalPresentationStyle = .overCurrentContext
    present(popupPickerViewController, animated: false, completion: nil)
  }
  
  func homeSelectButtonTapped() {
    let popupPickerViewController = ANIPopupPickerViewController()
    popupPickerViewController.pickerItem = ["東京都", "神奈川県", "大阪府", "愛知県", "埼玉県", "千葉県", "兵庫県", "北海道", "福岡県", "静岡県",
                                            "茨城県", "広島県", "京都府", "宮城県", "新潟県", "長野県", "岐阜県", "栃木県", "群馬県", "岡山県",
                                            "福島県", "三重県", "熊本県", "鹿児島県", "沖縄県", "滋賀県", "山口県", "愛媛県", "長崎県", "奈良県",
                                            "青森県", "岩手県", "大分県", "石川県", "山形県", "宮崎県", "富山県", "秋田県", "香川県", "和歌山県",
                                            "佐賀県", "山梨県", "福井県", "徳島県", "高知県", "島根県", "鳥取県"]
    pickMode = BasicInfoPickMode.home
    popupPickerViewController.modalPresentationStyle = .overCurrentContext
    present(popupPickerViewController, animated: false, completion: nil)
  }
  
  func vaccineSelectButtonTapped() {
    let popupPickerViewController = ANIPopupPickerViewController()
    popupPickerViewController.pickerItem = ["わからない", "０回", "１回", "２回"]
    pickMode = BasicInfoPickMode.vaccine
    popupPickerViewController.modalPresentationStyle = .overCurrentContext
    present(popupPickerViewController, animated: false, completion: nil)
  }
  
  func castrationSelectButtonTapped() {
    let popupPickerViewController = ANIPopupPickerViewController()
    popupPickerViewController.pickerItem = ["わからない", "済み"]
    pickMode = BasicInfoPickMode.castration
    popupPickerViewController.modalPresentationStyle = .overCurrentContext
    present(popupPickerViewController, animated: false, completion: nil)
  }
  
  func imagesPickCellTapped() {
    print("pick")
    
    recruitIntroduceImagesPick(animation: true)
  }
}

//MARK: ANIButtonViewDelegate
extension ANIRecruitContributionViewController: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === self.contributeButton {
      print("contribute button tapped")
    }
  }
}
