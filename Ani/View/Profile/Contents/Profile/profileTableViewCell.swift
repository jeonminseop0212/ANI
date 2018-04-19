//
//  profileTableViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/18.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class profileTableViewCell: UITableViewCell {
  
  private weak var nameLabel: UILabel?
  private weak var updateButton: UIButton?
  private weak var groupLabel: UILabel?
  private weak var introductionLabel: UILabel?
  private weak var twitterURLLabel: UILabel?
  private weak var instaURLLabel: UILabel?
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    backgroundColor = .clear
    self.selectionStyle = .none
    
    //nameLabel
    let nameLabel = UILabel()
    nameLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    nameLabel.textColor = ANIColor.dark
    nameLabel.numberOfLines = 0
    nameLabel.text = "jeonminseop"
    addSubview(nameLabel)
    nameLabel.topToSuperview(offset: 10.0)
    nameLabel.leftToSuperview(offset: 10.0)
    self.nameLabel = nameLabel

    //updateButton
    let updateButton = UIButton()
    updateButton.setTitle("更新", for: .normal)
    updateButton.setTitleColor(ANIColor.green, for: .normal)
    updateButton.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
    updateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
    updateButton.layer.cornerRadius = 5.0
    updateButton.layer.masksToBounds = true
    updateButton.layer.borderWidth = 1.0
    updateButton.layer.borderColor = ANIColor.green.cgColor
    updateButton.backgroundColor = .clear
    addSubview(updateButton)
    updateButton.topToSuperview(offset: 10.0)
    updateButton.rightToSuperview(offset: 10.0)
    updateButton.width(40.0)
    updateButton.height(20.0)
    self.updateButton = updateButton

    nameLabel.rightToLeft(of: updateButton, offset: 10.0)

    //groupLabel
    let groupLabel = UILabel()
    groupLabel.font = UIFont.systemFont(ofSize: 17.0)
    groupLabel.text = "個人"
    groupLabel.textColor = ANIColor.dark
    addSubview(groupLabel)
    groupLabel.topToBottom(of: nameLabel, offset: 10.0)
    groupLabel.leftToSuperview(offset: 10.0)
    self.groupLabel = groupLabel

    //introductionLabel
    let introductionLabel = UILabel()
    groupLabel.font = UIFont.systemFont(ofSize: 17.0)
    introductionLabel.numberOfLines = 0
    introductionLabel.text = "私はどのこのここに初回文を書くよあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれあれこれ"
    introductionLabel.textColor = ANIColor.dark
    addSubview(introductionLabel)
    introductionLabel.topToBottom(of: groupLabel, offset: 10.0)
    introductionLabel.leftToSuperview(offset: 10.0)
    introductionLabel.rightToSuperview(offset: 10.0)
    self.introductionLabel = introductionLabel

    //twitterURLLabel
    let twitterURLLabel = UILabel()
    twitterURLLabel.numberOfLines = 0
    twitterURLLabel.text = "www.twitter.com"
    twitterURLLabel.textColor = ANIColor.dark
    addSubview(twitterURLLabel)
    twitterURLLabel.topToBottom(of: introductionLabel, offset: 10.0)
    twitterURLLabel.leftToSuperview(offset: 10.0)
    twitterURLLabel.rightToSuperview(offset: 10.0)
    self.twitterURLLabel = twitterURLLabel
    
    //instaURLLabel
    let instaURLLabel = UILabel()
    instaURLLabel.numberOfLines = 0
    instaURLLabel.text = "www.insta.com"
    instaURLLabel.textColor = ANIColor.dark
    addSubview(instaURLLabel)
    instaURLLabel.topToBottom(of: twitterURLLabel, offset: 10.0)
    instaURLLabel.leftToSuperview(offset: 10.0)
    instaURLLabel.rightToSuperview(offset: 10.0)
    instaURLLabel.bottomToSuperview()
    self.instaURLLabel = instaURLLabel
  }
  
  @objc private func updateProfile() {
    print("update profile")
  }
}
