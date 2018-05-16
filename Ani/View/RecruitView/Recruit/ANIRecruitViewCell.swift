//
//  ANIRecruitViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIRecruitViewCell: UITableViewCell {
  var recruitImageView = UIImageView()
  var titleLabel = UILabel()
  var subTitleLabel = UILabel()
  private let PROFILE_IMAGE_HEIGHT: CGFloat = 32.0
  var profileImageView = UIImageView()
  var userNameLabel = UILabel()
  var supportCountLabel = UILabel()
  var supportButton = UIButton()
  var loveButton = UIButton()
  var loveCountLabel = UILabel()
  var clipButton = UIButton()
  var line = UIImageView()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    //recruitImageView
    let recruitImageView = UIImageView()
    recruitImageView.contentMode = .redraw
    addSubview(recruitImageView)
    let recruitImageViewHeight: CGFloat = UIScreen.main.bounds.width * UIViewController.HEADER_IMAGE_VIEW_RATIO
    recruitImageView.topToSuperview()
    recruitImageView.leftToSuperview()
    recruitImageView.rightToSuperview()
    recruitImageView.height(recruitImageViewHeight)
    self.recruitImageView = recruitImageView
    
    //titleLabel
    let titleLabel = UILabel()
    titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    titleLabel.textAlignment = .left
    titleLabel.textColor = ANIColor.dark
    addSubview(titleLabel)
    titleLabel.topToBottom(of: recruitImageView, offset: 10.0)
    titleLabel.leftToSuperview(offset: 10.0)
    titleLabel.rightToSuperview(offset: 10.0)
    titleLabel.height(20.0)
    self.titleLabel = titleLabel
    
    //subTitleLabel
    let subTitleLabel = UILabel()
    subTitleLabel.numberOfLines = 3
    subTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
    subTitleLabel.textColor = ANIColor.subTitle
    addSubview(subTitleLabel)
    subTitleLabel.topToBottom(of: titleLabel, offset: 10.0)
    subTitleLabel.leftToSuperview(offset: 10.0)
    subTitleLabel.rightToSuperview(offset: 10.0)
    self.subTitleLabel = subTitleLabel
    
    //profileImageView
    let profileImageView = UIImageView()
    addSubview(profileImageView)
    profileImageView.topToBottom(of: subTitleLabel, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(PROFILE_IMAGE_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_HEIGHT)
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    self.profileImageView = profileImageView
    
    //clipButton
    let clipButton = UIButton()
    clipButton.setImage(UIImage(named: "clip"), for: .normal)
    addSubview(clipButton)
    clipButton.centerY(to: profileImageView)
    clipButton.rightToSuperview(offset: 20.0)
    clipButton.width(21.0)
    clipButton.height(21.0)
    self.clipButton = clipButton
    
    //loveCountLabel
    let loveCountLabel = UILabel()
    addSubview(loveCountLabel)
    loveCountLabel.centerY(to: profileImageView)
    loveCountLabel.rightToLeft(of: clipButton, offset: -10.0)
    loveCountLabel.width(30.0)
    loveCountLabel.height(20.0)
    self.loveCountLabel = loveCountLabel
    
    //loveButton
    let loveButton = UIButton()
    loveButton.setImage(UIImage(named: "love"), for: .normal)
    addSubview(loveButton)
    loveButton.centerY(to: profileImageView)
    loveButton.rightToLeft(of: loveCountLabel, offset: -10.0)
    loveButton.width(21.0)
    loveButton.height(21.0)
    self.loveButton = loveButton
    
    //supportCountLabel
    let supportCountLabel = UILabel()
    addSubview(supportCountLabel)
    supportCountLabel.centerY(to: profileImageView)
    supportCountLabel.rightToLeft(of: loveButton, offset: -10.0)
    supportCountLabel.width(30.0)
    supportCountLabel.height(20.0)
    self.supportCountLabel = supportCountLabel
    
    //supportButton
    let supportButton = UIButton()
    supportButton.setImage(UIImage(named: "support"), for: .normal)
    addSubview(supportButton)
    supportButton.centerY(to: profileImageView)
    supportButton.rightToLeft(of: supportCountLabel, offset: -10.0)
    supportButton.width(21.0)
    supportButton.height(21.0)
    self.supportButton = supportButton
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.font = UIFont.systemFont(ofSize: 13.0)
    userNameLabel.textColor = ANIColor.subTitle
    addSubview(userNameLabel)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToLeft(of: supportButton, offset: 10.0)
    userNameLabel.centerY(to: profileImageView)
    userNameLabel.height(20.0)
    self.userNameLabel = userNameLabel
    
    //line
    let line = UIImageView()
    line.image = UIImage(named: "line")
    addSubview(line)
    line.topToBottom(of: profileImageView, offset: 10.0)
    line.leftToSuperview()
    line.rightToSuperview()
    line.height(0.5)
    line.bottomToSuperview()
    self.line = line
  }
}
