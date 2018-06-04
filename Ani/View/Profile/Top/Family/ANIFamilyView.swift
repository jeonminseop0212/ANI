//
//  ANIFamillyView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseStorageUI
import FirebaseDatabase

class ANIFamilyView: UIView {
  
  private weak var familyCollectionView: UICollectionView?
  
  var user: FirebaseUser? {
    didSet {
      guard let familyCollectionView = self.familyCollectionView else { return }
      familyCollectionView.reloadData()
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
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    let id = NSStringFromClass(ANIFamilyViewCell.self)
    collectionView.register(ANIFamilyViewCell.self, forCellWithReuseIdentifier: id)
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    collectionView.backgroundColor = .white
    collectionView.alwaysBounceHorizontal = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.delegate = self
    collectionView.dataSource = self
    addSubview(collectionView)
    collectionView.edgesToSuperview()
    self.familyCollectionView = collectionView
  }
}

extension ANIFamilyView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let user = self.user, let familyImageUrls = user.familyImageUrls {
      return 1 + familyImageUrls.count
    } else {
      return 1
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIFamilyViewCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIFamilyViewCell
    
    if indexPath.item == 0 {
      if let user = self.user, let profileImageUrl = user.profileImageUrl {
        cell.familyImageView?.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
      }
    } else {
      if let user = self.user, let familyImageUrls = user.familyImageUrls {
        cell.familyImageView?.sd_setImage(with: URL(string: familyImageUrls[indexPath.item - 1]), completed: nil)
      }
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    return size
  }
}
