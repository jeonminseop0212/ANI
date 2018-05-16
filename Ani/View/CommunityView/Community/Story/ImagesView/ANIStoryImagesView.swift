//
//  ANIStoryImagesView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIStoryImagesView: UIView {
  
  private weak var imagesCollectionView: UICollectionView?
  weak var pageControl: UIPageControl?
  static let PAGE_CONTROL_HEIGHT: CGFloat = 30.0
  
  var images = [UIImage]() {
    didSet {
      for subview in self.subviews{
        subview.removeFromSuperview()
      }
      setup()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //iamgesCollectionView
    let flowLayot = UICollectionViewFlowLayout()
    flowLayot.scrollDirection = .horizontal
    flowLayot.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    flowLayot.minimumLineSpacing = 0
    flowLayot.minimumInteritemSpacing = 0
    let imagesCollectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayot)
    imagesCollectionView.delegate = self
    imagesCollectionView.dataSource = self
    imagesCollectionView.isPagingEnabled = true
    imagesCollectionView.showsHorizontalScrollIndicator = false
    imagesCollectionView.backgroundColor = .white
    let id = NSStringFromClass(ANIStoryImagesViewCell.self)
    imagesCollectionView.register(ANIStoryImagesViewCell.self, forCellWithReuseIdentifier: id)
    addSubview(imagesCollectionView)
    imagesCollectionView.topToSuperview()
    imagesCollectionView.leftToSuperview()
    imagesCollectionView.rightToSuperview()
    imagesCollectionView.bottomToSuperview(offset: -ANIStoryImagesView.PAGE_CONTROL_HEIGHT)
    self.imagesCollectionView = imagesCollectionView
    
    //pageControl
    let pageControl = UIPageControl()
    pageControl.pageIndicatorTintColor = ANIColor.gray
    pageControl.currentPageIndicatorTintColor = ANIColor.green
    pageControl.currentPage = 0
    pageControl.isUserInteractionEnabled = false
    addSubview(pageControl)
    pageControl.topToBottom(of: imagesCollectionView, offset: 8.0)
    pageControl.leftToSuperview()
    pageControl.rightToSuperview()
    pageControl.height(ANIStoryImagesView.PAGE_CONTROL_HEIGHT)
    self.pageControl = pageControl
  }
}

extension ANIStoryImagesView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIStoryImagesViewCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIStoryImagesViewCell
    cell.imageView?.image = images[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    return size
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard let pageControl = self.pageControl else { return }
    pageControl.currentPage = Int(targetContentOffset.pointee.x / pageControl.frame.width)
  }
}
