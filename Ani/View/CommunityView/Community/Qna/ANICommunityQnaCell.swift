//
//  ANICommunityViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANICommunityQnaCell: UICollectionViewCell {
  private weak var qnaView: ANIQnaView?
  
  var qnas: [Qna]? {
    didSet {
      guard let qnaView = self.qnaView,
        let qnas = self.qnas else { return }
      qnaView.qnas = qnas
    }
  }
  
  var delegate: ANIQnaViewDelegate? {
    get { return self.qnaView?.delegate }
    set(v) { self.qnaView?.delegate = v }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = ANIColor.bg
    
    let qnaView = ANIQnaView()
    addSubview(qnaView)
    qnaView.edgesToSuperview()
    self.qnaView = qnaView
  }
}

