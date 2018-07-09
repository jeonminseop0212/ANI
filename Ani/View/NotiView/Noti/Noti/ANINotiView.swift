
//
//  ANINotiNotiView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/15.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

protocol ANINotiViewDelegate {
  func cellTapped(noti: FirebaseNotification)
}

class ANINotiView: UIView {
  
  private weak var notiTableView: UITableView?
  
  private var notifications = [FirebaseNotification]()
  
  var isCellSelected: Bool = false
  
  var delegate: ANINotiViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    loadNoti()
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
    
    //notiTableView
    let notiTableView = UITableView()
    notiTableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    notiTableView.scrollIndicatorInsets  = UIEdgeInsets(top: UIViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    let basicNotiId = NSStringFromClass(ANIBasicNotiViewCell.self)
    notiTableView.register(ANIBasicNotiViewCell.self, forCellReuseIdentifier: basicNotiId)
    let followNotiId = NSStringFromClass(ANIFollowNotiViewCell.self)
    notiTableView.register(ANIFollowNotiViewCell.self, forCellReuseIdentifier: followNotiId)
    notiTableView.backgroundColor = ANIColor.bg
    notiTableView.separatorStyle = .none
    notiTableView.alwaysBounceVertical = true
    notiTableView.dataSource = self
    notiTableView.delegate = self
    addSubview(notiTableView)
    notiTableView.edgesToSuperview()
    self.notiTableView = notiTableView
  }
  
  private func setupNotifications() {
    ANINotificationManager.receive(notiTabTapped: self, selector: #selector(scrollToTop))
  }
  
  @objc private func scrollToTop() {
    guard let notiTableView = notiTableView,
          !notifications.isEmpty,
          isCellSelected else { return }
    
    notiTableView.scrollToRow(at: [0, 0], at: .top, animated: true)
  }
}

//MARK: UITableViewDataSource
extension ANINotiView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notifications.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if notifications[indexPath.row].kind == KEY_NOTI_KIND_FOLLOW {
      let followNotiId = NSStringFromClass(ANIFollowNotiViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: followNotiId, for: indexPath) as! ANIFollowNotiViewCell
      
      cell.noti = notifications[indexPath.row]
      
      return cell
    } else {
      let basicNotiId = NSStringFromClass(ANIBasicNotiViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: basicNotiId, for: indexPath) as! ANIBasicNotiViewCell
      
      cell.noti = notifications[indexPath.row]
      
      return cell
    }
  }
}

//MARK: UITableViewDelegate
extension ANINotiView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if notifications[indexPath.row].kind != KEY_NOTI_KIND_FOLLOW {
      self.delegate?.cellTapped(noti: notifications[indexPath.row])
    }
  }
}

//MARK: data
extension ANINotiView {
  private func loadNoti() {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid else { return }
    
    let databaseRef = Database.database().reference()
    
    databaseRef.child(KEY_NOTIFICATIONS).child(currentUserUid).observeSingleEvent(of: .value) { (snapshot) in
      for item in snapshot.children {
        if let snapshot = item as? DataSnapshot {
          guard let value = snapshot.value else { return }
          
          do {
            let qna = try FirebaseDecoder().decode(FirebaseNotification.self, from: value)
            self.notifications.insert(qna, at: 0)

            DispatchQueue.main.async {
              guard let notiTableView = self.notiTableView else { return }
              notiTableView.reloadData()
            }
          } catch let error {
            print(error)
          }
        }
      }
    }
  }
}
