//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

protocol ANIRecruitViewDelegate {
  func recruitCellTap(selectedRecruit: FirebaseRecruit, user: FirebaseUser)
  func recruitViewDidScroll(scrollY: CGFloat)
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser)
  func reject()
}

class ANIRecuruitView: UIView {

  private weak var recruitTableView: UITableView? {
    didSet {
      guard let recruitTableView = self.recruitTableView else { return }
      let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT
      recruitTableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    }
  }
  
  private var recruits = [FirebaseRecruit]()
  
  var delegate:ANIRecruitViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupNotifications()
    loadRecruit(sender: nil)
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
    tableView.backgroundColor = ANIColor.bg
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    tableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.delegate = self
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(loadRecruit(sender:)), for: .valueChanged)
    tableView.addSubview(refreshControl)
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.recruitTableView = tableView
  }
  
  //MARK: Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(logout: self, selector: #selector(reloadRecruit))
    ANINotificationManager.receive(login: self, selector: #selector(reloadRecruit))
    ANINotificationManager.receive(recruitTabTapped: self, selector: #selector(scrollToTop))
  }
  
  @objc private func loadRecruit(sender: UIRefreshControl?) {
    if !self.recruits.isEmpty {
      self.recruits.removeAll()
    }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_RECRUITS).queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snapshot) in
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot, let value = snapshot.value {
            do {
              let recruit = try FirebaseDecoder().decode(FirebaseRecruit.self, from: value)
              self.recruits.insert(recruit, at: 0)
              
              DispatchQueue.main.async {
                if let sender = sender {
                  sender.endRefreshing()
                }
    
                guard let recruitTableView = self.recruitTableView else { return }
                recruitTableView.reloadData()
              }
            } catch let error {
              print(error)
              
              if let sender = sender {
                sender.endRefreshing()
              }
            }
          }
        }
        
        if let sender = sender, snapshot.value as? [String: AnyObject] == nil {
          sender.endRefreshing()
        }
      })
    }
  }
  
  @objc private func reloadRecruit() {
    loadRecruit(sender: nil)
  }
  
  @objc private func scrollToTop() {
    guard let recruitTableView = recruitTableView,
          !recruits.isEmpty else { return }
    
    recruitTableView.scrollToRow(at: [0, 0], at: .top, animated: true)
  }
}

//MARK: UITableViewDataSource
extension ANIRecuruitView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recruits.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIRecruitViewCell
    
    if !recruits.isEmpty {
      cell.recruit = recruits[indexPath.row]
      cell.delegate = self
    }
    
    return cell
  }
}

//MARK: UITableViewDelegate
extension ANIRecuruitView: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ANINotificationManager.postViewScrolled()
    
    //navigation bar animation
    let scrollY = scrollView.contentOffset.y
    self.delegate?.recruitViewDidScroll(scrollY: scrollY)
  }
  
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? ANIRecruitViewCell {
      cell.unobserveLove()
      cell.unobserveSupport()
    }
  }
}

//MARK: ANIRecruitViewCellDelegate
extension ANIRecuruitView: ANIRecruitViewCellDelegate {
  func cellTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.recruitCellTap(selectedRecruit: recruit, user: user)
  }
  
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportButtonTapped(supportRecruit: supportRecruit, user: user)
  }
  
  func reject() {
    self.delegate?.reject()
  }
}
