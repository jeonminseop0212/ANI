//
//  ANIRecruitDetailView.swift
//  Ani
//
//  Created by jeonminseop on 2018/04/26.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

protocol ANIRecruitDetailViewDelegate {
  func recruitDetailViewDidScroll(offset: CGFloat)
}

class ANIRecruitDetailView: UIView {
  
  private let HEADER_IMAGE_VIEW_HEIGHT: CGFloat = 150.0
  private weak var headerImageView: UIImageView?
  private var headerImageViewTopConstraint: Constraint?
  var headerMinHeight: CGFloat?

  private weak var scrollView: UIScrollView?
  private weak var contentView: UIView?
  
  var delegete: ANIRecruitDetailViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = .white
    
    let headerImageView = UIImageView()
    headerImageView.image = UIImage(named: "cat1")
    addSubview(headerImageView)
    headerImageViewTopConstraint = headerImageView.topToSuperview()
    headerImageView.leftToSuperview()
    headerImageView.rightToSuperview()
    headerImageView.height(HEADER_IMAGE_VIEW_HEIGHT)
    self.headerImageView = headerImageView
    
    let scrollView = UIScrollView()
    scrollView.delegate = self
    addSubview(scrollView)
    scrollView.topToBottom(of: headerImageView)
    scrollView.leftToSuperview()
    scrollView.rightToSuperview()
    scrollView.bottomToSuperview()
    self.scrollView = scrollView
    
    let contentView = UIView()
    scrollView.addSubview(contentView)
    contentView.edgesToSuperview()
    contentView.width(to: scrollView)
    contentView.height(1000)
    self.contentView = contentView
  }
}

extension ANIRecruitDetailView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let imageView = self.headerImageView,
          let imageViewTopConstraint = self.headerImageViewTopConstraint,
          let headerMinHeight = self.headerMinHeight
          else { return }
    
    let scrollY = scrollView.contentOffset.y
    
    //imageView animation
    if scrollY <= 0 {
      let scaleRatio = 1 - scrollY / HEADER_IMAGE_VIEW_HEIGHT
      imageView.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
      imageViewTopConstraint.constant = 0
    } else {
      if HEADER_IMAGE_VIEW_HEIGHT - scrollY > headerMinHeight {
        imageViewTopConstraint.constant = -scrollY
        self.layoutIfNeeded()
      } else {
        imageViewTopConstraint.constant = -(HEADER_IMAGE_VIEW_HEIGHT - headerMinHeight)
        self.layoutIfNeeded()
      }
    }
    print("scrollY \(scrollY)")
    //navigation bar animation
    let offset = scrollY / (HEADER_IMAGE_VIEW_HEIGHT - headerMinHeight)
    self.delegete?.recruitDetailViewDidScroll(offset: offset)
  }
}

