//
//  ANIFollowUserView.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/27.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import NVActivityIndicatorView

class ANIFollowUserView: UIView {
  
  private weak var followUserTableView: UITableView?
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var followUserViewMode: FollowUserViewMode?
  
  var userId: String? {
    didSet {
      guard let followUserViewMode = self.followUserViewMode else { return }
      
      switch followUserViewMode {
      case .following:
        loadFollowingUser(sender: nil)
      case .follower:
        loadFollower(sender: nil)
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
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(reloadData(sender:)), for: .valueChanged)
    followUserTableView.addSubview(refreshControl)
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
  
  @objc private func reloadData(sender: UIRefreshControl?) {
    guard let followUserViewMode = self.followUserViewMode else { return }
    
    switch followUserViewMode {
    case .following:
      loadFollowingUser(sender: sender)
    case .follower:
      loadFollower(sender: sender)
    }
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
  private func loadFollowingUser(sender: UIRefreshControl?) {
    guard let userId = self.userId,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    if !self.followingUsers.isEmpty {
      self.followingUsers.removeAll()
    }
    
    if sender == nil {
      activityIndicatorView.startAnimating()
    }
    
    let database = Firestore.firestore()
    
    database.collection(KEY_USERS).document(userId).collection(KEY_FOLLOWING_USER_IDS).order(by: KEY_DATE, descending: true).limit(to: 20).getDocuments { (snapshot, error) in
      if let error = error {
        DLog("Error get document: \(error)")
        
        return
      }
      
      guard let snapshot = snapshot else { return }
      
      for document in snapshot.documents {
        database.collection(KEY_USERS).document(document.documentID).getDocument(completion: { (userSnapshot, userError) in
          if let error = error {
            DLog("Error get user document: \(error)")
            
            return
          }
          
          guard let userSnapshot = userSnapshot, let data = userSnapshot.data() else { return }
          
          do {
            let user = try FirestoreDecoder().decode(FirebaseUser.self, from: data)
            self.followingUsers.append(user)

            DispatchQueue.main.async {
              if let sender = sender {
                sender.endRefreshing()
              }
              
              guard let followUserTableView = self.followUserTableView else { return }

              followUserTableView.reloadData()
              activityIndicatorView.stopAnimating()

              UIView.animate(withDuration: 0.2, animations: {
                followUserTableView.alpha = 1.0
              })
            }
          } catch let error {
            DLog(error)
            activityIndicatorView.stopAnimating()
            
            if let sender = sender {
              sender.endRefreshing()
            }
          }
        })
      }
      
      if snapshot.documents.isEmpty {
        if let sender = sender {
          sender.endRefreshing()
        }
        
        activityIndicatorView.stopAnimating()
      }
    }
  }
  
  private func loadFollower(sender: UIRefreshControl?) {
    guard let userId = self.userId,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    if !self.followers.isEmpty {
      self.followers.removeAll()
    }
    
    if sender == nil {
      activityIndicatorView.startAnimating()
    }
    
    let database = Firestore.firestore()
    
    database.collection(KEY_USERS).document(userId).collection(KEY_FOLLOWER_IDS).order(by: KEY_DATE, descending: true).limit(to: 20).getDocuments { (snapshot, error) in
      if let error = error {
        DLog("Error get document: \(error)")
        
        return
      }
      
      guard let snapshot = snapshot else { return }
      
      let group = DispatchGroup()
      var followUserTemp = [FirebaseUser?]()
      
      for (index, document) in snapshot.documents.enumerated() {
        
        group.enter()
        followUserTemp.append(nil)
        
        DispatchQueue(label: "follow").async {

          database.collection(KEY_USERS).document(document.documentID).getDocument(completion: { (userSnapshot, userError) in
            if let error = error {
              DLog("Error get user document: \(error)")
              
              return
            }
            
            guard let userSnapshot = userSnapshot, let data = userSnapshot.data() else {
              group.leave()

              return
            }
            
            do {
              let user = try FirestoreDecoder().decode(FirebaseUser.self, from: data)
              followUserTemp[index] = user
              
              group.leave()
            } catch let error {
              DLog(error)
              
              group.leave()
            }
          })
        }
      }
      
      group.notify(queue: DispatchQueue(label: "follow")) {
        DispatchQueue.main.async {
          DispatchQueue.main.async {
            if let sender = sender {
              sender.endRefreshing()
            }

            guard let followUserTableView = self.followUserTableView else { return }
            
            for user in followUserTemp {
              if let user = user {
                self.followers.append(user)
              }
            }
            
            followUserTableView.reloadData()
            activityIndicatorView.stopAnimating()

            UIView.animate(withDuration: 0.2, animations: {
              followUserTableView.alpha = 1.0
            })
          }
        }
      }
      
      if snapshot.documents.isEmpty {
        if let sender = sender {
          sender.endRefreshing()
        }
        
        activityIndicatorView.stopAnimating()
      }
    }
  }
}
