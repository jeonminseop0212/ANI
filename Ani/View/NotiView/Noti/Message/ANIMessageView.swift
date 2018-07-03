//
//  ANIMessageView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/15.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase
import NVActivityIndicatorView

class ANIMessageView: UIView {
  
  private weak var messageTableView: UITableView?
  
  private var chatGroups = [FirebaseChatGroup]()
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    loadChatGroup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = ANIColor.bg
    let window = UIApplication.shared.keyWindow
    var bottomSafeArea: CGFloat = 0.0
    if let windowUnrap = window {
      bottomSafeArea = windowUnrap.safeAreaInsets.bottom
    }
    
    //messageTableView
    let messageTableView = UITableView()
    messageTableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    messageTableView.scrollIndicatorInsets  = UIEdgeInsets(top: UIViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    let id = NSStringFromClass(ANIMessageViewCell.self)
    messageTableView.register(ANIMessageViewCell.self, forCellReuseIdentifier: id)
    messageTableView.backgroundColor = ANIColor.bg
    messageTableView.separatorStyle = .none
    messageTableView.alwaysBounceVertical = true
    messageTableView.dataSource = self
    messageTableView.alpha = 0.0
    addSubview(messageTableView)
    messageTableView.edgesToSuperview()
    self.messageTableView = messageTableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.green, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  private func loadChatGroup() {
    guard let crrentUserUid = ANISessionManager.shared.currentUserUid,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    let databaseRef = Database.database().reference()
    
    activityIndicatorView.startAnimating()

    databaseRef.child(KEY_USERS).child(crrentUserUid).child(KEY_CHAT_GROUP_IDS).queryOrderedByValue().queryLimited(toFirst: 20).observe(.value) { (snapshot) in
      if !self.chatGroups.isEmpty {
        self.chatGroups.removeAll()
      }
      
      for item in snapshot.children {
        if let snapshot = item as? DataSnapshot {
          databaseRef.child(KEY_CHAT_GROUPS).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let value = snapshot.value else { return }
            do {
              let group = try FirebaseDecoder().decode(FirebaseChatGroup.self, from: value)
              self.chatGroups.insert(group, at: 0)
              
              DispatchQueue.main.async {
                guard let messageTableView = self.messageTableView else { return }
    
                activityIndicatorView.stopAnimating()
    
                messageTableView.reloadData()
    
                UIView.animate(withDuration: 0.2, animations: {
                  messageTableView.alpha = 1.0
                })
              }
            } catch let error {
              print(error)
              
              activityIndicatorView.stopAnimating()
            }
            if snapshot.value as? [String: AnyObject] == nil {
              activityIndicatorView.stopAnimating()
            }
          })
        }
      }
      
      if snapshot.value as? [String: AnyObject] == nil {
        activityIndicatorView.stopAnimating()
      }
    }
  }
}

//MARK: UITableViewDataSource
extension ANIMessageView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatGroups.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIMessageViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIMessageViewCell
    
    cell.chatGroup = chatGroups[indexPath.row]
    cell.loadUser()
    cell.observeGroup()
    
    return cell
  }
}
