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
}

class ANIInitialView: UIView {
  
  private weak var headerImageView: UIImageView?
  
  private weak var base: UIView?
  private weak var titleLabel: UILabel?
  private weak var subTitleLabel: UILabel?
  
  private let START_BUTTON_HEIGHT: CGFloat = 45.0
  private let START_BUTTON_WIDTH: CGFloat = 150.0
  private weak var startButton: ANIAreaButtonView?
  private weak var startButtonLabel: UILabel?
  
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
    subTitleLabel.centerInSuperview()
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
    
    //startButton
    let startButton = ANIAreaButtonView()
    startButton.base?.layer.cornerRadius = START_BUTTON_HEIGHT / 2
    startButton.base?.backgroundColor = ANIColor.green
    startButton.delegate = self
    addSubview(startButton)
    startButton.height(START_BUTTON_HEIGHT)
    startButton.width(START_BUTTON_WIDTH)
    startButton.topToBottom(of: subTitleLabel, offset: 20.0)
    startButton.centerXToSuperview()
    self.startButton = startButton
    
    //startButtonLabel
    let startButtonLabel = UILabel()
    startButtonLabel.textColor = .white
    startButtonLabel.textAlignment = .center
    startButtonLabel.text = "はじめる"
    startButtonLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    startButton.addContent(startButtonLabel)
    startButtonLabel.edgesToSuperview()
    self.startButtonLabel = startButtonLabel
    
//    //signUpButton
//    let signUpButton = ANIAreaButtonView()
//    signUpButton.base?.layer.cornerRadius = START_BUTTON_HEIGHT / 2
//    signUpButton.base?.backgroundColor = .white
//    signUpButton.base?.layer.borderColor = ANIColor.green.cgColor
//    signUpButton.base?.layer.borderWidth = 2.0
//    signUpButton.delegate = self
//    buttonStackView.addArrangedSubview(signUpButton)
//    signUpButton.height(START_BUTTON_HEIGHT)
//    self.signUpButton = signUpButton
//
//    //signUpButtonLabel
//    let signUpButtonLabel = UILabel()
//    signUpButtonLabel.textColor = ANIColor.green
//    signUpButtonLabel.textAlignment = .center
//    signUpButtonLabel.text = "登録"
//    signUpButtonLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
//    signUpButton.addContent(signUpButtonLabel)
//    signUpButtonLabel.edgesToSuperview()
//    self.signUpButtonLabel = signUpButtonLabel
    
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
}

//MARK: ANIButtonViewDelegate
extension ANIInitialView: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === startButton {
      self.delegate?.loginButtonTapped()
    }
  }
}
