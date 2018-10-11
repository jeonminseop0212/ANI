//
//  ANIFamilyViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIFamilyViewCell: UICollectionViewCell {
  
  private let FAMILY_BIG_IMAGE_VIEW_HEIGHT: CGFloat = 80.0
  weak var familyBigImageView: UIImageView?
  private let FAMILY_SMALL_IMAGE_VIEW_HEIGHT: CGFloat = 69.0
  weak var familySmallImageVIew: UIImageView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //familyBigImageView
    let familyBigImageView = UIImageView()
    familyBigImageView.contentMode = .scaleAspectFill
    familyBigImageView.backgroundColor = .clear
    familyBigImageView.layer.cornerRadius = FAMILY_BIG_IMAGE_VIEW_HEIGHT / 2
    familyBigImageView.layer.masksToBounds = true
    addSubview(familyBigImageView)
    familyBigImageView.width(FAMILY_BIG_IMAGE_VIEW_HEIGHT)
    familyBigImageView.height(FAMILY_BIG_IMAGE_VIEW_HEIGHT)
    familyBigImageView.centerInSuperview()
    self.familyBigImageView = familyBigImageView
    
    //familySmallImageVIew
    let familySmallImageVIew = UIImageView()
    familySmallImageVIew.contentMode = .scaleAspectFill
    familySmallImageVIew.backgroundColor = ANIColor.gray
    familySmallImageVIew.layer.cornerRadius = FAMILY_SMALL_IMAGE_VIEW_HEIGHT / 2
    familySmallImageVIew.layer.masksToBounds = true
    familyBigImageView.addSubview(familySmallImageVIew)
    familySmallImageVIew.width(FAMILY_SMALL_IMAGE_VIEW_HEIGHT)
    familySmallImageVIew.height(FAMILY_SMALL_IMAGE_VIEW_HEIGHT)
    familySmallImageVIew.centerInSuperview()
    self.familySmallImageVIew = familySmallImageVIew
  }
}
