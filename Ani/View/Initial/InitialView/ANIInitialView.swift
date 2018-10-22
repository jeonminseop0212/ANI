//
//  ANIInitialView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/23.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIInitialViewDelegate {
  func loginButtonTapped()
  func signUpButtonTapped()
  func startAnonymous()
}

class ANIInitialView: UIView {
  
  private weak var initialImageView: UIImageView?

  private weak var titleLabel: UILabel?
  private weak var subTitleLabel: UILabel?
  
  private weak var buttonStackView: UIStackView?
  private let LOGIN_BUTTON_HEIGHT: CGFloat = 45.0
  private weak var loginButton: ANIAreaButtonView?
  private weak var loginButtonLabel: UILabel?
  private weak var signUpButton: ANIAreaButtonView?
  private weak var signUpButtonLabel: UILabel?
  
  private weak var anonymousLabel: UILabel?
  
  var delegate: ANIInitialViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //initialImageView
    let initialImageView = UIImageView()
    initialImageView.contentMode = .scaleAspectFill
    initialImageView.image = UIImage(named: "initial")
    addSubview(initialImageView)
    initialImageView.edgesToSuperview()
    self.initialImageView = initialImageView
    
    //anonymousLabel
    let anonymousLabel = UILabel()
    anonymousLabel.font = UIFont.systemFont(ofSize: 13.0)
    anonymousLabel.textColor = ANIColor.darkGray
    anonymousLabel.text = "ログインしないで始める"
    anonymousLabel.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startAnonymous))
    anonymousLabel.addGestureRecognizer(tapGesture)
    addSubview(anonymousLabel)
    anonymousLabel.bottomToSuperview(offset: -24.0)
    anonymousLabel.centerXToSuperview()
    self.anonymousLabel = anonymousLabel
    
    //buttonStackView
    let buttonStackView = UIStackView()
    buttonStackView.backgroundColor = .red
    buttonStackView.axis = .horizontal
    buttonStackView.alignment = .center
    buttonStackView.distribution = .fillEqually
    buttonStackView.spacing = 10.0
    addSubview(buttonStackView)
    buttonStackView.bottomToTop(of: anonymousLabel, offset: -12.0)
    buttonStackView.leftToSuperview(offset: 40.0)
    buttonStackView.rightToSuperview(offset: -40.0)
    self.buttonStackView = buttonStackView
    
    //loginButton
    let loginButton = ANIAreaButtonView()
    loginButton.base?.layer.cornerRadius = LOGIN_BUTTON_HEIGHT / 2
    loginButton.base?.backgroundColor = ANIColor.emerald
    loginButton.delegate = self
    buttonStackView.addArrangedSubview(loginButton)
    loginButton.height(LOGIN_BUTTON_HEIGHT)
    self.loginButton = loginButton
    
    //loginButtonLabel
    let loginButtonLabel = UILabel()
    loginButtonLabel.textColor = .white
    loginButtonLabel.textAlignment = .center
    loginButtonLabel.text = "ログイン"
    loginButtonLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
    loginButton.addContent(loginButtonLabel)
    loginButtonLabel.edgesToSuperview()
    self.loginButtonLabel = loginButtonLabel
    
    //signUpButton
    let signUpButton = ANIAreaButtonView()
    signUpButton.base?.layer.cornerRadius = LOGIN_BUTTON_HEIGHT / 2
    signUpButton.base?.backgroundColor = .clear
    signUpButton.base?.layer.borderColor = ANIColor.emerald.cgColor
    signUpButton.base?.layer.borderWidth = 2.0
    signUpButton.delegate = self
    buttonStackView.addArrangedSubview(signUpButton)
    signUpButton.height(LOGIN_BUTTON_HEIGHT)
    self.signUpButton = signUpButton
    
    //signUpButtonLabel
    let signUpButtonLabel = UILabel()
    signUpButtonLabel.textColor = ANIColor.emerald
    signUpButtonLabel.textAlignment = .center
    signUpButtonLabel.text = "登録"
    signUpButtonLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
    signUpButton.addContent(signUpButtonLabel)
    signUpButtonLabel.edgesToSuperview()
    self.signUpButtonLabel = signUpButtonLabel

    //subTitleLabel
    let subTitleLabel = UILabel()
    subTitleLabel.textColor = ANIColor.subTitle
    subTitleLabel.font = UIFont.systemFont(ofSize: 18.0)
    subTitleLabel.numberOfLines = 2
    subTitleLabel.textAlignment = .center
    subTitleLabel.text = "猫と猫好き、猫好きと猫好きが\nつながるコミュニティ"
    addSubview(subTitleLabel)
    subTitleLabel.centerXToSuperview()
    subTitleLabel.bottomToTop(of: buttonStackView, offset: -24.0)
    self.subTitleLabel = subTitleLabel
    
    //titleLabel
    let titleLabel = UILabel()
    titleLabel.textColor = ANIColor.dark
    titleLabel.font = UIFont.boldSystemFont(ofSize: 55.0)
    titleLabel.text = "MYAU"
    addSubview(titleLabel)
    titleLabel.bottomToTop(of: subTitleLabel, offset: -20.0)
    titleLabel.centerXToSuperview()
    self.titleLabel = titleLabel
  }
  
  @objc private func startAnonymous() {
    self.delegate?.startAnonymous()
  }
}

//MARK: ANIButtonViewDelegate
extension ANIInitialView: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === loginButton {
      self.delegate?.loginButtonTapped()
    }
    if view === signUpButton {
      self.delegate?.signUpButtonTapped()
    }
  }
}
