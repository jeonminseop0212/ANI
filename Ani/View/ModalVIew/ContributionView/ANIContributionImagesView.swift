//
//  ANIContributionImagesView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIContributionImagesViewDelegate {
  func imagesPickCellTapped()
  func imageDelete(index: Int)
}

class ANIContributionImagesView: UIView {
  
  private weak var imagesViewCollectionView: UICollectionView?
  
  var contentImages = [UIImage?]() {
    didSet {
      reloadLayout()
    }
  }
  
  var delegate: ANIContributionImagesViewDelegate?
  
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
    let id = NSStringFromClass(ANIContributionImagesCell.self)
    imagesViewCollectionView.register(ANIContributionImagesCell.self, forCellWithReuseIdentifier: id)
    addSubview(imagesViewCollectionView)
    imagesViewCollectionView.edgesToSuperview()
    self.imagesViewCollectionView = imagesViewCollectionView
  }
  
  private func reloadLayout() {
    guard let imagesViewCollectionView = self.imagesViewCollectionView else { return }
    imagesViewCollectionView.reloadData()
  }
}

extension ANIContributionImagesView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return contentImages.count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIContributionImagesCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIContributionImagesCell
    
    if indexPath.item < contentImages.count {
      cell.imageView?.contentMode = .scaleAspectFill
      cell.imageView?.image = contentImages[indexPath.item]
      cell.deleteButton?.alpha = 1.0
      cell.deleteButton?.tag = indexPath.row
      cell.delegate = self
    } else {
      cell.imageView?.backgroundColor = ANIColor.bg
      cell.imageView?.contentMode = .center
      cell.imageView?.image = UIImage(named: "imagesPickButton")
      cell.deleteButton?.alpha = 0.0
    }
    
    return cell
  }
}

//MARK: UICollectionViewDelegate
extension ANIContributionImagesView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item == contentImages.count {
      self.delegate?.imagesPickCellTapped()
    }
  }
}

//MARK: UICollectionViewDelegateFlowLayout
extension ANIContributionImagesView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if contentImages.isEmpty {
      let sideInset: CGFloat = 20.0
      collectionView.isScrollEnabled = false
      return CGSize(width: collectionView.frame.width - sideInset, height: collectionView.frame.height)
    } else {
      collectionView.isScrollEnabled = true
      return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
  }
}

extension ANIContributionImagesView: ANIContributionImagesCellDelegate {
  func deleteButtonTapped(index: Int) {
    self.delegate?.imageDelete(index: index)
  }
}
