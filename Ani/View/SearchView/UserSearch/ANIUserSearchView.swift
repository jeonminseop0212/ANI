//
//  UserSearchView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIUserSearchView: UIView {
  
  weak var userTableView: UITableView?
  private var testUserSearchResult = [User]()

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
    tableView.contentInset = UIEdgeInsets(top: ANISearchViewController.CATEGORIES_VIEW_HEIGHT, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: ANISearchViewController.CATEGORIES_VIEW_HEIGHT, left: 0, bottom: 0, right: 0)
    tableView.dataSource = self
    tableView.delegate = self
    let id = NSStringFromClass(ANIUserSearchViewCell.self)
    tableView.register(ANIUserSearchViewCell.self, forCellReuseIdentifier: id)
    tableView.backgroundColor = .white
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
    
    testUserSearchResult = [user1, user2, user3, user4, user5, user6, user7, user8, user9]
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
  }
}
