//
//  RecruitCategoriesView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/05.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIRecruitCategoriesView: UIView {
  
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
    flowlayout.sectionInset = UIEdgeInsets(top: -10, left: 10, bottom: 0, right: 10)
    let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowlayout)
    let id = NSStringFromClass(ANIRecruitCategoryCell.self)
    collectionView.register(ANIRecruitCategoryCell.self, forCellWithReuseIdentifier: id)
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
    let arr = ["シャム", "ペルシャ", "スコティッシュフォールド", "アメリカン・ショートヘア", "バーマン", "ブリティッシュショートヘア", "ミックス"]
    self.testArr = arr
  }
}

extension ANIRecruitCategoriesView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testArr.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANIRecruitCategoryCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANIRecruitCategoryCell
    cell.categoryLabel?.text = testArr[indexPath.item]
    cell.backgroundColor = ANIColor.lightGray
    cell.layer.cornerRadius = cell.frame.height / 2
    cell.layer.masksToBounds = true
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = ANIRecruitCategoryCell.sizeWithCategory(category: testArr[indexPath.item])
    return size
  }
}
