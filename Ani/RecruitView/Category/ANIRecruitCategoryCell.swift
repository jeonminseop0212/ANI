//
//  CollectionViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/05.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIRecruitCategoryCell: UICollectionViewCell {
  var categoryLabel: UILabel?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let categoryLabel = UILabel()
    categoryLabel.textAlignment = .center
    categoryLabel.textColor = ANIColor.dark
    addSubview(categoryLabel)
    categoryLabel.edgesToSuperview()
    self.categoryLabel = categoryLabel
  }
  
  static func sizeWithCategory(category: String?) -> CGSize {
    guard let category = category else { return .zero }
    let tempLabel = UILabel()
    tempLabel.text = category
    tempLabel.sizeToFit()
    return CGSize(width: tempLabel.frame.width + 30.0, height: tempLabel.frame.height + 10.0)
  }
}
