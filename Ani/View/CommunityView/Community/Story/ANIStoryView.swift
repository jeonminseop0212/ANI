//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import NVActivityIndicatorView

protocol ANIStoryViewDelegate {
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func reject()
}

class ANIStoryView: UIView {
  
  private weak var storyTableView: UITableView?
  
  private var stories = [FirebaseStory]()
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var isCellSelected: Bool = false
  
  var delegate: ANIStoryViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    loadStory(sender: nil)
    setupNotifications()
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
    
    //tableView
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
    tableView.delegate = self
    tableView.alpha = 0.0
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(loadStory(sender:)), for: .valueChanged)
    tableView.addSubview(refreshControl)
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.storyTableView = tableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.green, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  //MARK: Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(logout: self, selector: #selector(reloadStory))
    ANINotificationManager.receive(login: self, selector: #selector(reloadStory))
    ANINotificationManager.receive(communityTabTapped: self, selector: #selector(scrollToTop))
  }
  
  @objc private func reloadStory() {
    loadStory(sender: nil)
  }
  
  @objc private func scrollToTop() {
    guard let storyTableView = storyTableView,
          !stories.isEmpty,
          isCellSelected else { return }
    
    storyTableView.scrollToRow(at: [0, 0], at: .top, animated: true)
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
        cell.delegate = self
        
        return cell
      } else {
        let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
        
        cell.story = stories[indexPath.row]
        cell.delegate = self
        
        return cell
      }
    } else {
      return UITableViewCell()
    }
  }
}

//MARK: UITableViewDelegate
extension ANIStoryView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if !stories.isEmpty {
      if stories[indexPath.row].recruitId != nil, let cell = cell as? ANISupportViewCell {
        cell.unobserveLove()
        cell.unobserveComment()
      } else if let cell = cell as? ANIStoryViewCell {
        cell.unobserveLove()
        cell.unobserveComment()
      }
    }
  }
}

//MARK: ANIStoryViewCellDelegate
extension ANIStoryView: ANIStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func reject() {
    self.delegate?.reject()
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

//MARK: data
extension ANIStoryView {
  @objc private func loadStory(sender: UIRefreshControl?) {
    guard let activityIndicatorView = self.activityIndicatorView else { return }
    
    if !self.stories.isEmpty {
      self.stories.removeAll()
    }
    
    if sender == nil {
      activityIndicatorView.startAnimating()
    }
    
    DispatchQueue.global().async {
      let database = Firestore.firestore()
      database.collection(KEY_STORIES).order(by: KEY_DATE, descending: true).limit(to: 20).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          do {
            let story = try FirestoreDecoder().decode(FirebaseStory.self, from: document.data())
            self.stories.append(story)
            
            DispatchQueue.main.async {
              if let sender = sender {
                sender.endRefreshing()
              }
              
              guard let storyTableView = self.storyTableView else { return }
              
              activityIndicatorView.stopAnimating()
              
              storyTableView.reloadData()
              
              UIView.animate(withDuration: 0.2, animations: {
                storyTableView.alpha = 1.0
              })
            }
          } catch let error {
            print(error)
            
            activityIndicatorView.stopAnimating()
            
            if let sender = sender {
              sender.endRefreshing()
            }
          }
        }
        
        if let sender = sender, snapshot.documents.isEmpty {
          sender.endRefreshing()
          
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
}
