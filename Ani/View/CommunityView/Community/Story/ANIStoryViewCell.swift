//
//  ANIRecruitViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIStoryViewCell: UICollectionViewCell {
  var storyImagesView = ANIStoryImagesView()
  var titleLabel = UILabel()
  var subTitleTextView = UITextView()
  var line = UIImageView()
  var profileImageView = UIImageView()
  var userNameLabel = UILabel()
  var loveButton = UIButton()
  var loveCountLabel = UILabel()
  var commentButton = UIButton()
  var commentCountLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //storyImageView
    let storyImagesView = ANIStoryImagesView()
    addSubview(storyImagesView)
    storyImagesView.topToSuperview()
    storyImagesView.leftToSuperview()
    storyImagesView.rightToSuperview()
    storyImagesView.height(200.0 + ANIStoryImagesView.PAGE_CONTROL_HEIGHT)
    self.storyImagesView = storyImagesView
    
    //titleLabel
    let titleLabel = UILabel()
    titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    titleLabel.textAlignment = .left
    titleLabel.textColor = ANIColor.dark
    addSubview(titleLabel)
    titleLabel.topToBottom(of: storyImagesView, offset: 10.0)
    titleLabel.leftToSuperview(offset: 10.0)
    titleLabel.rightToSuperview(offset: 10.0)
    titleLabel.height(20.0)
    self.titleLabel = titleLabel

    //subTitleTextView
    let subTitleTextView = UITextView()
    subTitleTextView.font = UIFont.systemFont(ofSize: 14.0)
    subTitleTextView.textAlignment = .left
    subTitleTextView.isScrollEnabled = false
    subTitleTextView.textColor = ANIColor.subTitle
    subTitleTextView.isEditable = false
    addSubview(subTitleTextView)
    subTitleTextView.topToBottom(of: titleLabel, offset: 2.0)
    subTitleTextView.leftToSuperview(offset: 5.0)
    subTitleTextView.rightToSuperview(offset: 5.0)
    subTitleTextView.height(60.0)
    self.subTitleTextView = subTitleTextView

    //profileImageView
    let profileImageView = UIImageView()
    addSubview(profileImageView)
    profileImageView.topToBottom(of: subTitleTextView, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(32.0)
    profileImageView.height(32.0)
    profileImageView.layer.cornerRadius = profileImageView.constraints[0].constant / 2
    profileImageView.layer.masksToBounds = true
    self.profileImageView = profileImageView

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

    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.font = UIFont.systemFont(ofSize: 13.0)
    userNameLabel.textColor = ANIColor.subTitle
    addSubview(userNameLabel)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToLeft(of: loveButton, offset: 10.0)
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
    self.line = line
  }
}

