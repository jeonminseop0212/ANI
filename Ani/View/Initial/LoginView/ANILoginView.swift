//
//  ANILoginView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/23.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CodableFirebase
import NVActivityIndicatorView

protocol ANILoginViewDelegate {
  func reject(notiText: String)
  func loginSuccess()
}

class ANILoginView: UIView {
  
  private weak var scrollView: ANIScrollView?
  private weak var contentView: UIView?
  
  private weak var titleLabel: UILabel?
  private weak var emailTextFieldBG: UIView?
  private weak var emailImageView: UIImageView?
  private weak var emailTextField: UITextField?
  
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
    titleLabel.rightToSuperview(offset: -10.0)
    self.titleLabel = titleLabel
    
    //emailTextFieldBG
    let emailTextFieldBG = UIView()
    emailTextFieldBG.backgroundColor = ANIColor.lightGray
    emailTextFieldBG.layer.cornerRadius = 10.0
    emailTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(emailTextFieldBG)
    emailTextFieldBG.topToBottom(of: titleLabel, offset: 30.0)
    emailTextFieldBG.leftToSuperview(offset: 10.0)
    emailTextFieldBG.rightToSuperview(offset: -10.0)
    self.emailTextFieldBG = emailTextFieldBG
    
    //emailImageView
    let emailImageView = UIImageView()
    emailImageView.image = UIImage(named: "idImage")
    emailTextFieldBG.addSubview(emailImageView)
    emailImageView.width(19.0)
    emailImageView.height(18.0)
    emailImageView.leftToSuperview(offset: 10.0)
    emailImageView.centerYToSuperview()
    self.emailImageView = emailImageView
    
    //emailTextField
    let emailTextField = UITextField()
    emailTextField.font = UIFont.systemFont(ofSize: 18.0)
    emailTextField.textColor = ANIColor.dark
    emailTextField.backgroundColor = .clear
    emailTextField.placeholder = "IDまたはユーザーネーム"
    emailTextField.returnKeyType = .done
    emailTextField.keyboardType = .emailAddress
    emailTextField.delegate = self
    emailTextFieldBG.addSubview(emailTextField)
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    emailTextField.edgesToSuperview(excluding: .left, insets: insets)
    emailTextField.leftToRight(of: emailImageView, offset: 10.0)
    self.emailTextField = emailTextField
    
    //passwordTextFieldBG
    let passwordTextFieldBG = UIView()
    passwordTextFieldBG.backgroundColor = ANIColor.lightGray
    passwordTextFieldBG.layer.cornerRadius = 10.0
    passwordTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(passwordTextFieldBG)
    passwordTextFieldBG.topToBottom(of: emailTextFieldBG, offset: 20.0)
    passwordTextFieldBG.leftToSuperview(offset: 10.0)
    passwordTextFieldBG.rightToSuperview(offset: -10.0)
    self.passwordTextFieldBG = passwordTextFieldBG

    //passwordImageView
    let passwordImageView = UIImageView()
    passwordImageView.image = UIImage(named: "passwordImage")
    passwordTextFieldBG.addSubview(passwordImageView)
    passwordImageView.width(15.0)
    passwordImageView.height(20.0)
    passwordImageView.centerX(to: emailImageView)
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
    passwordTextField.left(to: emailTextField)
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
    guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
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
      guard let emailTextField = self.emailTextField,
            let email = emailTextField.text,
            let passwordTextField = self.passwordTextField,
            let password = passwordTextField.text else { return }
      
      let activityData = ActivityData(size: CGSize(width: 40.0, height: 40.0),type: .lineScale, color: ANIColor.green)
      NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
      
      self.endEditing(true)
      
      Auth.auth().signIn(withEmail: email, password: password) { (successUser, error) in
        if let errorUnrap = error {
          let nsError = errorUnrap as NSError
          
          NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)

          DLog("nsError \(nsError)")
          if nsError.code == 17008 {
            self.delegate?.reject(notiText: "存在しないメールアドレスです！")
          } else if nsError.code == 17009 {
            self.delegate?.reject(notiText: "パスワードが違います！")
          } else if nsError.code == 17011 || nsError.code == 17008 {
            self.delegate?.reject(notiText: "存在しないメールアドレスです！")
          } else {
            self.delegate?.reject(notiText: "ログインに失敗しました！")
          }
        } else {
          let database = Firestore.firestore()
          
          ANISessionManager.shared.currentUserUid = Auth.auth().currentUser?.uid
          if let currentUserUid = ANISessionManager.shared.currentUserUid {
            DispatchQueue.global().async {
              database.collection(KEY_USERS).document(currentUserUid).addSnapshotListener({ (snapshot, error) in
                if let error = error {
                  DLog("Error adding document: \(error)")

                  return
                }
                
                guard let snapshot = snapshot, let value = snapshot.data() else { return }
                                
                do {
                  let user = try FirestoreDecoder().decode(FirebaseUser.self, from: value)
                  
                  DispatchQueue.main.async {
                    ANISessionManager.shared.currentUser = user
                    ANISessionManager.shared.isAnonymous = false
                    self.delegate?.loginSuccess()
                    
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                  }
                } catch let error {
                  DLog(error)
                  NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                }
              })
            }
          }
          
          self.endEditing(true)
        }
      }
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
