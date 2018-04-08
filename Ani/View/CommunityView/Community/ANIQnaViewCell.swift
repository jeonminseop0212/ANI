//
//  ANICommunityViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIQnaViewCell: UICollectionViewCell {
  private weak var qnaView: ANIQnaView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let qnaView = ANIQnaView()
    addSubview(qnaView)
    qnaView.edgesToSuperview()
    self.qnaView = qnaView
  }
}

