//
//  ANIMyChatViewCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/27.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIMyChatViewCell: UITableViewCell {
  
  private weak var stackView: UIStackView?
  private weak var dateLabel: UILabel?
  private weak var base: UIView?
  private weak var messageBG: UIView?
  private weak var messageLabel: UILabel?
  private weak var timeLabel: UILabel?
  
  var message: FirebaseChatMessage?
  
  var chagedDate: String? {
    didSet {
      reloadLayout()
    }
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    
    //stackView
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    addSubview(stackView)
    stackView.edgesToSuperview()
    self.stackView = stackView
    
    //dateLabel
    let dateLabel = UILabel()
    dateLabel.backgroundColor = .white
    dateLabel.textColor = ANIColor.darkGray
    dateLabel.font = UIFont.systemFont(ofSize: 15)
    dateLabel.textAlignment = .center
    dateLabel.isHidden = true
    stackView.addArrangedSubview(dateLabel)
    self.dateLabel = dateLabel
    
    //base
    let base = UIView()
    stackView.addArrangedSubview(base)
    self.base = base
    
    //messageBG
    let messageBG = UIView()
    messageBG.backgroundColor = ANIColor.moreDarkGray
    messageBG.layer.cornerRadius = 10.0
    messageBG.layer.masksToBounds = true
    base.addSubview(messageBG)
    let width = UIScreen.main.bounds.width * 0.7
    messageBG.topToSuperview(offset: 5.0)
    messageBG.rightToSuperview(offset: -10.0)
    messageBG.bottomToSuperview(offset: -5.0)
    messageBG.width(min: 0.0, max: width)
    self.messageBG = messageBG

    //messageLabel
    let messageLabel = UILabel()
    messageLabel.font = UIFont.systemFont(ofSize: 15.0)
    messageLabel.textColor = .white
    messageLabel.numberOfLines = 0
    messageBG.addSubview(messageLabel)
    let labelInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    messageLabel.edgesToSuperview(insets: labelInsets)
    self.messageLabel = messageLabel
    
    //timeLabel
    let timeLabel = UILabel()
    timeLabel.textColor = ANIColor.darkGray
    timeLabel.font = UIFont.systemFont(ofSize: 13)
    base.addSubview(timeLabel)
    timeLabel.rightToLeft(of: messageBG, offset: -4.0)
    timeLabel.bottom(to: messageBG)
    self.timeLabel = timeLabel
  }
  
  private func reloadLayout() {
    guard let dateLabel = self.dateLabel,
          let messageLabel = self.messageLabel,
          let message = self.message,
          let text = message.message,
          let timeLabel = self.timeLabel,
          let date = message.date else { return }
    
    dateLabel.isHidden = true
    if let chagedDate = self.chagedDate {
      dateLabel.isHidden = false
      dateLabel.text = chagedDate
    } else {
      dateLabel.isHidden = true
    }
    
    messageLabel.text = text
    
    let suffixString = String(date.suffix(8))
    timeLabel.text = String(suffixString.prefix(5))
  }
}
