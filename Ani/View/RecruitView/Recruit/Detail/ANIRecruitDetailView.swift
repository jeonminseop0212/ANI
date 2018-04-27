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
  
  private weak var titleLabel: UILabel?
  
  var delegate: ANIRecruitDetailViewDelegate?
  
  var testRecruit: Recruit? {
    didSet {
      reloadLayout()
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
    self.backgroundColor = .white
    
    let headerImageView = UIImageView()
    addSubview(headerImageView)
    headerImageViewTopConstraint = headerImageView.topToSuperview()
    headerImageView.leftToSuperview()
    headerImageView.rightToSuperview()
    headerImageView.height(HEADER_IMAGE_VIEW_HEIGHT)
    self.headerImageView = headerImageView
    
    let scrollView = UIScrollView()
    scrollView.delegate = self
    let topInset = HEADER_IMAGE_VIEW_HEIGHT
    scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    scrollView.scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    addSubview(scrollView)
    scrollView.edgesToSuperview()
    self.scrollView = scrollView
    
    let contentView = UIView()
    scrollView.addSubview(contentView)
    contentView.topToSuperview()
    contentView.leftToSuperview()
    contentView.rightToSuperview()
    contentView.bottomToSuperview()
    contentView.width(to: scrollView)
    contentView.height(1000)
    self.contentView = contentView
    
    let titleLabel = UILabel()
    titleLabel.numberOfLines = 0
    titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    titleLabel.textColor = ANIColor.dark
    contentView.addSubview(titleLabel)
    titleLabel.topToSuperview(offset: 10.0)
    titleLabel.leftToSuperview(offset: 10.0)
    titleLabel.rightToSuperview(offset: 10.0)
    self.titleLabel = titleLabel
  }
  
  private func reloadLayout() {
    guard let testRecruit = self.testRecruit,
          let headerImageView = self.headerImageView,
          let titleLabel = self.titleLabel else { return }
    
    headerImageView.image = testRecruit.recruitImage
    titleLabel.text = testRecruit.title
  }
}

extension ANIRecruitDetailView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let imageView = self.headerImageView,
          let imageViewTopConstraint = self.headerImageViewTopConstraint,
          let headerMinHeight = self.headerMinHeight
          else { return }
    
    let scrollY = scrollView.contentOffset.y
    let newScrollY = scrollY + HEADER_IMAGE_VIEW_HEIGHT
    
    //imageView animation
    if newScrollY < 0 {
      let scaleRatio = 1 - newScrollY / HEADER_IMAGE_VIEW_HEIGHT
      imageView.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
      imageViewTopConstraint.constant = 0
    }
    else {
      imageView.transform = CGAffineTransform.identity
      if HEADER_IMAGE_VIEW_HEIGHT - newScrollY > headerMinHeight {
        imageViewTopConstraint.constant = -newScrollY
        self.layoutIfNeeded()
      } else {
        imageViewTopConstraint.constant = -(HEADER_IMAGE_VIEW_HEIGHT - headerMinHeight)
        self.layoutIfNeeded()
      }
    }
    
    //navigation bar animation
    let offset = newScrollY / (HEADER_IMAGE_VIEW_HEIGHT - headerMinHeight)
    self.delegate?.recruitDetailViewDidScroll(offset: offset)
  }
}

