//
//  ANIProfileClipCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIProfileQnaCell: UITableViewCell {
  var subTitleLabel = UILabel()
  var profileImageView = UIImageView()
  var userNameLabel = UILabel()
  var qnaImagesView = ANIQnaImagesView()
  private weak var loveButton = UIButton()
  var loveCountLabel = UILabel()
  private weak var commentButton = UIButton()
  var commentCountLabel = UILabel()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    
    self.backgroundColor = .white
    //subTitleLabel
    let subTitleLabel = UILabel()
    subTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
    subTitleLabel.textColor = ANIColor.subTitle
    subTitleLabel.numberOfLines = 0
    addSubview(subTitleLabel)
    subTitleLabel.topToSuperview(offset: 10.0)
    subTitleLabel.leftToSuperview(offset: 10.0)
    subTitleLabel.rightToSuperview(offset: 10.0)
    self.subTitleLabel = subTitleLabel
    
    //qnaImagesView
    let qnaImagesView = ANIQnaImagesView()
    addSubview(qnaImagesView)
    qnaImagesView.topToBottom(of: subTitleLabel, offset: 10.0)
    qnaImagesView.leftToSuperview()
    qnaImagesView.rightToSuperview()
    qnaImagesView.height(UIScreen.main.bounds.width / 2 - 30)
    self.qnaImagesView = qnaImagesView
    
    //profileImageView
    let profileImageView = UIImageView()
    addSubview(profileImageView)
    profileImageView.topToBottom(of: qnaImagesView, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(32.0)
    profileImageView.height(32.0)
    profileImageView.layer.cornerRadius = profileImageView.constraints[0].constant / 2
    profileImageView.layer.masksToBounds = true
    self.profileImageView = profileImageView
    
    //bottomSpace
    let spaceView = UIView()
    spaceView.backgroundColor = ANIColor.bg
    addSubview(spaceView)
    spaceView.topToBottom(of: profileImageView, offset: 10)
    spaceView.leftToSuperview()
    spaceView.rightToSuperview()
    spaceView.height(10.0)
    spaceView.bottomToSuperview()
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.font = UIFont.systemFont(ofSize: 13.0)
    userNameLabel.textColor = ANIColor.subTitle
    addSubview(userNameLabel)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToSuperview(offset: 10.0)
    userNameLabel.centerY(to: profileImageView)
    userNameLabel.height(20.0)
    self.userNameLabel = userNameLabel
    
    //commentCountLabel
    let commentCountLabel = UILabel()
    addSubview(commentCountLabel)
    commentCountLabel.centerY(to: profileImageView)
    commentCountLabel.rightToSuperview(offset: 20.0)
    commentCountLabel.width(30.0)
    commentCountLabel.height(20.0)
    self.commentCountLabel = commentCountLabel
    
    //commentButton
    let commentButton = UIButton()
    commentButton.setImage(UIImage(named: "comment"), for: .normal)
    addSubview(commentButton)
    commentButton.centerY(to: profileImageView)
    commentButton.rightToLeft(of: commentCountLabel, offset: -10.0)
    commentButton.width(25.0)
    commentButton.height(24.0)
    self.commentButton = commentButton
    
    //loveCountLabel
    let loveCountLabel = UILabel()
    addSubview(loveCountLabel)
    loveCountLabel.centerY(to: profileImageView)
    loveCountLabel.rightToLeft(of: commentButton, offset: -10.0)
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
  }
}
