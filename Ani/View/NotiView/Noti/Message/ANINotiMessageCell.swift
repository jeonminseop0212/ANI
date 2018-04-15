//
//  ANINotiMessageCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/14.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANINotiMessageCell: UICollectionViewCell {
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    backgroundColor = .yellow
  }
}
