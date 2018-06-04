//
//  ANIFamilyViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIFamilyViewCell: UICollectionViewCell {
  
  private let FAMILY_IMAGE_VIEW_BG_HEIGHT: CGFloat = 80.0
  private weak var familyImageViewBG: UIView?
  
  weak var familyImageView: UIImageView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let imageViewBG = UIView()
    addSubview(imageViewBG)
    imageViewBG.width(FAMILY_IMAGE_VIEW_BG_HEIGHT)
    imageViewBG.height(FAMILY_IMAGE_VIEW_BG_HEIGHT)
    imageViewBG.centerInSuperview()
    self.familyImageViewBG = imageViewBG
    
    let imageView = UIImageView()
    imageViewBG.addSubview(imageView)
    imageView.layer.cornerRadius = FAMILY_IMAGE_VIEW_BG_HEIGHT / 2
    imageView.layer.masksToBounds = true
    imageView.edgesToSuperview()
    self.familyImageView = imageView
  }
}
