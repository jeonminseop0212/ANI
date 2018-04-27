//
//  ANICommunityMenuBar.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANICommunityMenuBar: UIView {
  var menuCollectionView: UICollectionView?
  private let menus = ["STORY", "Q&A"]
  var horizontalBarleftConstraint:Constraint?
  var aniCoummunityViewController: ANICommunityViewController?
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupHorizontalBar()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = .white    
    let flowlayout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowlayout)
    let id = NSStringFromClass(ANICommunityMenuBarCell.self)
    collectionView.register(ANICommunityMenuBarCell.self, forCellWithReuseIdentifier: id)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = .white
    let selectedIndexPath = IndexPath(item: 0, section: 0)
    collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .left)
    addSubview(collectionView)
    collectionView.topToSuperview(offset: UIViewController.STATUS_BAR_HEIGHT)
    collectionView.leftToSuperview()
    collectionView.rightToSuperview()
    collectionView.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    self.menuCollectionView = collectionView
  }
  
  private func setupHorizontalBar() {
    let horizontalBar = UIView()
    horizontalBar.backgroundColor = ANIColor.green
    addSubview(horizontalBar)
    horizontalBarleftConstraint = horizontalBar.leftToSuperview()
    horizontalBar.widthToSuperview(multiplier: 1/2)
    horizontalBar.height(3.0)
    horizontalBar.bottomToSuperview()
  }
}

extension ANICommunityMenuBar: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let id = NSStringFromClass(ANICommunityMenuBarCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! ANICommunityMenuBarCell
    cell.menuLabel?.text = menus[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.height)
    return size
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let aniCoummunityViewController = self.aniCoummunityViewController else { return }
    aniCoummunityViewController.scrollToMenuIndex(menuIndex: indexPath.item)
  }
}
