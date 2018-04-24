//
//  ANISearchCategoriesView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANISearchCategoriesView: UIView {
  
  private weak var categoryCollectionView: UICollectionView?
  
  private var testArr = [String]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setTestModel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let flowlayout = UICollectionViewFlowLayout()
    flowlayout.scrollDirection = .horizontal
    flowlayout.sectionInset = UIEdgeInsets(top: -10, left: 12, bottom: 0, right: 12)
    let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowlayout)
    let id = NSStringFromClass(ANISearchCategoryCell.self)
    collectionView.register(ANISearchCategoryCell.self, forCellWithReuseIdentifier: id)
    collectionView.backgroundColor = .white
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.alwaysBounceHorizontal = true
    collectionView.dataSource = self
    collectionView.delegate = self
    addSubview(collectionView)
    collectionView.edgesToSuperview()
    self.categoryCollectionView = collectionView
  }
  
  private func setTestModel() {
    let arr = ["ユーザー", "ストリー", "質問"]
    self.testArr = arr
  }
}

extension ANISearchCategoriesView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testArr.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANISearchCategoryCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANISearchCategoryCell
    cell.categoryLabel?.text = testArr[indexPath.item]
    cell.backgroundColor = ANIColor.lightGray
    cell.layer.cornerRadius = cell.frame.height / 2
    cell.layer.masksToBounds = true
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = ANISearchCategoryCell.sizeWithCategory(category: testArr[indexPath.item])
    return size
  }
}
