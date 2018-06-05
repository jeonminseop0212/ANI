//
//  ANIProfileEditView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIProfileEditViewDelegate {
  func kindSelectButtonTapped()
  func editButtonEnable(enable: Bool)
  func imagePickerCellTapped()
  func imageEditCellTapped(index: Int)
}

class ANIProfileEditView: UIView {
  
  private weak var scrollView: ANIScrollView?
  private weak var contentView: UIView?
  
  private weak var familyTitleLabel: UILabel?
  private let FAMILY_VIEW_HEIGHT: CGFloat = 95.0
  private weak var familyView: ANIProfileEditFamilyView?
  
  private weak var nameTitleLabel: UILabel?
  private weak var nameBG: UIView?
  private weak var nameTextView: ANIPlaceHolderTextView?
  
  private weak var kindTitleLable: UILabel?
  private weak var kindBG: UIView?
  private weak var kindLabel: UILabel?
  private weak var kindSelectButton: ANIImageButtonView?
  
  private weak var introduceTitleLabel: UILabel?
  private weak var introduceBG: UIView?
  private weak var introduceTextView: ANIPlaceHolderTextView?
  
  var currentUser: FirebaseUser? {
    didSet {
      guard let familyView = self.familyView,
            let currentUser = self.currentUser else { return }
      familyView.currentUser = currentUser
      
      reloadLayout()
    }
  }
  
  private var selectedTextViewMaxY: CGFloat?
  
  var profileImage = UIImage() {
    didSet {
      guard let familyView = self.familyView else { return }
      familyView.profileImage = profileImage
    }
  }
  var familyImages: [UIImage?]? {
    didSet {
      guard let familyView = self.familyView else { return }
      familyView.familyImages = familyImages
    }
  }
  
  var delegate: ANIProfileEditViewDelegate?
  
  private let KEYBOARD_HIDE_TOOL_BAR_HEIGHT: CGFloat = 40.0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
    setNotification()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //scrollView
    let scrollView = ANIScrollView()
    scrollView.contentInsetAdjustmentBehavior = .never
    addSubview(scrollView)
    scrollView.edgesToSuperview()
    self.scrollView = scrollView
    
    //contentView
    let contentView = UIView()
    scrollView.addSubview(contentView)
    contentView.edgesToSuperview()
    contentView.width(to: scrollView)
    self.contentView = contentView
    
    //familyTitleLabel
    let familyTitleLabel = UILabel()
    familyTitleLabel.text = "家族リスト"
    familyTitleLabel.textColor = ANIColor.dark
    familyTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    contentView.addSubview(familyTitleLabel)
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    familyTitleLabel.edgesToSuperview(excluding: .bottom, insets: insets)
    self.familyTitleLabel = familyTitleLabel
    
    //familyView
    let familyView = ANIProfileEditFamilyView()
    familyView.delegate = self
    contentView.addSubview(familyView)
    familyView.topToBottom(of: familyTitleLabel)
    familyView.leftToSuperview()
    familyView.rightToSuperview()
    familyView.height(FAMILY_VIEW_HEIGHT)
    self.familyView = familyView
    
    //nameTitleLabel
    let nameTitleLabel = UILabel()
    nameTitleLabel.text = "名前"
    nameTitleLabel.textColor = ANIColor.dark
    nameTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    contentView.addSubview(nameTitleLabel)
    nameTitleLabel.topToBottom(of: familyView, offset: 10.0)
    nameTitleLabel.leftToSuperview(offset: 10.0)
    nameTitleLabel.rightToSuperview(offset: 10.0)
    self.familyTitleLabel = familyTitleLabel
    
    //nameBG
    let nameBG = UIView()
    nameBG.backgroundColor = ANIColor.lightGray
    nameBG.layer.cornerRadius = 10.0
    nameBG.layer.masksToBounds = true
    contentView.addSubview(nameBG)
    nameBG.topToBottom(of: nameTitleLabel, offset: 10.0)
    nameBG.leftToSuperview(offset: 10.0)
    nameBG.rightToSuperview(offset: 10.0)
    self.nameBG = nameBG
    
    //nameTextView
    let nameTextView = ANIPlaceHolderTextView()
    nameTextView.font = UIFont.systemFont(ofSize: 15.0)
    nameTextView.textColor = ANIColor.dark
    nameTextView.backgroundColor = .clear
    nameTextView.isScrollEnabled = false
    nameTextView.placeHolder = "名前を入力してください"
    nameTextView.delegate = self
    nameBG.addSubview(nameTextView)
    let textViewInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: -5.0)
    nameTextView.edgesToSuperview(insets: textViewInsets)
    self.nameTextView = nameTextView
    setHideButtonOnKeyboard(textView: nameTextView)
    
    //kindTitleLable
    let kindTitleLable = UILabel()
    kindTitleLable.text = "グループ"
    kindTitleLable.textColor = ANIColor.dark
    kindTitleLable.font = UIFont.boldSystemFont(ofSize: 20.0)
    contentView.addSubview(kindTitleLable)
    kindTitleLable.topToBottom(of: nameBG, offset: 10.0)
    kindTitleLable.leftToSuperview(offset: 10.0)
    kindTitleLable.rightToSuperview(offset: 10.0)
    self.kindTitleLable = kindTitleLable
    
    //kindBG
    let kindBG = UIView()
    kindBG.backgroundColor = ANIColor.lightGray
    kindBG.layer.cornerRadius = 10.0
    kindBG.layer.masksToBounds = true
    contentView.addSubview(kindBG)
    kindBG.topToBottom(of: kindTitleLable, offset: 10.0)
    kindBG.leftToSuperview(offset: 10.0)
    kindBG.rightToSuperview(offset: 10.0)
    self.kindBG = kindBG
    
    //kindLabel
    let kindLabel = UILabel()
    kindLabel.backgroundColor = .clear
    kindLabel.textColor = ANIColor.dark
    kindLabel.font = UIFont.systemFont(ofSize: 15.0)
    kindLabel.isUserInteractionEnabled = true
    let tapKindGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(kindSelectButtonTapped))
    kindLabel.addGestureRecognizer(tapKindGestureRecognizer)
    kindBG.addSubview(kindLabel)
    kindLabel.edgesToSuperview(excluding: .right, insets: insets)
    self.kindLabel = kindLabel
    
    //kindSelectButton
    let kindSelectButton = ANIImageButtonView()
    kindSelectButton.delegate = self
    kindSelectButton.image = UIImage(named: "basicInfoSelectButton")
    kindBG.addSubview(kindSelectButton)
    kindSelectButton.width(12.0)
    kindSelectButton.height(12.0)
    kindSelectButton.centerY(to: kindLabel)
    kindSelectButton.leftToRight(of: kindLabel, offset: 10.0)
    self.kindSelectButton = kindSelectButton
    
    //introduceTitleLabel
    let introduceTitleLabel = UILabel()
    introduceTitleLabel.text = "紹介"
    introduceTitleLabel.textColor = ANIColor.dark
    introduceTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    contentView.addSubview(introduceTitleLabel)
    introduceTitleLabel.topToBottom(of: kindBG, offset: 10.0)
    introduceTitleLabel.leftToSuperview(offset: 10.0)
    introduceTitleLabel.rightToSuperview(offset: 10.0)
    self.introduceTitleLabel = introduceTitleLabel
    
    //introduceBG
    let introduceBG = UIView()
    introduceBG.backgroundColor = ANIColor.lightGray
    introduceBG.layer.cornerRadius = 10.0
    introduceBG.layer.masksToBounds = true
    contentView.addSubview(introduceBG)
    introduceBG.topToBottom(of: introduceTitleLabel, offset: 10.0)
    introduceBG.leftToSuperview(offset: 10.0)
    introduceBG.rightToSuperview(offset: 10.0)
    introduceBG.bottomToSuperview(offset: -10.0)
    self.introduceBG = introduceBG
    
    //introduceTextView
    let introduceTextView = ANIPlaceHolderTextView()
    introduceTextView.font = UIFont.systemFont(ofSize: 15.0)
    introduceTextView.textColor = ANIColor.dark
    introduceTextView.backgroundColor = .clear
    introduceTextView.isScrollEnabled = false
    introduceTextView.placeHolder = "紹介文を入力してください"
    introduceTextView.delegate = self
    introduceBG.addSubview(introduceTextView)
    introduceTextView.edgesToSuperview(insets: textViewInsets)
    self.introduceTextView = introduceTextView
    setHideButtonOnKeyboard(textView: introduceTextView)
  }
  
  private func setNotification() {
    ANINotificationManager.receive(pickerViewDidSelect: self, selector: #selector(updateKind))
    ANINotificationManager.receive(keyboardWillChangeFrame: self, selector: #selector(keyboardWillChangeFrame))
  }
  
  private func reloadLayout() {
    guard let nameTextView = self.nameTextView,
          let kindLabel = self.kindLabel,
          let introduceTextView = self.introduceTextView,
          let currentUser = self.currentUser else { return }
    
    nameTextView.text = currentUser.userName
    kindLabel.text = currentUser.kind
    introduceTextView.text = currentUser.introduce
  }
  
  private func setHideButtonOnKeyboard(textView: UITextView){
    let tools = UIToolbar()
    tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: KEYBOARD_HIDE_TOOL_BAR_HEIGHT)
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(keyboardHideButtonTapped))
    tools.items = [spacer, closeButton]
    textView.inputAccessoryView = tools
  }
  
  private func editButtonEnable() {
    guard let nameTextView = self.nameTextView else { return }
    
    if nameTextView.text.count > 0 {
      self.delegate?.editButtonEnable(enable: true)
    } else {
      self.delegate?.editButtonEnable(enable: false)
    }
  }
  
  func getUpdateUser() -> FirebaseUser? {
    guard let nameTextView = self.nameTextView,
          let name = nameTextView.text,
          let kindLabel = self.kindLabel,
          let kind = kindLabel.text,
          let introduceTextView = self.introduceTextView,
          let introduce = introduceTextView.text else { return nil }
    
    var updateUser = FirebaseUser()
    updateUser.userName = name
    updateUser.kind = kind
    updateUser.introduce = introduce
    return updateUser
  }
  
  @objc func keyboardWillChangeFrame(_ notification: Notification) {
    guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
          let scrollView = self.scrollView,
          let selectedTextViewMaxY = self.selectedTextViewMaxY else { return }

    let selectedTextViewVisiableMaxY = selectedTextViewMaxY - scrollView.contentOffset.y + UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT
    if selectedTextViewVisiableMaxY > keyboardFrame.origin.y {
      let margin: CGFloat = 10.0
      let blindHeight = selectedTextViewVisiableMaxY - keyboardFrame.origin.y
      scrollView.contentOffset.y = scrollView.contentOffset.y + blindHeight + margin
    }
  }
  
  //MARK: action
  @objc func keyboardHideButtonTapped(){
    self.endEditing(true)
    self.resignFirstResponder()
  }
  
  @objc private func kindSelectButtonTapped() {
    self.delegate?.kindSelectButtonTapped()
  }
  
  @objc private func updateKind(_ notification: NSNotification) {
    guard let pickItem = notification.object,
          let kind = pickItem as? String,
          let kindLabel = self.kindLabel else { return }
    
    kindLabel.text = kind
  }
}

//MARK: UITextViewDelegate
extension ANIProfileEditView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    editButtonEnable()
  }
  
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    guard let selectedTextViewSuperView = textView.superview else { return false }
    selectedTextViewMaxY = selectedTextViewSuperView.frame.maxY

    return true
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    selectedTextViewMaxY = nil
  }
}

//MARK: ANIButtonViewDelegate
extension ANIProfileEditView: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === self.kindSelectButton {
      self.delegate?.kindSelectButtonTapped()
    }
  }
}

//MARK: ANIProfileEditFamilyViewDelegate
extension ANIProfileEditView: ANIProfileEditFamilyViewDelegate {
  func imagePickerCellTapped() {
    self.delegate?.imagePickerCellTapped()
  }
  
  func imageEditButtonTapped(index: Int) {
    self.delegate?.imageEditCellTapped(index: index)
  }
}
