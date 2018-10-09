
//
//  ANINotiNotiView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/15.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import NVActivityIndicatorView

protocol ANINotiViewDelegate {
  func cellTapped(noti: FirebaseNotification)
}

class ANINotiView: UIView {
  
  private weak var reloadView: ANIReloadView?
  
  private weak var notiTableView: UITableView?
  
  private var notifications = [FirebaseNotification]()
  
  private var users = [FirebaseUser]()
  
  private var isLastNotiPage: Bool = false
  private var lastNoti: QueryDocumentSnapshot?
  private var isLoading: Bool = false
  private let COUNT_LAST_CELL: Int = 4
  
  var isCellSelected: Bool = false
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var delegate: ANINotiViewDelegate?
  
  private var cellHeight = [IndexPath: CGFloat]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    loadNoti(sender: nil)
    setupNotifications()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let window = UIApplication.shared.keyWindow
    var bottomSafeArea: CGFloat = 0.0
    if let windowUnrap = window {
      bottomSafeArea = windowUnrap.safeAreaInsets.bottom
    }
    
    //reloadView
    let reloadView = ANIReloadView()
    reloadView.alpha = 0.0
    reloadView.messege = "通知がありません。"
    reloadView.delegate = self
    addSubview(reloadView)
    reloadView.dropShadow()
    reloadView.centerInSuperview()
    reloadView.leftToSuperview(offset: 50.0)
    reloadView.rightToSuperview(offset: -50.0)
    self.reloadView = reloadView
    
    //notiTableView
    let notiTableView = UITableView()
    notiTableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: bottomSafeArea, right: 0)
    notiTableView.scrollIndicatorInsets  = UIEdgeInsets(top: UIViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: bottomSafeArea, right: 0)
    let basicNotiId = NSStringFromClass(ANIBasicNotiViewCell.self)
    notiTableView.register(ANIBasicNotiViewCell.self, forCellReuseIdentifier: basicNotiId)
    let followNotiId = NSStringFromClass(ANIFollowNotiViewCell.self)
    notiTableView.register(ANIFollowNotiViewCell.self, forCellReuseIdentifier: followNotiId)
    notiTableView.backgroundColor = ANIColor.bg
    notiTableView.separatorStyle = .none
    notiTableView.alpha = 0.0
    notiTableView.rowHeight = UITableView.automaticDimension
    notiTableView.alwaysBounceVertical = true
    notiTableView.dataSource = self
    notiTableView.delegate = self
    let refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = .clear
    refreshControl.tintColor = ANIColor.moreDarkGray
    refreshControl.addTarget(self, action: #selector(loadNoti(sender:)), for: .valueChanged)
    notiTableView.addSubview(refreshControl)
    addSubview(notiTableView)
    notiTableView.edgesToSuperview()
    self.notiTableView = notiTableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.green, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  private func setupNotifications() {
    ANINotificationManager.receive(notiTabTapped: self, selector: #selector(scrollToTop))
    ANINotificationManager.receive(login: self, selector: #selector(reloadNotifications))
  }
  
  @objc private func scrollToTop() {
    guard let notiTableView = notiTableView,
          !notifications.isEmpty,
          isCellSelected else { return }
    
    notiTableView.scrollToRow(at: [0, 0], at: .top, animated: true)
  }
  
  @objc private func reloadNotifications() {
    loadNoti(sender: nil)
  }
  
  private func showReloadView(sender: UIRefreshControl?) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let reloadView = self.reloadView,
          let notiTableView = self.notiTableView else { return }
    
    activityIndicatorView.stopAnimating()
    
    notiTableView.reloadData()
    
    if let sender = sender {
      sender.endRefreshing()
    }
    
    notiTableView.alpha = 0.0
    
    UIView.animate(withDuration: 0.2, animations: {
      reloadView.alpha = 1.0
    })
    
    self.isLoading = false
  }
  
  private func updateCheckNotiDate() {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid else { return }
    
    let database = Firestore.firestore()
    
    let date = ANIFunction.shared.getToday()
    database.collection(KEY_USERS).document(currentUserUid).updateData([KEY_CHECK_NOTI_DATE: date, KEY_IS_HAVE_UNREAD_NOTI: false])
  }
}

//MARK: UITableViewDataSource
extension ANINotiView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notifications.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if !notifications.isEmpty {
      if notifications[indexPath.row].notiKind == KEY_NOTI_KIND_FOLLOW {
        let followNotiId = NSStringFromClass(ANIFollowNotiViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: followNotiId, for: indexPath) as! ANIFollowNotiViewCell
        
        if users.contains(where: { $0.uid == notifications[indexPath.row].userId }) {
          for user in users {
            if notifications[indexPath.row].userId == user.uid {
              cell.user = user
              break
            }
          }
        } else {
          cell.user = nil
        }
        cell.noti = notifications[indexPath.row]
        cell.delegate = self
        
        return cell
      } else {
        let basicNotiId = NSStringFromClass(ANIBasicNotiViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: basicNotiId, for: indexPath) as! ANIBasicNotiViewCell
        
        if users.contains(where: { $0.uid == notifications[indexPath.row].userId }) {
          for user in users {
            if notifications[indexPath.row].userId == user.uid {
              cell.user = user
              break
            }
          }
        } else {
          cell.user = nil
        }
        cell.noti = notifications[indexPath.row]
        cell.delegate = self
        
        return cell
      }
    } else {
      return UITableViewCell()
    }
  }
}

//MARK: UITableViewDelegate
extension ANINotiView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if notifications[indexPath.row].notiKind != KEY_NOTI_KIND_FOLLOW {
      self.delegate?.cellTapped(noti: notifications[indexPath.row])
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let element = self.notifications.count - COUNT_LAST_CELL
    if !isLoading, indexPath.row >= element {
      loadMoreNoti()
    }
    
    self.cellHeight[indexPath] = cell.frame.size.height
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    if let height = self.cellHeight[indexPath] {
      return height
    } else {
      return UITableView.automaticDimension
    }
  }
}

//MARK: data
extension ANINotiView {
  @objc private func loadNoti(sender: UIRefreshControl?) {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid,
          let activityIndicatorView = self.activityIndicatorView,
          let reloadView = self.reloadView,
          let notiTableView = self.notiTableView else { return }

    reloadView.alpha = 0.0
    
    if !self.notifications.isEmpty {
      self.notifications.removeAll()
    }
    
    if sender == nil {
      activityIndicatorView.startAnimating()
    }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      self.isLoading = true
      self.isLastNotiPage = false
      
      database.collection(KEY_USERS).document(currentUserUid).collection(KEY_NOTIFICATIONS).order(by: KEY_NOTI_UPDATE_DATE, descending: true).limit(to: 20).getDocuments { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          self.isLoading = false
          
          return
        }
        
        guard let snapshot = snapshot,
              let lastNoti = snapshot.documents.last else {
                self.showReloadView(sender: sender)
                return }
        
        self.lastNoti = lastNoti
        
        var updated: Bool = false
        
        for document in snapshot.documents {
          do {
            let notification = try FirestoreDecoder().decode(FirebaseNotification.self, from: document.data())
            self.notifications.append(notification)
            
            DispatchQueue.main.async {
              if let sender = sender {
                sender.endRefreshing()
              }
              
              activityIndicatorView.stopAnimating()
              
              notiTableView.reloadData() {
                if !updated {
                  self.updateCheckNotiDate()
                  updated = true
                }
              }
              
              UIView.animate(withDuration: 0.2, animations: {
                notiTableView.alpha = 1.0
              })
              
              self.isLoading = false
            }
          } catch let error {
            DLog(error)
            
            activityIndicatorView.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: {
              reloadView.alpha = 1.0
            })
            
            if let sender = sender {
              sender.endRefreshing()
            }
            
            self.isLoading = false
          }
        }
        
        if snapshot.documents.isEmpty {
          if !self.notifications.isEmpty {
            self.notifications.removeAll()
          }
          
          self.showReloadView(sender: sender)
          
          self.isLoading = false
        }
      }
    }
  }
  
  private func loadMoreNoti() {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid,
          let notiTableView = self.notiTableView,
          let lastNoti = self.lastNoti,
          !isLoading,
          !isLastNotiPage else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      self.isLoading = true
      
      database.collection(KEY_USERS).document(currentUserUid).collection(KEY_NOTIFICATIONS).order(by: KEY_NOTI_UPDATE_DATE, descending: true).start(afterDocument: lastNoti).limit(to: 20).getDocuments { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          self.isLoading = false

          return
        }
        
        guard let snapshot = snapshot else { return }
        guard let lastNoti = snapshot.documents.last else {
          self.isLastNotiPage = true
          self.isLoading = false
          return }

        self.lastNoti = lastNoti
        
        for (index, document) in snapshot.documents.enumerated() {
          do {
            let noti = try FirestoreDecoder().decode(FirebaseNotification.self, from: document.data())
            self.notifications.append(noti)
            
            DispatchQueue.main.async {
              if index + 1 == snapshot.documents.count {
                notiTableView.reloadData()
                
                self.isLoading = false
              }
            }
          } catch let error {
            DLog(error)
            
            self.isLoading = false
          }
        }
        
        if snapshot.documents.isEmpty {          
          self.isLoading = false
        }
      }
    }
  }
}

//MARK: ANIReloadViewDelegate
extension ANINotiView: ANIReloadViewDelegate {
  func reloadButtonTapped() {
    loadNoti(sender: nil)
  }
}

//MARK: ANIBasicNotiViewCellDelegate
extension ANINotiView: ANIBasicNotiViewCellDelegate, ANIFollowNotiViewCellDelegate {
  func loadedNotiUser(user: FirebaseUser) {
    self.users.append(user)
  }
}
