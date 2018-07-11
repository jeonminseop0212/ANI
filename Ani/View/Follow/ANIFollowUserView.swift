//
//  ANIFollowUserView.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/27.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase
import NVActivityIndicatorView

class ANIFollowUserView: UIView {
  
  private weak var followUserTableView: UITableView?
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var followUserViewMode: FollowUserViewMode?
  
  var userId: String? {
    didSet {
      guard let followUserViewMode = self.followUserViewMode,
            let activityIndicatorView = self.activityIndicatorView else { return }
      
      activityIndicatorView.startAnimating()
      
      switch followUserViewMode {
      case .following:
        loadFollowingUser()
      case .follower:
        loadFollower()
      }
    }
  }
  
  private var followingUsers = [FirebaseUser]()
  private var followers = [FirebaseUser]()

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = .white
    
    //followUserTableView
    let followUserTableView = UITableView()
    let id = NSStringFromClass(ANIFollowUserViewCell.self)
    followUserTableView.register(ANIFollowUserViewCell.self, forCellReuseIdentifier: id)
    followUserTableView.separatorStyle = .none
    followUserTableView.alpha = 0.0
    followUserTableView.dataSource = self
    addSubview(followUserTableView)
    followUserTableView.edgesToSuperview()
    self.followUserTableView = followUserTableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.green, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
}

//MARK: UITableViewDataSource
extension ANIFollowUserView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let followUserViewMode = self.followUserViewMode else { return 0 }
    
    switch followUserViewMode {
    case .following:
      return followingUsers.count
    case .follower:
      return followers.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let followUserViewMode = self.followUserViewMode else { return UITableViewCell() }
    
    let id = NSStringFromClass(ANIFollowUserViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIFollowUserViewCell
    
    switch followUserViewMode {
    case .following:
      cell.user = followingUsers[indexPath.row]
    case .follower:
      cell.user = followers[indexPath.row]
    }
    
    return cell
  }
}

//MARK: data
extension ANIFollowUserView {
  private func loadFollowingUser() {
    guard let userId = self.userId else { return }
    
    let databaseRef = Database.database().reference()
    databaseRef.child(KEY_FOLLOWING_USER_IDS).child(userId).queryOrderedByValue().queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
      
      for item in snapshot.children {
        if let snapshot = item as? DataSnapshot {
          databaseRef.child(KEY_USERS).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else { return }
            
            do {
              let user = try FirebaseDecoder().decode(FirebaseUser.self, from: value)
              self.followingUsers.insert(user, at: 0)
              
              DispatchQueue.main.async {
                guard let followUserTableView = self.followUserTableView,
                      let activityIndicatorView = self.activityIndicatorView else { return }
                
                followUserTableView.reloadData()
                activityIndicatorView.stopAnimating()
                
                UIView.animate(withDuration: 0.2, animations: {
                  followUserTableView.alpha = 1.0
                })
              }
            } catch let error {
              guard let activityIndicatorView = self.activityIndicatorView else { return }
              
              print(error)
              activityIndicatorView.stopAnimating()
            }
          })
        }
      }
      
      if snapshot.value as? [String: Any] == nil {
        guard let activityIndicatorView = self.activityIndicatorView else { return }
        
        activityIndicatorView.stopAnimating()
      }
    }
  }
  
  private func loadFollower() {
    guard let userId = self.userId else { return }
    
    let databaseRef = Database.database().reference()
    databaseRef.child(KEY_FOLLOWER_IDS).child(userId).queryOrderedByValue().queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
      
      for item in snapshot.children {
        if let snapshot = item as? DataSnapshot {
          databaseRef.child(KEY_USERS).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else { return }
            
            do {
              let user = try FirebaseDecoder().decode(FirebaseUser.self, from: value)
              self.followers.insert(user, at: 0)
              
              DispatchQueue.main.async {
                guard let followUserTableView = self.followUserTableView,
                  let activityIndicatorView = self.activityIndicatorView else { return }
                
                followUserTableView.reloadData()
                activityIndicatorView.stopAnimating()
                
                UIView.animate(withDuration: 0.2, animations: {
                  followUserTableView.alpha = 1.0
                })
              }
            } catch let error {
              guard let activityIndicatorView = self.activityIndicatorView else { return }

              print(error)
              activityIndicatorView.stopAnimating()
            }
          })
        }
      }
    
      if snapshot.value as? [String: Any] == nil {
        guard let activityIndicatorView = self.activityIndicatorView else { return }
        
        activityIndicatorView.stopAnimating()
      }
    }
  }
}
