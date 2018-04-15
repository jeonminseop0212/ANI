//
//  ANINotiViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/15.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANINotiViewCell: UICollectionViewCell {
  
  var profileImageView: UIImageView?
  var subTitleLabel: UILabel?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    contentView.backgroundColor = .white
    //profileImageView
    let profileImageView = UIImageView()
    addSubview(profileImageView)
    profileImageView.topToSuperview(offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(50.0)
    profileImageView.height(50.0)
    profileImageView.layer.cornerRadius = profileImageView.constraints[0].constant / 2
    profileImageView.layer.masksToBounds = true
    self.profileImageView = profileImageView

    //subTitleLabel
    let subTitleLabel = UILabel()
    subTitleLabel.numberOfLines = 0
    subTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
    subTitleLabel.textColor = ANIColor.subTitle
    addSubview(subTitleLabel)
    subTitleLabel.topToSuperview(offset: 10.0)
    subTitleLabel.leftToRight(of: profileImageView, offset: 10.0)
    subTitleLabel.rightToSuperview(offset: 10.0)
    self.subTitleLabel = subTitleLabel
  }
}
