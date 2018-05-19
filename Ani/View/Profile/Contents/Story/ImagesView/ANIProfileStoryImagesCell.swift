//
//  ANIProfileStoryImagesViewCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIProfileStoryImagesCell: UICollectionViewCell {
  var imageView: UIImageView?
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    addSubview(imageView)
    imageView.edgesToSuperview()
    self.imageView = imageView
  }
}
