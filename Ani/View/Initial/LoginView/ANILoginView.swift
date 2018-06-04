//
//  ANILoginView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/23.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANILoginViewDelegate {
  func reject()
  func loginButtonTapped()
}

class ANILoginView: UIView {
  
  private weak var scrollView: ANIScrollView?
  private weak var contentView: UIView?
  
  private weak var titleLabel: UILabel?
  private weak var idTextFieldBG: UIView?
  private weak var idImageView: UIImageView?
  private weak var idTextField: UITextField?
  
  private weak var passwordTextFieldBG: UIView?
  private weak var passwordImageView: UIImageView?
  private weak var passwordTextField: UITextField?
  
  private let LOGIN_BUTTON_HEIGHT: CGFloat = 45.0
  private weak var loginButton: ANIAreaButtonView?
  private weak var loginButtonLabel: UILabel?
  
  private var selectedTextFieldMaxY: CGFloat?
  
  var delegate: ANILoginViewDelegate?
  
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
    
    //titleLabel
    let titleLabel = UILabel()
    titleLabel.font = UIFont.boldSystemFont(ofSize: 30.0)
    titleLabel.textColor = ANIColor.dark
    titleLabel.text = "おかえりなさい😻"
    titleLabel.textAlignment = .center
    contentView.addSubview(titleLabel)
    titleLabel.topToSuperview(offset: 50.0)
    titleLabel.leftToSuperview(offset: 10.0)
    titleLabel.rightToSuperview(offset: 10.0)
    self.titleLabel = titleLabel
    
    //idTextFieldBG
    let idTextFieldBG = UIView()
    idTextFieldBG.backgroundColor = ANIColor.lightGray
    idTextFieldBG.layer.cornerRadius = 10.0
    idTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(idTextFieldBG)
    idTextFieldBG.topToBottom(of: titleLabel, offset: 30.0)
    idTextFieldBG.leftToSuperview(offset: 10.0)
    idTextFieldBG.rightToSuperview(offset: 10.0)
    self.idTextFieldBG = idTextFieldBG
    
    //idImageView
    let idImageView = UIImageView()
    idImageView.image = UIImage(named: "idImage")
    idTextFieldBG.addSubview(idImageView)
    idImageView.width(19.0)
    idImageView.height(18.0)
    idImageView.leftToSuperview(offset: 10.0)
    idImageView.centerYToSuperview()
    self.idImageView = idImageView
    
    //idTextField
    let idTextField = UITextField()
    idTextField.font = UIFont.systemFont(ofSize: 18.0)
    idTextField.textColor = ANIColor.dark
    idTextField.backgroundColor = .clear
    idTextField.placeholder = "IDまたはユーザーネーム"
    idTextField.returnKeyType = .done
    idTextField.delegate = self
    idTextFieldBG.addSubview(idTextField)
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
    idTextField.edgesToSuperview(excluding: .left, insets: insets)
    idTextField.leftToRight(of: idImageView, offset: 10.0)
    self.idTextField = idTextField
    
    //passwordTextFieldBG
    let passwordTextFieldBG = UIView()
    passwordTextFieldBG.backgroundColor = ANIColor.lightGray
    passwordTextFieldBG.layer.cornerRadius = 10.0
    passwordTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(passwordTextFieldBG)
    passwordTextFieldBG.topToBottom(of: idTextFieldBG, offset: 20.0)
    passwordTextFieldBG.leftToSuperview(offset: 10.0)
    passwordTextFieldBG.rightToSuperview(offset: 10.0)
    self.passwordTextFieldBG = passwordTextFieldBG

    //passwordImageView
    let passwordImageView = UIImageView()
    passwordImageView.image = UIImage(named: "passwordImage")
    passwordTextFieldBG.addSubview(passwordImageView)
    passwordImageView.width(15.0)
    passwordImageView.height(20.0)
    passwordImageView.centerX(to: idImageView)
    passwordImageView.centerYToSuperview()
    self.passwordImageView = passwordImageView
    
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
    passwordTextField.edgesToSuperview(excluding: .left, insets: insets)
    passwordTextField.left(to: idTextField)
    self.passwordTextField = passwordTextField
    
    //loginButton
    let logButton = ANIAreaButtonView()
    logButton.base?.backgroundColor = ANIColor.green
    logButton.base?.layer.cornerRadius = LOGIN_BUTTON_HEIGHT / 2
    logButton.delegate = self
    logButton.dropShadow(opacity: 0.1)
    contentView.addSubview(logButton)
    logButton.topToBottom(of: passwordTextFieldBG, offset: 30.0)
    logButton.centerXToSuperview()
    logButton.width(190.0)
    logButton.height(LOGIN_BUTTON_HEIGHT)
    logButton.bottomToSuperview(offset: -10)
    self.loginButton = logButton

    //loginButtonLabel
    let loginButtonLabel = UILabel()
    loginButtonLabel.textColor = .white
    loginButtonLabel.text = "ログイン"
    loginButtonLabel.textAlignment = .center
    loginButtonLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    logButton.addContent(loginButtonLabel)
    loginButtonLabel.edgesToSuperview()
    self.loginButtonLabel = loginButtonLabel
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
extension ANILoginView: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === loginButton {
      //TODO: reject, sever
//      self.delegate?.reject()
      self.delegate?.loginButtonTapped()
    }
  }
}

//MARK: UITextFieldDelegate
extension ANILoginView: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    guard let selectedTextViewSuperView = textField.superview else { return }
    selectedTextFieldMaxY = selectedTextViewSuperView.frame.maxY + UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.endEditing(true)
    
    return true
  }
}
