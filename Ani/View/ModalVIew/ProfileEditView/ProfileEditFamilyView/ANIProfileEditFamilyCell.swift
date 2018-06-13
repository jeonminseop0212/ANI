//
//  ANIProfileEditFamilyCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIProfileEditFamilyCell: UICollectionViewCell {
  
  private let FAMILY_IMAGE_VIEW_BG_HEIGHT: CGFloat = 80.0
  private weak var familyImageViewBG: UIView?
  weak var familyImageView: UIImageView?
  private let IMAGE_PICK_IMAGE_VIEW_HEGITH: CGFloat = 25.0
  weak var imagePickImageView: UIImageView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //imageViewBG
    let imageViewBG = UIView()
    addSubview(imageViewBG)
    imageViewBG.width(FAMILY_IMAGE_VIEW_BG_HEIGHT)
    imageViewBG.height(FAMILY_IMAGE_VIEW_BG_HEIGHT)
    imageViewBG.centerInSuperview()
    self.familyImageViewBG = imageViewBG
    
    //imageView
    let imageView = UIImageView()
    imageView.backgroundColor = ANIColor.bg
    imageView.contentMode = .scaleAspectFit
    imageViewBG.addSubview(imageView)
    imageView.layer.cornerRadius = FAMILY_IMAGE_VIEW_BG_HEIGHT / 2
    imageView.layer.masksToBounds = true
    imageView.edgesToSuperview()
    self.familyImageView = imageView
    
    //imagePickImageView
    let imagePickImageView = UIImageView()
    imagePickImageView.backgroundColor = ANIColor.bg
    imagePickImageView.contentMode = .scaleAspectFit
    imagePickImageView.image = UIImage(named: "imagePickButton")
    imagePickImageView.layer.cornerRadius = IMAGE_PICK_IMAGE_VIEW_HEGITH / 2
    imagePickImageView.layer.masksToBounds = true
    imageViewBG.addSubview(imagePickImageView)
    imagePickImageView.width(IMAGE_PICK_IMAGE_VIEW_HEGITH)
    imagePickImageView.height(IMAGE_PICK_IMAGE_VIEW_HEGITH)
    imagePickImageView.rightToSuperview()
    imagePickImageView.bottomToSuperview()
    self.imagePickImageView = imagePickImageView
  }
}
