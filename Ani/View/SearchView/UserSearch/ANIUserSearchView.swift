//
//  UserSearchView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIUserSearchViewDelegate {
  func userSearchViewDidScroll(scrollY: CGFloat)
}

class ANIUserSearchView: UIView {
  
  weak var userTableView: UITableView? {
    didSet {
      guard let userTableView = self.userTableView else { return }
      let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT
      userTableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    }
  }
  private var testUserSearchResult = [User]()
  
  var delegate: ANIUserSearchViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupTestUser()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let tableView = UITableView()
    tableView.separatorStyle = .none
    let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT
    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.backgroundColor = .white
    let id = NSStringFromClass(ANIUserSearchViewCell.self)
    tableView.register(ANIUserSearchViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.delegate = self
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.userTableView = tableView
  }
  
  private func setupTestUser() {
    let user1 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user2 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user3 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user4 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user5 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user6 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user7 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user8 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user9 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user10 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user11 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user12 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user13 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user14 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user15 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user16 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    let user17 = User(profileImage: UIImage(named: "profileImage")!,name: "inoue chiaki")
    let user18 = User(profileImage: UIImage(named: "profileImage")!,name: "jeon minseop")
    
    testUserSearchResult = [user1, user2, user3, user4, user5, user6, user7, user8, user9, user10, user11, user12, user13, user14, user15, user16, user17, user18]
  }
}

extension ANIUserSearchView: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return testUserSearchResult.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIUserSearchViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIUserSearchViewCell
    cell.profileImageView.image = testUserSearchResult[indexPath.row].profileImage
    cell.userNameLabel.text = testUserSearchResult[indexPath.row].name
    return cell
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ANINotificationManager.postViewScrolled()
    
    //navigation bar animation
    let scrollY = scrollView.contentOffset.y
    self.delegate?.userSearchViewDidScroll(scrollY: scrollY)
  }
}
