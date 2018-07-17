//
//  ANIRecruitFiltersView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/05.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

protocol ANIRecruitFiltersViewDelegate {
  func homeSelectButtonTapped()
  func kindSelectButtonTapped()
  func ageSelectButtonTapped()
  func sexSelectButtonTapped()
}

class ANIRecruitFiltersView: UIView {
  
  weak var filterCollectionView: UICollectionView?
  
  private var filters = ["お家", "種類", "年齢", "性別"]
  
  var delegate: ANIRecruitFiltersViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = .white
    
    //collectionView
    let flowlayout = UICollectionViewFlowLayout()
    flowlayout.scrollDirection = .horizontal
    flowlayout.sectionInset = UIEdgeInsets(top: -2, left: 12, bottom: 0, right: 12)
    let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowlayout)
    let id = NSStringFromClass(ANIRecruitFilterCell.self)
    collectionView.register(ANIRecruitFilterCell.self, forCellWithReuseIdentifier: id)
    collectionView.backgroundColor = .white
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.alwaysBounceHorizontal = true
    collectionView.dataSource = self
    collectionView.delegate = self
    addSubview(collectionView)
    collectionView.edgesToSuperview()
    self.filterCollectionView = collectionView
  }
}

//MARK: UICollectionViewDataSource
extension ANIRecruitFiltersView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filters.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIRecruitFilterCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIRecruitFilterCell
    
    cell.filter = filters[indexPath.item]
    
    return cell
  }
}

//MARK: UICollectionViewDelegateFlowLayout
extension ANIRecruitFiltersView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let size = ANIRecruitFilterCell.sizeWithFilter(filter: filters[indexPath.item])
    
    return size
  }
}

//MARK: UICollectionViewDelegate
extension ANIRecruitFiltersView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item == 0 {
      self.delegate?.homeSelectButtonTapped()
    } else if indexPath.item == 1 {
      self.delegate?.kindSelectButtonTapped()
    } else if indexPath.item == 2 {
      self.delegate?.ageSelectButtonTapped()
    } else if indexPath.item == 3 {
      self.delegate?.sexSelectButtonTapped()
    }
  }
}
