//
//  ANIProfileViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIProfileViewController: UIViewController {
  
  private weak var familyView: ANIFamilyView?
  private let FAMILY_VIEW_HEIGHT: CGFloat = 95.0
  
  private weak var menuBar: ANIProfileMenuBar?
  private let MENU_BAR_HEIGHT: CGFloat = 60.0

  private weak var containerCollectionView: UICollectionView?
  
  override func viewDidLoad() {
        super.viewDidLoad()

      setup()
    }
  
  private func setup() {
    //basic
    Orientation.lockOrientation(.portrait)
    self.view.backgroundColor = .white
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationItem.title = "PROFILE"
    
    //familyView
    let familyView = ANIFamilyView()
    self.view.addSubview(familyView)
    familyView.topToSuperview()
    familyView.leftToSuperview()
    familyView.rightToSuperview()
    familyView.widthToSuperview()
    familyView.height(FAMILY_VIEW_HEIGHT)
    self.familyView = familyView
    
    //menuBar
    let menuBar = ANIProfileMenuBar()
    menuBar.aniProfileViewController = self
    self.view.addSubview(menuBar)
    menuBar.topToBottom(of: familyView, offset: 10.0)
    menuBar.leftToSuperview()
    menuBar.rightToSuperview()
    menuBar.widthToSuperview()
    menuBar.height(MENU_BAR_HEIGHT)
    self.menuBar = menuBar
    
    //container
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let containerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    containerCollectionView.dataSource = self
    containerCollectionView.delegate = self
    containerCollectionView.showsHorizontalScrollIndicator = false
    containerCollectionView.backgroundColor = ANIColor.bg
    containerCollectionView.isPagingEnabled = true
    let profileId = NSStringFromClass(ANIProfileProfileCell.self)
    containerCollectionView.register(ANIProfileProfileCell.self, forCellWithReuseIdentifier: profileId)
//    let qnaId = NSStringFromClass(ANICommunityQnaCell.self)
//    containerCollectionView.register(ANICommunityQnaCell.self, forCellWithReuseIdentifier: qnaId)
    
    self.view.addSubview(containerCollectionView)
    containerCollectionView.topToBottom(of: menuBar)
    containerCollectionView.leftToSuperview()
    containerCollectionView.rightToSuperview()
    containerCollectionView.bottomToSuperview()
    self.containerCollectionView = containerCollectionView
  }
  
  func scrollToMenuIndex(menuIndex: Int) {
    guard let containerCollectionView = self.containerCollectionView else { return }
    let indexPath = IndexPath(item: menuIndex, section: 0)
    containerCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
  }
}

extension ANIProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.item == 0 {
      let profileId = NSStringFromClass(ANIProfileProfileCell.self)
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileId, for: indexPath) as! ANIProfileProfileCell
      return cell
    } else if indexPath.item == 1{
      let profileId = NSStringFromClass(ANIProfileProfileCell.self)
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileId, for: indexPath) as! ANIProfileProfileCell
      return cell
    } else if indexPath.item == 2{
      let profileId = NSStringFromClass(ANIProfileProfileCell.self)
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileId, for: indexPath) as! ANIProfileProfileCell
      return cell
    } else {
      let profileId = NSStringFromClass(ANIProfileProfileCell.self)
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileId, for: indexPath) as! ANIProfileProfileCell
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    return size
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard let menuBar = self.menuBar else { return }
    let indexPath = IndexPath(item: Int(targetContentOffset.pointee.x / view.frame.width), section: 0)
    menuBar.menuCollectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .left)
  }
}
