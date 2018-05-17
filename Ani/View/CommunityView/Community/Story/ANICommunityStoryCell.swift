//
//  ANIRecruitViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANICommunityStoryCell: UICollectionViewCell {
  private weak var storyView: ANIStoryView?
  
  var storys: [Story]? {
    didSet {
      guard let storyView = self.storyView,
            let storys = self.storys else { return }
      storyView.storys = storys
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let storyView = ANIStoryView()
    addSubview(storyView)
    storyView.edgesToSuperview()
    self.storyView = storyView
  }
}
