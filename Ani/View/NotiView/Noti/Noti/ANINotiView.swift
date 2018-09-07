
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
  
  private var RELOAD_BUTTON_HEIGHT: CGFloat = 60.0
  private weak var reloadButton: ANIImageButtonView?
  private weak var notiTableView: UITableView?
  
  private var notifications = [FirebaseNotification]()
  
  var isCellSelected: Bool = false
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var delegate: ANINotiViewDelegate?
  
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
    
    //reloadButton
    let reloadButton = ANIImageButtonView()
    reloadButton.image = UIImage(named: "reloadButton")
    reloadButton.delegate = self
    reloadButton.alpha = 0.0
    addSubview(reloadButton)
    reloadButton.centerInSuperview()
    reloadButton.width(RELOAD_BUTTON_HEIGHT)
    reloadButton.height(RELOAD_BUTTON_HEIGHT)
    self.reloadButton = reloadButton
    
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
    notiTableView.alpha = 0.0
    notiTableView.alwaysBounceVertical = true
    notiTableView.dataSource = self
    notiTableView.delegate = self
    let refreshControl = UIRefreshControl()
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
        
        cell.noti = notifications[indexPath.row]
        
        return cell
      } else {
        let basicNotiId = NSStringFromClass(ANIBasicNotiViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: basicNotiId, for: indexPath) as! ANIBasicNotiViewCell
        
        cell.noti = notifications[indexPath.row]
        
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
}

//MARK: data
extension ANINotiView {
  @objc private func loadNoti(sender: UIRefreshControl?) {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid,
          let activityIndicatorView = self.activityIndicatorView,
          let reloadButton = self.reloadButton,
          let notiTableView = self.notiTableView else { return }

    reloadButton.alpha = 0.0
    
    if !self.notifications.isEmpty {
      self.notifications.removeAll()
    }
    
    if sender == nil {
      activityIndicatorView.startAnimating()
    }
    
    let database = Firestore.firestore()
    
    database.collection(KEY_USERS).document(currentUserUid).collection(KEY_NOTIFICATIONS).order(by: KEY_NOTI_UPDATE_DATE, descending: true).limit(to: 20).getDocuments { (snapshot, error) in
      if let error = error {
        print("Error get document: \(error)")
        
        return
      }
      
      guard let snapshot = snapshot else { return }
      
      for document in snapshot.documents {
        do {
          let notification = try FirestoreDecoder().decode(FirebaseNotification.self, from: document.data())
          self.notifications.append(notification)
          
          DispatchQueue.main.async {
            if let sender = sender {
              sender.endRefreshing()
            }
            
            activityIndicatorView.stopAnimating()
            
            notiTableView.reloadData()
            
            UIView.animate(withDuration: 0.2, animations: {
              notiTableView.alpha = 1.0
            })
          }
        } catch let error {
          print(error)
          
          activityIndicatorView.stopAnimating()
          
          UIView.animate(withDuration: 0.2, animations: {
            reloadButton.alpha = 1.0
          })
          
          if let sender = sender {
            sender.endRefreshing()
          }
        }
      }
      
      if snapshot.documents.isEmpty {
        if !self.notifications.isEmpty {
          self.notifications.removeAll()
        }
        
        if let sender = sender {
          sender.endRefreshing()
        }
        
        activityIndicatorView.stopAnimating()
        
        notiTableView.alpha = 0.0
        
        UIView.animate(withDuration: 0.2, animations: {
          reloadButton.alpha = 1.0
        })
      }
    }
  }
}

//MARK: ANIButtonViewDelegate
extension ANINotiView: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === reloadButton {
      loadNoti(sender: nil)
    }
  }
}
