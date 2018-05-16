//
//  ANIRecruitDetailImagesView.swift
//  Ani
//
//  Created by jeonminseop on 2018/04/28.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import Photos

class ANIRecruitDetailImagesView: UIView {
  
  private weak var imagesViewCollectionView: UICollectionView?
  
  var testIntroduceImages = [UIImage]() {
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
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    let imagesViewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    imagesViewCollectionView.alwaysBounceHorizontal = true
    imagesViewCollectionView.showsHorizontalScrollIndicator = false
    imagesViewCollectionView.dataSource = self
    imagesViewCollectionView.delegate = self
    imagesViewCollectionView.backgroundColor = .white
    imagesViewCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    let id = NSStringFromClass(ANIRecruitDetailImagesViewCell.self)
    imagesViewCollectionView.register(ANIRecruitDetailImagesViewCell.self, forCellWithReuseIdentifier: id)
    addSubview(imagesViewCollectionView)
    imagesViewCollectionView.edgesToSuperview()
    self.imagesViewCollectionView = imagesViewCollectionView
  }
  
  private func reloadLayout() {
    guard let imagesViewCollectionView = self.imagesViewCollectionView else { return }
    imagesViewCollectionView.reloadData()
  }
}

extension ANIRecruitDetailImagesView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testIntroduceImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIRecruitDetailImagesViewCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIRecruitDetailImagesViewCell
    
    cell.imageView?.image = testIntroduceImages[indexPath.item]
    
    return cell
  }
}

extension ANIRecruitDetailImagesView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
  }
}