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
import AVKit

protocol ANIStoryViewDelegate {
  func didSelectStoryViewCell(selectedStory: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func reject()
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String)
  func didSelectRankingCell(rankingStory: FirebaseStory, ranking: Int)
}

class ANIStoryView: UIView {
  
  private weak var reloadView: ANIReloadView?
  
  private weak var storyTableView: UITableView?
  
  private weak var refreshControl: UIRefreshControl?
  
  private var stories = [FirebaseStory]()
  private var supportRecruits = [String: FirebaseRecruit?]()
  private var storyVideoAssets = [String: AVAsset]()
  private var rankingStories = [FirebaseStory]()
  private var users = [FirebaseUser]()
  
  private var isLastStoryPage: Bool = false
  private var lastStory: QueryDocumentSnapshot?
  private var isLoading: Bool = false
  private let COUNT_LAST_CELL: Int = 4
  
  private var lastRankingStory: QueryDocumentSnapshot?
  
  private weak var activityIndicatorView: ANIActivityIndicator?

  var isCellSelected: Bool = false
  
  private var beforeVideoViewCell: ANIVideoStoryViewCell?
  
  var delegate: ANIStoryViewDelegate?
  
  static var shared: ANIStoryView?
  
  private var cellHeight = [IndexPath: CGFloat]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupNotifications()
    
    if ANISessionManager.shared.isLaunchNoti {
      loadStory(sender: nil)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = ANIColor.bg
    
    //reloadView
    let reloadView = ANIReloadView()
    reloadView.alpha = 0.0
    reloadView.messege = "ストーリーがありません。"
    reloadView.delegate = self
    addSubview(reloadView)
    reloadView.dropShadow()
    reloadView.centerInSuperview()
    reloadView.leftToSuperview(offset: 50.0)
    reloadView.rightToSuperview(offset: -50.0)
    self.reloadView = reloadView
    
    //tableView
    let tableView = UITableView()
    tableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: UIViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
    let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
    tableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellId)
    let videoStoryCellId = NSStringFromClass(ANIVideoStoryViewCell.self)
    tableView.register(ANIVideoStoryViewCell.self, forCellReuseIdentifier: videoStoryCellId)
    let supportCellId = NSStringFromClass(ANISupportViewCell.self)
    tableView.register(ANISupportViewCell.self, forCellReuseIdentifier: supportCellId)
    let rankingCellId = NSStringFromClass(ANIRankingViewCell.self)
    tableView.register(ANIRankingViewCell.self, forCellReuseIdentifier: rankingCellId)
    tableView.separatorStyle = .none
    tableView.backgroundColor = ANIColor.bg
    tableView.dataSource = self
    tableView.delegate = self
    tableView.alpha = 0.0
    tableView.rowHeight = UITableView.automaticDimension
    let refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = .clear
    refreshControl.tintColor = ANIColor.moreDarkGray
    refreshControl.addTarget(self, action: #selector(reloadData(sender:)), for: .valueChanged)
    tableView.addSubview(refreshControl)
    self.refreshControl = refreshControl
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.storyTableView = tableView
    
    //activityIndicatorView
    let activityIndicatorView = ANIActivityIndicator()
    activityIndicatorView.isFull = false
    self.addSubview(activityIndicatorView)
    activityIndicatorView.edgesToSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  @objc private func reloadData(sender:  UIRefreshControl?) {
    self.loadStory(sender: sender)
  }
  
  static func endRefresh() {
    guard let shared = ANIStoryView.shared,
          let refreshControl = shared.refreshControl,
          let storyTableView = shared.storyTableView else { return }
    
    refreshControl.endRefreshing()
    
    let topInset = ANICommunityViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT
    if storyTableView.contentOffset.y + topInset < 0 {
      storyTableView.scrollToRow(at: [0, 0], at: .top, animated: false)
    }
  }
  
  //MARK: Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(logout: self, selector: #selector(reloadStory))
    ANINotificationManager.receive(communityTabTapped: self, selector: #selector(scrollToTop))
    ANINotificationManager.receive(deleteStory: self, selector: #selector(deleteStory))
    ANINotificationManager.receive(loadedCurrentUser: self, selector: #selector(reloadStory))
    ANINotificationManager.postDidSetupViewNotifications()
  }
  
  @objc private func reloadStory() {
    guard let storyTableView = self.storyTableView else { return }
    
    storyTableView.alpha = 0.0
    
    self.loadStory(sender: nil)
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
        if rankingStories.isEmpty {
          indexPath = [0, index]
        } else {
          indexPath = [0, index + 1]
        }
      }
    }
    
    if stories.isEmpty {
      storyTableView.reloadData()
      storyTableView.alpha = 0.0
      showReloadView()
    } else {
      storyTableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
  private func showReloadView() {
    guard let reloadView = self.reloadView,
          let storyTableView = self.storyTableView else { return }
    
    storyTableView.alpha = 0.0
    
    UIView.animate(withDuration: 0.2, animations: {
      reloadView.alpha = 1.0
    }) { (complete) in
      ANISessionManager.shared.isLoadedFirstData = true
      ANINotificationManager.postDismissSplash()
    }
  }
  
  private func isBlockStory(story: FirebaseStory) -> Bool {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid else { return false }
    
    if let blockUserIds = ANISessionManager.shared.blockUserIds, blockUserIds.contains(story.userId) {
      return true
    }
    if let blockingUserIds = ANISessionManager.shared.blockingUserIds, blockingUserIds.contains(story.userId) {
      return true
    }
    if let hideUserIds = story.hideUserIds, hideUserIds.contains(currentUserUid) {
      return true
    }
    if story.storyImageUrls == nil && story.recruitId == nil && story.thumbnailImageUrl == nil {
      return true
    }
    
    return false
  }
}

//MARK: UITableViewDataSource
extension ANIStoryView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if rankingStories.isEmpty {
      return stories.count
    } else {
      return stories.count + 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if rankingStories.isEmpty {
      if !stories.isEmpty {
        if let recruitId = stories[indexPath.row].recruitId {
          let supportCellId = NSStringFromClass(ANISupportViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
          cell.delegate = self

          if let supportRecruit = supportRecruits[recruitId] {
            if let supportRecruit = supportRecruit {
              cell.recruit = supportRecruit
              cell.isDeleteRecruit = false
            } else {
              cell.recruit = nil
              cell.isDeleteRecruit = true
            }
          } else {
            cell.recruit = nil
            cell.isDeleteRecruit = nil
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
          cell.indexPath = indexPath.row
          cell.story = stories[indexPath.row]
          
          return cell
        } else if stories[indexPath.row].thumbnailImageUrl != nil {
          let videoStoryCellId = NSStringFromClass(ANIVideoStoryViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: videoStoryCellId, for: indexPath) as! ANIVideoStoryViewCell
          cell.delegate = self
          
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
          
          if let storyVideoUrl = stories[indexPath.row].storyVideoUrl,
            storyVideoAssets.contains(where: { $0.0 == storyVideoUrl }) {
            cell.videoAsset = storyVideoAssets[storyVideoUrl]
          } else {
            cell.videoAsset = nil
          }
          
          cell.indexPath = indexPath.row
          cell.story = stories[indexPath.row]
          
          return cell
        } else {
          let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
          cell.delegate = self
          
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
          cell.indexPath = indexPath.row
          cell.story = stories[indexPath.row]
          
          return cell
        }
      } else {
        return UITableViewCell()
      }
    } else {
      if indexPath.row == 0 {
        let rankingCellId = NSStringFromClass(ANIRankingViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: rankingCellId, for: indexPath) as! ANIRankingViewCell
        cell.delegate = self
        
        cell.rankingStories = rankingStories
        
        return cell
      } else {
        if !stories.isEmpty {
          if let recruitId = stories[indexPath.row - 1].recruitId {
            let supportCellId = NSStringFromClass(ANISupportViewCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
            cell.delegate = self

            if let supportRecruit = supportRecruits[recruitId] {
              if let supportRecruit = supportRecruit {
                cell.recruit = supportRecruit
                cell.isDeleteRecruit = false
              } else {
                cell.recruit = nil
                cell.isDeleteRecruit = true
              }
            } else {
              cell.recruit = nil
              cell.isDeleteRecruit = nil
            }
            
            if users.contains(where: { $0.uid == stories[indexPath.row - 1].userId }) {
              for user in users {
                if stories[indexPath.row - 1].userId == user.uid {
                  cell.user = user
                  break
                }
              }
            } else {
              cell.user = nil
            }
            cell.indexPath = indexPath.row - 1
            cell.story = stories[indexPath.row - 1]
            
            return cell
          } else if stories[indexPath.row - 1].thumbnailImageUrl != nil {
            let videoStoryCellId = NSStringFromClass(ANIVideoStoryViewCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: videoStoryCellId, for: indexPath) as! ANIVideoStoryViewCell
            cell.delegate = self
            
            if users.contains(where: { $0.uid == stories[indexPath.row - 1].userId }) {
              for user in users {
                if stories[indexPath.row - 1].userId == user.uid {
                  cell.user = user
                  break
                }
              }
            } else {
              cell.user = nil
            }
            
            if let storyVideoUrl = stories[indexPath.row - 1].storyVideoUrl,
              storyVideoAssets.contains(where: { $0.0 == storyVideoUrl }) {
              cell.videoAsset = storyVideoAssets[storyVideoUrl]
            } else {
              cell.videoAsset = nil
            }
            
            cell.indexPath = indexPath.row - 1
            cell.story = stories[indexPath.row - 1]
            
            return cell
          } else {
            let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
            cell.delegate = self

            if users.contains(where: { $0.uid == stories[indexPath.row - 1].userId }) {
              for user in users {
                if stories[indexPath.row - 1].userId == user.uid {
                  cell.user = user
                  break
                }
              }
            } else {
              cell.user = nil
            }
            cell.indexPath = indexPath.row - 1
            cell.story = stories[indexPath.row - 1]
            
            return cell
          }
        } else {
          return UITableViewCell()
        }
      }
    }
  }
}

//MARK: UITableViewDelegate
extension ANIStoryView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if rankingStories.isEmpty {
      if !stories.isEmpty {
        if stories[indexPath.row].recruitId != nil, let cell = cell as? ANISupportViewCell {
          cell.unobserveLove()
          cell.unobserveComment()
        } else if stories[indexPath.row].thumbnailImageUrl != nil, let cell = cell as? ANIVideoStoryViewCell {
          cell.unobserveLove()
          cell.unobserveComment()
          cell.storyVideoView?.removeReachEndObserver()
          cell.storyVideoView?.stop()
        } else if let cell = cell as? ANIStoryViewCell {
          cell.unobserveLove()
          cell.unobserveComment()
        }
      }
    } else {
      if indexPath.row != 0, !stories.isEmpty {
        if stories[indexPath.row - 1].recruitId != nil, let cell = cell as? ANISupportViewCell {
          cell.unobserveLove()
          cell.unobserveComment()
        } else if stories[indexPath.row - 1].thumbnailImageUrl != nil, let cell = cell as? ANIVideoStoryViewCell {
          cell.unobserveLove()
          cell.unobserveComment()
          cell.storyVideoView?.removeReachEndObserver()
          cell.storyVideoView?.stop()
        } else if let cell = cell as? ANIStoryViewCell {
          cell.unobserveLove()
          cell.unobserveComment()
        }
      }
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if rankingStories.isEmpty {
      let element = self.stories.count - COUNT_LAST_CELL
      
      if !isLoading, indexPath.row >= element {
        loadMoreStory()
      }
    } else {
      if indexPath.row != 0 {
        let element = self.stories.count - COUNT_LAST_CELL
        
        if !isLoading, indexPath.row - 1 >= element {
          loadMoreStory()
        }
      }
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
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let storyTableView = self.storyTableView else { return }
    
    //play video
    let centerX = storyTableView.center.x
    let centerY = storyTableView.center.y + scrollView.contentOffset.y + UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT

    if let indexPath = storyTableView.indexPathForRow(at: CGPoint(x: centerX, y: centerY)) {
      if let videoCell = storyTableView.cellForRow(at: indexPath) as? ANIVideoStoryViewCell,
        let storyVideoView = videoCell.storyVideoView {
        if beforeVideoViewCell != videoCell {
          if let beforeVideoViewCell = self.beforeVideoViewCell,
            let beforeStoryVideoView = beforeVideoViewCell.storyVideoView {
            beforeStoryVideoView.stop()
          }
          
          storyVideoView.play()
          beforeVideoViewCell = videoCell
        }
      } else {
        if let beforeVideoViewCell = self.beforeVideoViewCell,
          let beforeStoryVideoView = beforeVideoViewCell.storyVideoView {
          beforeStoryVideoView.stop()
        }
        
        beforeVideoViewCell = nil
      }
    }
  }
}

//MARK: ANIStoryViewCellDelegate, ANIVideoStoryViewCellDelegate
extension ANIStoryView: ANIStoryViewCellDelegate, ANIVideoStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.didSelectStoryViewCell(selectedStory: story, user: user)
  }
  
  func reject() {
    self.delegate?.reject()
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, contentType: contentType, id: id)
  }
  
  func loadedStoryIsLoved(indexPath: Int, isLoved: Bool) {
    if !self.stories.isEmpty {
      var story = self.stories[indexPath]
      story.isLoved = isLoved
      self.stories[indexPath] = story
    }
  }
  
  func loadedStoryUser(user: FirebaseUser) {
    self.users.append(user)
  }
  
  func loadedVideo(urlString: String, asset: AVAsset) {
    storyVideoAssets[urlString] = asset
  }
}

//MARK: ANISupportViewCellDelegate
extension ANIStoryView: ANISupportViewCellDelegate {
  func supportCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.didSelectStoryViewCell(selectedStory: story, user: user)
  }
  
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportCellRecruitTapped(recruit: recruit, user: user)
  }
  
  func loadedRecruit(recruitId: String, recruit: FirebaseRecruit?) {
    self.supportRecruits[recruitId] = recruit
  }
}

//MARK: ANIRankingViewCellDelegate
extension ANIStoryView: ANIRankingViewCellDelegate {
  func didSelectRankingCell(rankingStory: FirebaseStory, ranking: Int) {
    self.delegate?.didSelectRankingCell(rankingStory: rankingStory, ranking: ranking)
  }
}

//MARK: data
extension ANIStoryView {
  private func loadStory(sender: UIRefreshControl?) {
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
    if !self.rankingStories.isEmpty {
      self.rankingStories.removeAll()
    }
    
    if sender == nil {
      activityIndicatorView.startAnimating()
    }
    
    let database = Firestore.firestore()
    
    let group = DispatchGroup()
    
    //story
    group.enter()
    DispatchQueue(label: "story").async {
      self.isLoading = true
      self.isLastStoryPage = false
      
      database.collection(KEY_STORIES).order(by: KEY_DATE, descending: true).limit(to: 15).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          group.leave()
          
          return
        }
        
        guard let snapshot = snapshot,
              let lastStory = snapshot.documents.last else {
                if !self.stories.isEmpty {
                  self.stories.removeAll()
                }
                
                group.leave()
                return }
        
        self.lastStory = lastStory
        
        for (index, document) in snapshot.documents.enumerated() {
          do {
            let story = try FirestoreDecoder().decode(FirebaseStory.self, from: document.data())
            
            if !self.isBlockStory(story: story) {
              if let storyVideoUrl = story.storyVideoUrl, let url = URL(string: storyVideoUrl) {
                let asset = AVAsset(url: url)
                
                self.storyVideoAssets[storyVideoUrl] = asset
              }
              
              self.stories.append(story)
            }
            
            DispatchQueue.main.async {
              if index + 1 == snapshot.documents.count {
                group.leave()
              }
            }
          } catch let error {
            DLog(error)
            
            group.leave()
          }
        }
      })
    }
    
    //ranking story
    if !self.rankingStories.isEmpty {
      self.rankingStories.removeAll()
    }
    
    let today = ANIFunction.shared.getToday(format: "yyyy/MM/dd")
    
    group.enter()
    DispatchQueue(label: "story").async {
      database.collection(KEY_STORIES).whereField(KEY_DAY, isEqualTo: today).order(by: KEY_LOVE_COUNT, descending: true).order(by: KEY_DATE, descending: true).limit(to: 3).getDocuments { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          group.leave()
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        if let lastRankingStory = snapshot.documents.last {
          self.lastRankingStory = lastRankingStory
          
          for (index, document) in snapshot.documents.enumerated() {
            do {
              let story = try FirestoreDecoder().decode(FirebaseStory.self, from: document.data())
              self.rankingStories.append(story)
              
              DispatchQueue.main.async {
                if index + 1 == snapshot.documents.count {
                  group.leave()
                }
              }
            } catch let error {
              DLog(error)
              group.leave()
            }
          }
        } else {
          group.leave()
        }
      }
    }
    
    group.notify(queue: DispatchQueue(label: "story")) {
      DispatchQueue.main.async {
        self.isLoading = false
        
        if let sender = sender {
          sender.endRefreshing()
        }
        
        activityIndicatorView.stopAnimating()

        if self.lastStory != nil {
          storyTableView.reloadData()
          
          if self.stories.isEmpty {
            self.loadMoreStory()
          } else {
            if storyTableView.alpha == 0 {
              UIView.animate(withDuration: 0.2, animations: {
                storyTableView.alpha = 1.0
              })
              ANISessionManager.shared.isLoadedFirstData = true
              
              ANINotificationManager.postDismissSplash()
            }
          }
        } else {
          self.showReloadView()
        }
      }
    }
  }
  
  private func loadMoreStory() {
    guard let storyTableView = self.storyTableView,
          let lastStory = self.lastStory,
          let activityIndicatorView = self.activityIndicatorView,
          !isLoading,
          !isLastStoryPage else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      self.isLoading = true
      
      database.collection(KEY_STORIES).order(by: KEY_DATE, descending: true).start(afterDocument: lastStory).limit(to: 15).getDocuments(completion: { (snapshot, error) in
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
            
            if !self.isBlockStory(story: story) {
              if let storyVideoUrl = story.storyVideoUrl, let url = URL(string: storyVideoUrl) {
                let asset = AVAsset(url: url)
                
                self.storyVideoAssets[storyVideoUrl] = asset
              }
              
              self.stories.append(story)
            }
            
            DispatchQueue.main.async {
              if index + 1 == snapshot.documents.count {
                storyTableView.reloadData()
                
                self.isLoading = false
                
                if self.stories.isEmpty {
                  self.loadMoreStory()
                } else {
                  if storyTableView.alpha == 0 {
                    activityIndicatorView.stopAnimating()
                    
                    UIView.animate(withDuration: 0.2, animations: {
                      storyTableView.alpha = 1.0
                    })

                    ANISessionManager.shared.isLoadedFirstData = true
                    ANINotificationManager.postDismissSplash()
                  }
                }
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
