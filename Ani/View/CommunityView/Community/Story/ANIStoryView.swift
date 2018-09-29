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
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String)
}

class ANIStoryView: UIView {
  
  private weak var reloadView: ANIReloadView?
  
  private weak var storyTableView: UITableView?
  
  private var stories = [FirebaseStory]()
  private var supportRecruits = [FirebaseRecruit]()
  private var users = [FirebaseUser]()
  
  private var isLastStoryPage: Bool = false
  private var lastStory: QueryDocumentSnapshot?
  private var isLoading: Bool = false
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var isCellSelected: Bool = false
  
  var delegate: ANIStoryViewDelegate?
  
  private var cellHeight = [IndexPath: CGFloat]()
  
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
    
    //reloadView
    let reloadView = ANIReloadView()
    reloadView.alpha = 0.0
    reloadView.messege = "ストーリーがありません。"
    reloadView.delegate = self
    addSubview(reloadView)
    reloadView.dropShadow()
    reloadView.centerInSuperview()
    reloadView.leftToSuperview(offset: 50.0)
    reloadView.rightToSuperview(offset: 50.0)
    self.reloadView = reloadView
    
    //tableView
    let tableView = UITableView()
    tableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: bottomSafeArea, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: UIViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: bottomSafeArea, right: 0)
    let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
    tableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellId)
    let supportCellId = NSStringFromClass(ANISupportViewCell.self)
    tableView.register(ANISupportViewCell.self, forCellReuseIdentifier: supportCellId)
    tableView.separatorStyle = .none
    tableView.backgroundColor = ANIColor.bg
    tableView.dataSource = self
    tableView.delegate = self
    tableView.alpha = 0.0
    tableView.rowHeight = UITableView.automaticDimension
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
    ANINotificationManager.receive(deleteStory: self, selector: #selector(deleteStory))
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
  
  @objc private func deleteStory(_ notification: NSNotification) {
    guard let id = notification.object as? String,
          let storyTableView = self.storyTableView else { return }
    
    var indexPath: IndexPath = [0, 0]
    
    for (index, story) in stories.enumerated() {
      if story.id == id {
        stories.remove(at: index)
        indexPath = [0, index]
      }
    }
    
    storyTableView.deleteRows(at: [indexPath], with: .automatic)
  }
  
  private func showReloadView(sender: UIRefreshControl?) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let reloadView = self.reloadView,
          let storyTableView = self.storyTableView else { return }
    
    if let sender = sender {
      sender.endRefreshing()
    }
    
    activityIndicatorView.stopAnimating()
    
    storyTableView.alpha = 0.0
    
    UIView.animate(withDuration: 0.2, animations: {
      reloadView.alpha = 1.0
    })
    
    self.isLoading = false
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
        
        if let recruitId = stories[indexPath.row].recruitId, supportRecruits.count != 0 {
          for supportRecruit in supportRecruits {
            if let supportRecruitId = supportRecruit.id, supportRecruitId == recruitId {
              cell.recruit = supportRecruit
              break
            }
          }
        } else {
          cell.recruit = nil
        }
        if users.contains(where: { $0.uid == stories[indexPath.row].userId }) {
          for user in users {
            if stories[indexPath.row].userId == user.uid {
              cell.user = user
              break
            }
          }
        } else {
          cell.user = nil
        }
        cell.story = stories[indexPath.row]
        cell.delegate = self
        cell.indexPath = indexPath.row
        
        return cell
      } else {
        let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
        
        if users.contains(where: { $0.uid == stories[indexPath.row].userId }) {
          for user in users {
            if stories[indexPath.row].userId == user.uid {
              cell.user = user
              break
            }
          }
        } else {
          cell.user = nil
        }
        cell.story = stories[indexPath.row]
        cell.delegate = self
        cell.indexPath = indexPath.row
        
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
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let element = self.stories.count - 4
    if !isLoading, indexPath.row >= element {
      loadMoreStory()
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

//MARK: ANIStoryViewCellDelegate
extension ANIStoryView: ANIStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func reject() {
    self.delegate?.reject()
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, contentType: contentType, id: id)
  }
  
  func loadedStoryIsLoved(indexPath: Int, isLoved: Bool) {
    var story = self.stories[indexPath]
    story.isLoved = isLoved
    self.stories[indexPath] = story
  }
  
  func loadedStoryUser(user: FirebaseUser) {
    self.users.append(user)
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
  
  func loadedRecruit(recruit: FirebaseRecruit) {
    self.supportRecruits.append(recruit)
  }
}

//MARK: data
extension ANIStoryView {
  @objc private func loadStory(sender: UIRefreshControl?) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let reloadView = self.reloadView,
          let storyTableView = self.storyTableView else { return }

    reloadView.alpha = 0.0
    
    if !self.stories.isEmpty {
      self.stories.removeAll()
    }
    if !self.supportRecruits.isEmpty {
      self.supportRecruits.removeAll()
    }
    if !self.users.isEmpty {
      self.users.removeAll()
    }
    
    if sender == nil {
      activityIndicatorView.startAnimating()
    }
    
    let database = Firestore.firestore()

    DispatchQueue.global().async {
      self.isLoading = true
      self.isLastStoryPage = false
      
      database.collection(KEY_STORIES).order(by: KEY_DATE, descending: true).limit(to: 10).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          self.isLoading = false
          
          return
        }
        
        guard let snapshot = snapshot,
              let lastStory = snapshot.documents.last else {
                self.showReloadView(sender: sender)
                return }
        
        self.lastStory = lastStory
        
        for document in snapshot.documents {
          do {
            let story = try FirestoreDecoder().decode(FirebaseStory.self, from: document.data())
            self.stories.append(story)
            
            DispatchQueue.main.async {
              if let sender = sender {
                sender.endRefreshing()
              }
              
              activityIndicatorView.stopAnimating()
              
              storyTableView.reloadData()
              
              UIView.animate(withDuration: 0.2, animations: {
                storyTableView.alpha = 1.0
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
          if !self.stories.isEmpty {
            self.stories.removeAll()
          }
          
          self.showReloadView(sender: sender)
        }
      })
    }
  }
  
  private func loadMoreStory() {
    guard let storyTableView = self.storyTableView,
          let lastStory = self.lastStory,
          !isLoading,
          !isLastStoryPage else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      self.isLoading = true
      
      database.collection(KEY_STORIES).order(by: KEY_DATE, descending: true).start(afterDocument: lastStory).limit(to: 10).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          self.isLoading = false
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        guard let lastStory = snapshot.documents.last else {
          self.isLastStoryPage = true
          self.isLoading = false
          return
        }
        
        self.lastStory = lastStory

        for (index, document) in snapshot.documents.enumerated() {
          do {
            let story = try FirestoreDecoder().decode(FirebaseStory.self, from: document.data())
            self.stories.append(story)
            
            DispatchQueue.main.async {
              if index + 1 == snapshot.documents.count {
                storyTableView.reloadData()
                
                self.isLoading = false
              }
            }
          } catch let error {
            DLog(error)
            self.isLoading = false
          }
        }
      })
    }
  }
}

//MARK: ANIReloadViewDelegate
extension ANIStoryView: ANIReloadViewDelegate {
  func reloadButtonTapped() {
    loadStory(sender: nil)
  }
}
