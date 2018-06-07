//
//  ANIStoryImagesViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIStoryImagesCell: UICollectionViewCell {
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
    imageView.backgroundColor = ANIColor.bg
    imageView.contentMode = .scaleAspectFit
    addSubview(imageView)
    imageView.edgesToSuperview()
    self.imageView = imageView
  }
}
