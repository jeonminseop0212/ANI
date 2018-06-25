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
  
  private weak var headerImageView: UIImageView?
  
  private weak var base: UIView?
  private weak var titleLabel: UILabel?
  private weak var subTitleLabel: UILabel?
  
  private weak var buttonStackView: UIStackView?
  private let LOGIN_BUTTON_HEIGHT: CGFloat = 45.0
  private weak var loginButton: ANIAreaButtonView?
  private weak var loginButtonLabel: UILabel?
  private weak var signUpButton: ANIAreaButtonView?
  private weak var signUpButtonLabel: UILabel?
  private weak var anonymousLabel: UILabel?
  
  private weak var fotterImageView: UIImageView?
  
  var delegate: ANIInitialViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //base
    let base = UIView()
    base.backgroundColor = .white
    addSubview(base)
    base.leftToSuperview()
    base.rightToSuperview()
    base.height(300.0)
    base.centerInSuperview()
    self.base = base
    
    //subTitleLabel
    let subTitleLabel = UILabel()
    subTitleLabel.textColor = ANIColor.subTitle
    subTitleLabel.font = UIFont.systemFont(ofSize: 20.0)
    subTitleLabel.numberOfLines = 2
    subTitleLabel.textAlignment = .center
    subTitleLabel.text = "猫たちがもっと幸せに暮らせる\n環境になるように..."
    base.addSubview(subTitleLabel)
    subTitleLabel.centerXToSuperview()
    subTitleLabel.centerYToSuperview(offset: -15.0)
    self.subTitleLabel = subTitleLabel
    
    //titleLabel
    let titleLabel = UILabel()
    titleLabel.textColor = ANIColor.dark
    titleLabel.font = UIFont.boldSystemFont(ofSize: 60.0)
    titleLabel.text = "ANI"
    base.addSubview(titleLabel)
    titleLabel.bottomToTop(of: subTitleLabel, offset: -15.0)
    titleLabel.centerXToSuperview()
    self.titleLabel = titleLabel
    
    //buttonStackView
    let buttonStackView = UIStackView()
    buttonStackView.backgroundColor = .red
    buttonStackView.axis = .horizontal
    buttonStackView.alignment = .center
    buttonStackView.distribution = .fillEqually
    buttonStackView.spacing = 10.0
    base.addSubview(buttonStackView)
    buttonStackView.topToBottom(of: subTitleLabel, offset: 15.0)
    buttonStackView.leftToSuperview(offset: 40.0)
    buttonStackView.rightToSuperview(offset: 40.0)
    self.buttonStackView = buttonStackView
    
    //loginButton
    let loginButton = ANIAreaButtonView()
    loginButton.base?.layer.cornerRadius = LOGIN_BUTTON_HEIGHT / 2
    loginButton.base?.backgroundColor = ANIColor.green
    loginButton.delegate = self
    buttonStackView.addArrangedSubview(loginButton)
    loginButton.height(LOGIN_BUTTON_HEIGHT)
    self.loginButton = loginButton
    
    //loginButtonLabel
    let loginButtonLabel = UILabel()
    loginButtonLabel.textColor = .white
    loginButtonLabel.textAlignment = .center
    loginButtonLabel.text = "ログイン"
    loginButtonLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    loginButton.addContent(loginButtonLabel)
    loginButtonLabel.edgesToSuperview()
    self.loginButtonLabel = loginButtonLabel
    
    //signUpButton
    let signUpButton = ANIAreaButtonView()
    signUpButton.base?.layer.cornerRadius = LOGIN_BUTTON_HEIGHT / 2
    signUpButton.base?.backgroundColor = .white
    signUpButton.base?.layer.borderColor = ANIColor.green.cgColor
    signUpButton.base?.layer.borderWidth = 2.0
    signUpButton.delegate = self
    buttonStackView.addArrangedSubview(signUpButton)
    signUpButton.height(LOGIN_BUTTON_HEIGHT)
    self.signUpButton = signUpButton
    
    //signUpButtonLabel
    let signUpButtonLabel = UILabel()
    signUpButtonLabel.textColor = ANIColor.green
    signUpButtonLabel.textAlignment = .center
    signUpButtonLabel.text = "登録"
    signUpButtonLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    signUpButton.addContent(signUpButtonLabel)
    signUpButtonLabel.edgesToSuperview()
    self.signUpButtonLabel = signUpButtonLabel
    
    //anonymousLabel
    let anonymousLabel = UILabel()
    anonymousLabel.font = UIFont.systemFont(ofSize: 13.0)
    anonymousLabel.textColor = ANIColor.darkGray
    anonymousLabel.text = "ログインしないで始める"
    anonymousLabel.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startAnonymous))
    anonymousLabel.addGestureRecognizer(tapGesture)
    base.addSubview(anonymousLabel)
    anonymousLabel.topToBottom(of: buttonStackView, offset: 15.0)
    anonymousLabel.centerXToSuperview()
    self.anonymousLabel = anonymousLabel
    
    //headerImageView
    let headerImageView = UIImageView()
    headerImageView.image = UIImage(named: "headerImage")
    headerImageView.alpha = 0.25
    addSubview(headerImageView)
    headerImageView.edgesToSuperview(excluding: .bottom)
    headerImageView.bottomToTop(of: base)
    self.headerImageView = headerImageView
    
    //fotterImageView
    let fotterImageView = UIImageView()
    fotterImageView.image = UIImage(named: "footerImage")
    fotterImageView.alpha = 0.25
    addSubview(fotterImageView)
    fotterImageView.edgesToSuperview(excluding: .top)
    fotterImageView.topToBottom(of: base)
    self.fotterImageView = fotterImageView
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
