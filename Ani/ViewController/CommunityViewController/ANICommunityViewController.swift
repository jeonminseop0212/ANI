//
//  CommunityViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANICommunityViewController: UIViewController {
  
  private weak var menuBar: ANICommunityMenuBar?
  private weak var containerCollectionView: UICollectionView?
  
  private let CONTRIBUTION_BUTTON_HEIGHT: CGFloat = 55.0
  private weak var contributionButon: ANIImageButtonView?

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
  }
  
  private func setup() {
    //basic
    Orientation.lockOrientation(.portrait)
    navigationController?.setNavigationBarHidden(true, animated: false)
    
    //container
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let containerCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: flowLayout)
    containerCollectionView.dataSource = self
    containerCollectionView.delegate = self
    containerCollectionView.showsHorizontalScrollIndicator = false
    containerCollectionView.backgroundColor = ANIColor.bg
    containerCollectionView.isPagingEnabled = true
    let storyId = NSStringFromClass(ANICommunityStoryCell.self)
    containerCollectionView.register(ANICommunityStoryCell.self, forCellWithReuseIdentifier: storyId)
    let qnaId = NSStringFromClass(ANICommunityQnaCell.self)
    containerCollectionView.register(ANICommunityQnaCell.self, forCellWithReuseIdentifier: qnaId)

    self.view.addSubview(containerCollectionView)
    containerCollectionView.edgesToSuperview()
    self.containerCollectionView = containerCollectionView
    
    //menuBar
    let menuBar = ANICommunityMenuBar()
    menuBar.aniCoummunityViewController = self
    self.view.addSubview(menuBar)
    let menuBarHeight = UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT
    menuBar.topToSuperview()
    menuBar.leftToSuperview()
    menuBar.rightToSuperview()
    menuBar.height(menuBarHeight)
    self.menuBar = menuBar
    
    //contributionButon
    let contributionButon = ANIImageButtonView()
    contributionButon.image = UIImage(named: "contributionButton")
    contributionButon.superViewCornerRadius(radius: CONTRIBUTION_BUTTON_HEIGHT / 2)
    contributionButon.superViewDropShadow(opacity: 0.13)
    contributionButon.delegate = self
    self.view.addSubview(contributionButon)
    contributionButon.width(CONTRIBUTION_BUTTON_HEIGHT)
    contributionButon.height(CONTRIBUTION_BUTTON_HEIGHT)
    contributionButon.rightToSuperview(offset: 15.0)
    contributionButon.bottomToSuperview(offset: -15.0, usingSafeArea: true)
    self.contributionButon = contributionButon
  }
  
  func scrollToMenuIndex(menuIndex: Int) {
    guard let containerCollectionView = self.containerCollectionView else { return }
    let indexPath = IndexPath(item: menuIndex, section: 0)
    containerCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
  }
}

extension ANICommunityViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.item == 0 {
      let storyId = NSStringFromClass(ANICommunityStoryCell.self)
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storyId, for: indexPath) as! ANICommunityStoryCell
      cell.frame.origin.y = collectionView.frame.origin.y
      return cell
    } else {
      let qnaId = NSStringFromClass(ANICommunityQnaCell.self)
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: qnaId, for: indexPath) as! ANICommunityQnaCell
      cell.frame.origin.y = collectionView.frame.origin.y
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    return size
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let menuBar = self.menuBar, let horizontalBarleftConstraint = menuBar.horizontalBarleftConstraint else { return }
    horizontalBarleftConstraint.constant = scrollView.contentOffset.x / 2
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard let menuBar = self.menuBar else { return }
    let indexPath = IndexPath(item: Int(targetContentOffset.pointee.x / view.frame.width), section: 0)
    menuBar.menuCollectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .left)
  }
}

extension ANICommunityViewController:ANIButtonViewDelegate{
  func buttonViewTapped(view: ANIButtonView) {
    if view === self.contributionButon {
      print("community contribution tapped")
    }
  }
}
