//
//  ChatView.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/27.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

class ANIChatView: UIView {
  
  private weak var chatTableView: UITableView?
    
  var chatGroupId: String? {
    didSet {
      loadMessage()
    }
  }
  
  var user: FirebaseUser?
  
  private var messages = [FirebaseChatMessage]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = .white
    
    //chatTableView
    let chatTableView = UITableView()
    chatTableView.separatorStyle = .none
    let myChatId = NSStringFromClass(ANIMyChatViewCell.self)
    chatTableView.register(ANIMyChatViewCell.self, forCellReuseIdentifier: myChatId)
    let otherChatId = NSStringFromClass(ANIOtherChatViewCell.self)
    chatTableView.register(ANIOtherChatViewCell.self, forCellReuseIdentifier: otherChatId)
    chatTableView.dataSource = self
    addSubview(chatTableView)
    chatTableView.edgesToSuperview()
    self.chatTableView = chatTableView
  }
  
  private func loadMessage() {
    guard let chatGroupId = self.chatGroupId else { return }
    
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      databaseRef.child(KEY_CHAT_MESSAGES).child(chatGroupId).queryOrderedByKey().queryLimited(toFirst: 20).observe(.childAdded) { (snapshot) in
        guard let value = snapshot.value else { return }
        
        do {
          let message = try FirebaseDecoder().decode(FirebaseChatMessage.self, from: value)
          
          self.messages.append(message)
          
          DispatchQueue.main.async {
            guard let chatTableView = self.chatTableView else { return }
            
            chatTableView.reloadData()
          }
        } catch let error {
          print(error)
        }
      }
    }
  }
}

//MARK: UITableViewDataSource
extension ANIChatView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid else { return UITableViewCell() }
    
    if messages[indexPath.row].userId == currentUserUid {
      let myChatId = NSStringFromClass(ANIMyChatViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: myChatId, for: indexPath) as! ANIMyChatViewCell
      
      cell.message = messages[indexPath.row]
      
      return cell
    } else {
      let otherChatId = NSStringFromClass(ANIOtherChatViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: otherChatId, for: indexPath) as! ANIOtherChatViewCell
      
      cell.message = messages[indexPath.row]
      cell.user = self.user
      
      return cell
    }
  }
}
