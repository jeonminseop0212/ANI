//
//  ANIRecruitContributeImagesView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIRecruitContributeImagesViewDelegate {
  func imagesPickCellTapped()
}

class ANIRecruitContributeImagesView: UIView {
  
  private weak var imagesViewCollectionView: UICollectionView?
  
  var introduceImages = [UIImage?]() {
    didSet {
      reloadLayout()
    }
  }
  
  var delegate: ANIRecruitContributeImagesViewDelegate?
  
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
    imagesViewCollectionView.delegate = self
    imagesViewCollectionView.dataSource = self
    imagesViewCollectionView.backgroundColor = .white
    imagesViewCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    let id = NSStringFromClass(ANIRecruitContributeImagesCell.self)
    imagesViewCollectionView.register(ANIRecruitContributeImagesCell.self, forCellWithReuseIdentifier: id)
    addSubview(imagesViewCollectionView)
    imagesViewCollectionView.edgesToSuperview()
    self.imagesViewCollectionView = imagesViewCollectionView
  }
  
  private func reloadLayout() {
    guard let imagesViewCollectionView = self.imagesViewCollectionView else { return }
    imagesViewCollectionView.reloadData()
  }
}

extension ANIRecruitContributeImagesView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return introduceImages.count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIRecruitContributeImagesCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIRecruitContributeImagesCell
    
    if indexPath.item < introduceImages.count {
      cell.imageView?.contentMode = .scaleAspectFill
      cell.imageView?.image = introduceImages[indexPath.item]
    } else {
      cell.imageView?.backgroundColor = ANIColor.bg
      cell.imageView?.contentMode = .center
      cell.imageView?.image = UIImage(named: "imagesPickButton")
    }
    
    return cell
  }
}

extension ANIRecruitContributeImagesView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item == introduceImages.count {
      self.delegate?.imagesPickCellTapped()
    }
  }
}

extension ANIRecruitContributeImagesView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
  }
}