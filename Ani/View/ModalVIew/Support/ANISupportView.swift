//
//  ANISuportView.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANISupportViewDelegate {
  func supportButtonTapped()
}

class ANISupportView: UIView {
  
  private weak var titleLabel: UILabel?
  private weak var messageTextView: ANIPlaceHolderTextView?
  private let SUPPORT_BUTTON_HEIGHT: CGFloat = 40.0
  private weak var supportButton: ANIAreaButtonView?
  private weak var supportButtonLabel: UILabel?
  
  var delegate: ANISupportViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //basic
    self.backgroundColor = .white
    self.layer.cornerRadius = 10.0
    self.layer.masksToBounds = true
    
    //titleLabel
    let titleLabel = UILabel()
    titleLabel.textColor = ANIColor.dark
    titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
    titleLabel.text = "応援ありがとうございます😻"
    titleLabel.textAlignment = .center
    addSubview(titleLabel)
    titleLabel.topToSuperview(offset: 15.0)
    titleLabel.leftToSuperview(offset: 15.0)
    titleLabel.rightToSuperview(offset: 15.0)
    self.titleLabel = titleLabel
    
    //supportButton
    let supportButton = ANIAreaButtonView()
    supportButton.base?.backgroundColor = ANIColor.green
    supportButton.baseCornerRadius = SUPPORT_BUTTON_HEIGHT / 2
    supportButton.dropShadow(opacity: 0.1)
    supportButton.delegate = self
    addSubview(supportButton)
    supportButton.bottomToSuperview(offset: -10.0)
    supportButton.leftToSuperview(offset: 100.0)
    supportButton.rightToSuperview(offset: 100.0)
    supportButton.height(SUPPORT_BUTTON_HEIGHT)
    self.supportButton = supportButton
    
    //supportButtonLabel
    let supportButtonLabel = UILabel()
    supportButtonLabel.text = "応援する"
    supportButtonLabel.textAlignment = .center
    supportButtonLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    supportButtonLabel.textColor = .white
    supportButton.addContent(supportButtonLabel)
    supportButtonLabel.edgesToSuperview()
    self.supportButtonLabel = supportButtonLabel
    
    //messageTextView
    let messageTextView = ANIPlaceHolderTextView()
    messageTextView.backgroundColor = ANIColor.bg
    messageTextView.layer.cornerRadius = 10.0
    messageTextView.layer.masksToBounds = true
    messageTextView.textColor = ANIColor.subTitle
    messageTextView.font = UIFont.systemFont(ofSize: 15.0)
    messageTextView.placeHolder = "応援メッセージを書きませんか？"
    addSubview(messageTextView)
    messageTextView.topToBottom(of: titleLabel, offset: 15.0)
    messageTextView.leftToSuperview(offset: 15.0)
    messageTextView.rightToSuperview(offset: 15.0)
    messageTextView.bottomToTop(of: supportButton, offset: -15.0)
    self.messageTextView = messageTextView
  }
}

//MARK: ANIButtonViewDelegate
extension ANISupportView: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === supportButton {
      self.delegate?.supportButtonTapped()
    }
  }
}
