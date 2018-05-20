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
    imageView.contentMode = .scaleAspectFit
    imageViewBG.addSubview(imageView)
    imageView.layer.cornerRadius = FAMILY_IMAGE_VIEW_BG_HEIGHT / 2
    imageView.layer.masksToBounds = true
    imageView.edgesToSuperview()
    self.familyImageView = imageView
    
    //imagePickImageView
    let imagePickImageView = UIImageView()
    imagePickImageView.contentMode = .scaleAspectFit
    imagePickImageView.image = UIImage(named: "imagePickButton")
    imageViewBG.addSubview(imagePickImageView)
    imagePickImageView.width(25.0)
    imagePickImageView.height(25.0)
    imagePickImageView.rightToSuperview()
    imagePickImageView.bottomToSuperview()
    self.imagePickImageView = imagePickImageView
  }
}
