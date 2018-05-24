//
//  SignUpView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/24.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANISignUpViewDelegate {
  func donButtonTapped()
  func prifileImagePickButtonTapped()
  func reject(notiText: String)
}

class ANISignUpView: UIView {
  
  private weak var scrollView: ANIScrollView?
  private weak var contentView: UIView?
  
  private let CONTENT_SPACE: CGFloat = 25.0
  
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 110.0
  private weak var profileImageView: UIImageView?
  private let PROFILE_IMAGE_PICK_BUTTON_HEIGHT: CGFloat = 30.0
  private weak var profileImagePickButton: ANIImageButtonView?
  
  private weak var idTitleLabel: UILabel?
  private weak var idTextFieldBG: UIView?
  private weak var idTextField: UITextField?
  
  private weak var passwordTitleLabel: UILabel?
  private weak var passwordTextFieldBG: UIView?
  private weak var passwordTextField: UITextField?
  private weak var passwordCheckTextFieldBG: UIView?
  private weak var passwordCheckTextField: UITextField?
  
  private weak var userNameTitleLabel: UILabel?
  private weak var userNameTextFieldBG: UIView?
  private weak var userNameTextField: UITextField?
  
  private let DONE_BUTTON_HEIGHT: CGFloat = 45.0
  private weak var doneButton: ANIAreaButtonView?
  private weak var doneButtonLabel: UILabel?
  
  private var selectedTextFieldMaxY: CGFloat?
  
  private var user: User?
  var profileImage: UIImage? {
    didSet {
      guard let profileImageView = self.profileImageView,
            let profileImage = self.profileImage else { return }
      
      profileImageView.image = profileImage
    }
  }
  
  var delegate: ANISignUpViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
    setupNotification()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //scrollView
    let scrollView = ANIScrollView()
    addSubview(scrollView)
    scrollView.edgesToSuperview()
    self.scrollView = scrollView
    
    //contentView
    let contentView = UIView()
    scrollView.addSubview(contentView)
    contentView.edgesToSuperview()
    contentView.width(to: scrollView)
    self.contentView = contentView
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    contentView.addSubview(profileImageView)
    profileImageView.topToSuperview(offset: 10.0)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.centerXToSuperview()
    self.profileImageView = profileImageView
    profileImage = UIImage(named: "profileDefaultImage")
    
    //profileImagePickButton
    let profileImagePickButton = ANIImageButtonView()
    profileImagePickButton.image = UIImage(named: "imagePickButton")
    profileImagePickButton.delegate = self
    contentView.addSubview(profileImagePickButton)
    profileImagePickButton.width(PROFILE_IMAGE_PICK_BUTTON_HEIGHT)
    profileImagePickButton.height(PROFILE_IMAGE_PICK_BUTTON_HEIGHT)
    profileImagePickButton.bottom(to: profileImageView)
    profileImagePickButton.right(to: profileImageView)
    self.profileImagePickButton = profileImagePickButton
    
    //idTitleLabel
    let idTitleLabel = UILabel()
    idTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    idTitleLabel.textColor = ANIColor.dark
    idTitleLabel.text = "IDを決めましょ！"
    contentView.addSubview(idTitleLabel)
    idTitleLabel.topToBottom(of: profileImageView, offset: CONTENT_SPACE)
    idTitleLabel.leftToSuperview(offset: 10.0)
    idTitleLabel.rightToSuperview(offset: 10.0)
    self.idTitleLabel = idTitleLabel
    
    //idTextFieldBG
    let idTextFieldBG = UIView()
    idTextFieldBG.backgroundColor = ANIColor.lightGray
    idTextFieldBG.layer.cornerRadius = 10.0
    idTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(idTextFieldBG)
    idTextFieldBG.topToBottom(of: idTitleLabel, offset: 10.0)
    idTextFieldBG.leftToSuperview(offset: 10.0)
    idTextFieldBG.rightToSuperview(offset: 10.0)
    self.idTextFieldBG = idTextFieldBG
    
    //idTextField
    let idTextField = UITextField()
    idTextField.font = UIFont.systemFont(ofSize: 18.0)
    idTextField.textColor = ANIColor.dark
    idTextField.backgroundColor = .clear
    idTextField.placeholder = "ex)ANI-ani"
    idTextField.returnKeyType = .done
    idTextField.delegate = self
    idTextFieldBG.addSubview(idTextField)
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
    idTextField.edgesToSuperview(insets: insets)
    self.idTextField = idTextField
    
    //passwordTitleLabel
    let passwordTitleLabel = UILabel()
    passwordTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    passwordTitleLabel.textColor = ANIColor.dark
    passwordTitleLabel.text = "パスワードを決めましょう🔑"
    contentView.addSubview(passwordTitleLabel)
    passwordTitleLabel.topToBottom(of: idTextFieldBG, offset: CONTENT_SPACE)
    passwordTitleLabel.leftToSuperview(offset: 10.0)
    passwordTitleLabel.rightToSuperview(offset: 10.0)
    self.passwordTitleLabel = passwordTitleLabel
    
    //passwordTextFieldBG
    let passwordTextFieldBG = UIView()
    passwordTextFieldBG.backgroundColor = ANIColor.lightGray
    passwordTextFieldBG.layer.cornerRadius = 10.0
    passwordTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(passwordTextFieldBG)
    passwordTextFieldBG.topToBottom(of: passwordTitleLabel, offset: 10.0)
    passwordTextFieldBG.leftToSuperview(offset: 10.0)
    passwordTextFieldBG.rightToSuperview(offset: 10.0)
    self.passwordTextFieldBG = passwordTextFieldBG
    
    //passwordTextField
    let passwordTextField = UITextField()
    passwordTextField.font = UIFont.systemFont(ofSize: 18.0)
    passwordTextField.textColor = ANIColor.dark
    passwordTextField.backgroundColor = .clear
    passwordTextField.placeholder = "パスワード"
    passwordTextField.returnKeyType = .done
    passwordTextField.isSecureTextEntry = true
    passwordTextField.delegate = self
    passwordTextFieldBG.addSubview(passwordTextField)
    passwordTextField.edgesToSuperview(insets: insets)
    self.passwordTextField = passwordTextField
    
    //passwordCheckTextFieldBG
    let passwordCheckTextFieldBG = UIView()
    passwordCheckTextFieldBG.backgroundColor = ANIColor.lightGray
    passwordCheckTextFieldBG.layer.cornerRadius = 10.0
    passwordCheckTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(passwordCheckTextFieldBG)
    passwordCheckTextFieldBG.topToBottom(of: passwordTextFieldBG, offset: 10.0)
    passwordCheckTextFieldBG.leftToSuperview(offset: 10.0)
    passwordCheckTextFieldBG.rightToSuperview(offset: 10.0)
    self.passwordCheckTextFieldBG = passwordCheckTextFieldBG
    
    //passwordCheckTextField
    let passwordCheckTextField = UITextField()
    passwordCheckTextField.font = UIFont.systemFont(ofSize: 18.0)
    passwordCheckTextField.textColor = ANIColor.dark
    passwordCheckTextField.backgroundColor = .clear
    passwordCheckTextField.placeholder = "パスワードの確認"
    passwordCheckTextField.returnKeyType = .done
    passwordCheckTextField.isSecureTextEntry = true
    passwordCheckTextField.delegate = self
    passwordCheckTextFieldBG.addSubview(passwordCheckTextField)
    passwordCheckTextField.edgesToSuperview(insets: insets)
    self.passwordCheckTextField = passwordCheckTextField
    
    //userNameTitleLabel
    let userNameTitleLabel = UILabel()
    userNameTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    userNameTitleLabel.textColor = ANIColor.dark
    userNameTitleLabel.text = "ユーザーネームを決めましょ！"
    contentView.addSubview(userNameTitleLabel)
    userNameTitleLabel.topToBottom(of: passwordCheckTextFieldBG, offset: CONTENT_SPACE)
    userNameTitleLabel.leftToSuperview(offset: 10.0)
    userNameTitleLabel.rightToSuperview(offset: 10.0)
    self.userNameTitleLabel = userNameTitleLabel
    
    //userNameTextFieldBG
    let userNameTextFieldBG = UIView()
    userNameTextFieldBG.backgroundColor = ANIColor.lightGray
    userNameTextFieldBG.layer.cornerRadius = 10.0
    userNameTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(userNameTextFieldBG)
    userNameTextFieldBG.topToBottom(of: userNameTitleLabel, offset: 10.0)
    userNameTextFieldBG.leftToSuperview(offset: 10.0)
    userNameTextFieldBG.rightToSuperview(offset: 10.0)
    self.userNameTextFieldBG = userNameTextFieldBG
    
    //userNameTextField
    let userNameTextField = UITextField()
    userNameTextField.font = UIFont.systemFont(ofSize: 18.0)
    userNameTextField.textColor = ANIColor.dark
    userNameTextField.backgroundColor = .clear
    userNameTextField.placeholder = "ex)ANI-ani"
    userNameTextField.returnKeyType = .done
    userNameTextField.delegate = self
    userNameTextFieldBG.addSubview(userNameTextField)
    userNameTextField.edgesToSuperview(insets: insets)
    self.userNameTextField = userNameTextField
    
    //doneButton
    let doneButton = ANIAreaButtonView()
    doneButton.base?.backgroundColor = ANIColor.green
    doneButton.base?.layer.cornerRadius = DONE_BUTTON_HEIGHT / 2
    doneButton.delegate = self
    doneButton.dropShadow(opacity: 0.1)
    contentView.addSubview(doneButton)
    doneButton.topToBottom(of: userNameTextFieldBG, offset: CONTENT_SPACE)
    doneButton.centerXToSuperview()
    doneButton.width(190.0)
    doneButton.height(DONE_BUTTON_HEIGHT)
    doneButton.bottomToSuperview(offset: -10.0)
    self.doneButton = doneButton
    
    //doneButtonLabel
    let doneButtonLabel = UILabel()
    doneButtonLabel.textColor = .white
    doneButtonLabel.text = "OK!"
    doneButtonLabel.textAlignment = .center
    doneButtonLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    doneButton.addContent(doneButtonLabel)
    doneButtonLabel.edgesToSuperview()
    self.doneButtonLabel = doneButtonLabel
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(keyboardWillChangeFrame: self, selector: #selector(keyboardWillChangeFrame))
  }
  
  @objc func keyboardWillChangeFrame(_ notification: Notification) {
    guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
          let scrollView = self.scrollView,
          let selectedTextFieldMaxY = self.selectedTextFieldMaxY else { return }
    
    let selectedTextFieldVisiableMaxY = selectedTextFieldMaxY - scrollView.contentOffset.y
    
    if selectedTextFieldVisiableMaxY > keyboardFrame.origin.y {
      let margin: CGFloat = 10.0
      let blindHeight = selectedTextFieldVisiableMaxY - keyboardFrame.origin.y + margin
      scrollView.contentOffset.y = scrollView.contentOffset.y + blindHeight
    }
  }
}

//MARK: ANIButtonViewDelegate
extension ANISignUpView: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view == profileImagePickButton {
      self.delegate?.prifileImagePickButtonTapped()
    }
    if view == doneButton {
      guard let profileImage = self.profileImage,
            let idTextField = self.idTextField,
            let id = idTextField.text,
            let passwordTextField = self.passwordTextField,
            let password = passwordTextField.text,
            let passwordCheckTextField = self.passwordCheckTextField,
            let passwordCheck = passwordCheckTextField.text,
            let userNameTextField = self.userNameTextField,
            let userName = userNameTextField.text else { return }
      
      if id.count > 0 && password.count > 0 && passwordCheck.count > 0 && userName.count > 0 {
        if password == passwordCheck {
          let user = User(id: id, password: password, profileImage: profileImage, name: userName, familyImages: nil, kind: nil, introduce: nil)
          
          //TODO: user create server
          
          self.delegate?.donButtonTapped()
        } else {
          self.delegate?.reject(notiText: "パスワードが異なります！")
        }
      } else {
        self.delegate?.reject(notiText: "入力してない項目があります！")
      }
    }
  }
}

//MARK: UITextFieldDelegate
extension ANISignUpView: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    guard let selectedTextViewSuperView = textField.superview else { return }
    selectedTextFieldMaxY = selectedTextViewSuperView.frame.maxY + UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.endEditing(true)
    
    return true
  }
}
