//
//  ANIMyChatViewCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/27.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIMyChatViewCell: UITableViewCell {
  
  private weak var base: UIView?
  private weak var messageLabel: UILabel?
  
  var message: FirebaseChatMessage? {
    didSet {
      reloadLayout()
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    
    //base
    let base = UIView()
    base.backgroundColor = ANIColor.bg
    base.layer.cornerRadius = 10.0
    base.layer.masksToBounds = true
    addSubview(base)
    let width = UIScreen.main.bounds.width * 0.7
    base.topToSuperview(offset: 5.0)
    base.rightToSuperview(offset: 10.0)
    base.bottomToSuperview(offset: -5.0)
    base.width(min: 0.0, max: width)
    self.base = base
    
    //messageLabel
    let messageLabel = UILabel()
    messageLabel.font = UIFont.systemFont(ofSize: 15.0)
    messageLabel.textColor = ANIColor.dark
    messageLabel.numberOfLines = 0
    base.addSubview(messageLabel)
    let labelInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
    messageLabel.edgesToSuperview(insets: labelInsets)
    self.messageLabel = messageLabel
  }
  
  private func reloadLayout() {
    guard let messageLabel = self.messageLabel,
          let message = self.message,
          let text = message.message else { return }
    
    messageLabel.text = text
  }
}
