//
//  ANIForgetView.swift
//  Ani
//
//  Created by jeonminseop on 2020/03/29.
//  Copyright © 2020 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ANIForgetPasswordViewDelegate {
  func reject(notiText: String)
  func startAnimaing()
  func stopAnimating()
}

class ANIForgetPasswordView: UIView {
  
  private weak var introduceLabel: UILabel?
  
  private weak var emailTextFieldBG: UIView?
  private weak var emailImageView: UIImageView?
  private weak var emailTextField: UITextField?
  
  private let RESET_PASSWORD_BUTTON_HEIGHT: CGFloat = 45.0
  private weak var resetPasswordButton: ANIAreaButtonView?
  private weak var resetPasswordButtonLabel: UILabel?
  
  var delegate: ANIForgetPasswordViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //introduceLabel
    let introduceLabel = UILabel()
    introduceLabel.text = "パスワードの再設定のメールをお送りします。\n再設定後、もう一度ログインしてください。\n\n*再設定のメールが迷惑メールに入る場合があります*"
    introduceLabel.numberOfLines = 0
    introduceLabel.font = UIFont.systemFont(ofSize: 15.0)
    introduceLabel.textColor = ANIColor.subTitle
    introduceLabel.textAlignment = .center
    self.addSubview(introduceLabel)
    introduceLabel.topToSuperview(offset: 50.0)
    introduceLabel.leftToSuperview(offset: 10.0)
    introduceLabel.rightToSuperview(offset: -10.0)
    self.introduceLabel = introduceLabel
    
    //emailTextFieldBG
    let emailTextFieldBG = UIView()
    emailTextFieldBG.backgroundColor = ANIColor.lightGray
    emailTextFieldBG.layer.cornerRadius = 10.0
    emailTextFieldBG.layer.masksToBounds = true
    self.addSubview(emailTextFieldBG)
    emailTextFieldBG.topToBottom(of: introduceLabel, offset: 30.0)
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
    emailTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
    emailTextField.returnKeyType = .done
    emailTextField.keyboardType = .emailAddress
    emailTextField.delegate = self
    emailTextFieldBG.addSubview(emailTextField)
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    emailTextField.edgesToSuperview(excluding: .left, insets: insets)
    emailTextField.leftToRight(of: emailImageView, offset: 10.0)
    self.emailTextField = emailTextField
    
    //resetPasswordButton
    let resetPasswordButton = ANIAreaButtonView()
    resetPasswordButton.base?.backgroundColor = ANIColor.emerald
    resetPasswordButton.base?.layer.cornerRadius = RESET_PASSWORD_BUTTON_HEIGHT / 2
    resetPasswordButton.delegate = self
    resetPasswordButton.dropShadow(opacity: 0.1)
    self.addSubview(resetPasswordButton)
    resetPasswordButton.topToBottom(of: emailTextFieldBG, offset: 30.0)
    resetPasswordButton.centerXToSuperview()
    resetPasswordButton.width(190.0)
    resetPasswordButton.height(RESET_PASSWORD_BUTTON_HEIGHT)
    self.resetPasswordButton = resetPasswordButton

    //resetPasswordButtonLabel
    let resetPasswordButtonLabel = UILabel()
    resetPasswordButtonLabel.textColor = .white
    resetPasswordButtonLabel.text = "送信"
    resetPasswordButtonLabel.textAlignment = .center
    resetPasswordButtonLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    resetPasswordButton.addContent(resetPasswordButtonLabel)
    resetPasswordButtonLabel.edgesToSuperview()
    self.resetPasswordButtonLabel = resetPasswordButtonLabel
  }
}

//MARK: ANIButtonViewDelegate
extension ANIForgetPasswordView: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === resetPasswordButton {
      guard let emailTextField = self.emailTextField,
            let email = emailTextField.text else { return }
      
      if email == "" {
        self.delegate?.reject(notiText: "メールアドレスを入力してください！")
      } else {
        self.delegate?.startAnimaing()
        self.endEditing(true)
        
        Auth.auth().languageCode = "ja"
        Auth.auth().sendPasswordReset(withEmail: email) { error in
          if let errorUnrap = error {
            let nsError = errorUnrap as NSError
            
            self.delegate?.stopAnimating()
            
            if nsError.code == 17008 || nsError.code == 17011 {
              self.delegate?.reject(notiText: "存在しないメールアドレスです！")
            } else {
              self.delegate?.reject(notiText: "送信に失敗しました！")
            }
          } else {
            self.delegate?.reject(notiText: "再設定メールを送信しました！")

            self.delegate?.stopAnimating()
          }
        }
      }
    }
  }
}

//MARK: UITextFieldDelegate
extension ANIForgetPasswordView: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.endEditing(true)
    
    return true
  }
}
