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

protocol ANIStoryViewDelegate {
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
}

class ANIStoryView: UIView {
  
  private weak var storyTableView: UITableView?
  
  private var stories = [FirebaseStory]()
  
  var delegate: ANIStoryViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadStory(sender: nil)
    setup()
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
    let tableView = UITableView()
    tableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: UIViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
    tableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellId)
    let supportCellId = NSStringFromClass(ANISupportViewCell.self)
    tableView.register(ANISupportViewCell.self, forCellReuseIdentifier: supportCellId)
    tableView.separatorStyle = .none
    tableView.backgroundColor = ANIColor.bg
    tableView.dataSource = self
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(loadStory(sender:)), for: .valueChanged)
    tableView.addSubview(refreshControl)
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.storyTableView = tableView
  }
  
  //MARK: Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(logout: self, selector: #selector(reloadStory))
    ANINotificationManager.receive(login: self, selector: #selector(reloadStory))
  }
  
  @objc private func loadStory(sender: UIRefreshControl?) {
    if !self.stories.isEmpty {
      self.stories.removeAll()
    }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_STORIES).queryLimited(toFirst: 20).observe(.value, with: { (snapshot) in
        databaseRef.child(KEY_STORIES).removeAllObservers()
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot, let value = snapshot.value {
            do {
              let story = try FirebaseDecoder().decode(FirebaseStory.self, from: value)
              self.stories.insert(story, at: 0)
              
              DispatchQueue.main.async {
                if let sender = sender {
                  sender.endRefreshing()
                }
                
                guard let storyTableView = self.storyTableView else { return }
                storyTableView.reloadData()
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
  
  @objc private func reloadStory() {
    loadStory(sender: nil)
  }
}

//MARK: UITableViewDataSource
extension ANIStoryView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return stories.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if !stories.isEmpty {
      if stories[indexPath.row].recruitId != nil {
        let supportCellId = NSStringFromClass(ANISupportViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
        
        cell.story = stories[indexPath.row]
        cell.observeStory()
        cell.delegate = self
        
        return cell
      } else {
        let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
        
        cell.story = stories[indexPath.row]
        cell.observeStory()
        cell.delegate = self
        
        return cell
      }
    } else {
      return UITableViewCell()
    }
  }
}

//MARK: ANIStoryViewCellDelegate
extension ANIStoryView: ANIStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
}

//MARK: ANISupportViewCellDelegate
extension ANIStoryView: ANISupportViewCellDelegate {
  func supportCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportCellRecruitTapped(recruit: recruit, user: user)
  }
}
