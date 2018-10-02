//
//  ChatView.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/27.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import NVActivityIndicatorView

class ANIChatView: UIView {
  
  private weak var chatTableView: UITableView?
    
  var chatGroupId: String?
  
  var user: FirebaseUser? 
  
  var chatGroup: FirebaseChatGroup? {
    didSet {
      loadMessage()
    }
  }
  
  private var messages = [FirebaseChatMessage]()
  
  private var beforeDate: String = ""
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
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
    chatTableView.alpha = 0.0
    addSubview(chatTableView)
    chatTableView.edgesToSuperview()
    self.chatTableView = chatTableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.green, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  func scrollToBottom() {
    guard let chatTableView = self.chatTableView else { return }
    
    if !messages.isEmpty {
      chatTableView.scrollToRow(at: [0, messages.count - 1], at: .bottom, animated: false)
    }
  }
  
  private func getDate(date: String) -> String {
    let resetDate = String(date.prefix(10))
    
    return resetDate
  }
  
  private func updateCheckChatGroupDate() {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid,
          let chatGroupId = self.chatGroupId,
          let chatGroup = self.chatGroup else { return }
    
    let database = Firestore.firestore()
    
    let date = ANIFunction.shared.getToday()
    
    var checkChatGroupDateTemp = [String: String]()
    
    if let checkChatGroupDate = chatGroup.checkChatGroupDate {
      checkChatGroupDateTemp = checkChatGroupDate
    }
    
    checkChatGroupDateTemp[currentUserUid] = date
    database.collection(KEY_CHAT_GROUPS).document(chatGroupId).updateData(["checkChatGroupDate": checkChatGroupDateTemp])
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
      if let date = messages[indexPath.row].date {
        if indexPath.row == 0 {
          cell.chagedDate = getDate(date: date)
        } else {
          if let beforeDate = messages[indexPath.row - 1].date, getDate(date: beforeDate) != getDate(date: date) {
            cell.chagedDate = getDate(date: date)
          } else {
            cell.chagedDate = nil
          }
        }
      }
      
      return cell
    } else {
      let otherChatId = NSStringFromClass(ANIOtherChatViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: otherChatId, for: indexPath) as! ANIOtherChatViewCell
      
      cell.message = messages[indexPath.row]
      cell.user = self.user
      if let date = messages[indexPath.row].date {
        if indexPath.row == 0 {
          cell.chagedDate = getDate(date: date)
        } else {
          if let beforeDate = messages[indexPath.row - 1].date, getDate(date: beforeDate) != getDate(date: date) {
            cell.chagedDate = date
          } else {
            cell.chagedDate = nil
          }
        }
      }
      return cell
    }
  }
}

//MAKR: data
extension ANIChatView {
  private func loadMessage() {
    guard let chatGroupId = self.chatGroupId,
          let activityIndicatorView = self.activityIndicatorView,
          let chatTableView = self.chatTableView else { return }
    
    let database = Firestore.firestore()
    
    activityIndicatorView.startAnimating()
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
      database.collection(KEY_CHAT_GROUPS).document(chatGroupId).collection(KEY_CHAT_MESSAGES).order(by: KEY_DATE).limit(to: 20).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        guard let snapshot = snapshot else { return }
        
        var updated: Bool = false
        
        snapshot.documentChanges.forEach({ (diff) in
          if diff.type == .added {
            do {
              let message = try FirestoreDecoder().decode(FirebaseChatMessage.self, from: diff.document.data())
              
              self.messages.append(message)
              
              DispatchQueue.main.async {
                chatTableView.reloadData() {
                  if !updated {
                    self.updateCheckChatGroupDate()
                    updated = true
                  }
                }
                self.scrollToBottom()
                
                UIView.animate(withDuration: 0.2, animations: {
                  chatTableView.alpha = 1.0
                })
                
                activityIndicatorView.stopAnimating()
              }
            } catch let error {
              DLog(error)
              
              activityIndicatorView.stopAnimating()
            }
          }
        })
        
        if snapshot.documents.isEmpty {
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
}
