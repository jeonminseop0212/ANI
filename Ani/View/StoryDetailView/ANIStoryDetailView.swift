//
//  ANIStoryDetailView.swift
//  Ani
//
//  Created by jeonminseop on 2019/12/15.
//  Copyright © 2019 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import AVKit

protocol ANIStoryDetailViewDelegate {
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func popupOptionView(isMe: Bool, id: String)
}

class ANIStoryDetailView: UIView {
  
  private weak var tableView: UITableView?
  private weak var alertLabel: UILabel?
  
  var storyId: String? {
    didSet {
      guard let storyId = self.storyId,
            let tableView = self.tableView else { return }
      
      tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

      loadStory(storyId: storyId)
    }
  }
  
  private var story: FirebaseStory?
  private var user: FirebaseUser?
  private var storyVideoAsset: AVAsset?
  
  private var isLoading: Bool = false
  
  private var beforeVideoViewCell: ANIVideoStoryViewCell?
    
  private weak var activityIndicatorView: ANIActivityIndicator?
  
  private var scollViewContentOffsetY: CGFloat = 0.0

  var delegate: ANIStoryDetailViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //tableView
    let tableView = UITableView()
    tableView.separatorStyle = .none
    tableView.backgroundColor = ANIColor.bg
    let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
    tableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellId)
    let videoStoryCellId = NSStringFromClass(ANIVideoStoryViewCell.self)
    tableView.register(ANIVideoStoryViewCell.self, forCellReuseIdentifier: videoStoryCellId)
    tableView.alpha = 0.0
    tableView.rowHeight = UITableView.automaticDimension
    tableView.dataSource = self
    tableView.delegate = self
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.tableView = tableView
    
    //alertLabel
    let alertLabel = UILabel()
    alertLabel.alpha = 0.0
    alertLabel.text = "投稿が存在しません。"
    alertLabel.font = UIFont.systemFont(ofSize: 17)
    alertLabel.textColor = ANIColor.dark
    alertLabel.textAlignment = .center
    addSubview(alertLabel)
    alertLabel.centerYToSuperview()
    alertLabel.leftToSuperview(offset: 10.0)
    alertLabel.rightToSuperview(offset: -10.0)
    self.alertLabel = alertLabel
    
    //activityIndicatorView
    let activityIndicatorView = ANIActivityIndicator()
    activityIndicatorView.isFull = false
    self.addSubview(activityIndicatorView)
    activityIndicatorView.edgesToSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  func playVideo() {
    guard let tableView = self.tableView else { return }
    
    if scollViewContentOffsetY != 0 {
      let centerX = tableView.center.x
      let centerY = tableView.center.y + scollViewContentOffsetY + UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT
      
      if let indexPath = tableView.indexPathForRow(at: CGPoint(x: centerX, y: centerY)) {
        if let videoCell = tableView.cellForRow(at: indexPath) as? ANIVideoStoryViewCell,
          let storyVideoView = videoCell.storyVideoView {
          storyVideoView.play()
        }
      }
    } else {
      let indexPath = IndexPath(row: 0, section: 0)
      if let videoCell = tableView.cellForRow(at: indexPath) as? ANIVideoStoryViewCell,
        let storyVideoView = videoCell.storyVideoView {
        storyVideoView.play()
      }
    }
  }
  
  func stopVideo() {
    guard let tableView = self.tableView else { return }
    
    if scollViewContentOffsetY != 0 {
      let centerX = tableView.center.x
      let centerY = tableView.center.y + scollViewContentOffsetY + UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT
      
      if let indexPath = tableView.indexPathForRow(at: CGPoint(x: centerX, y: centerY)) {
        if let videoCell = tableView.cellForRow(at: indexPath) as? ANIVideoStoryViewCell,
          let storyVideoView = videoCell.storyVideoView {
          storyVideoView.stop()
        }
      }
    } else {
      let indexPath = IndexPath(row: 0, section: 0)
      if let videoCell = tableView.cellForRow(at: indexPath) as? ANIVideoStoryViewCell,
        let storyVideoView = videoCell.storyVideoView {
        storyVideoView.stop()
      }
    }
  }
  
  private func loadDone() {
    guard let tableView = self.tableView,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    activityIndicatorView.stopAnimating()
    
    tableView.reloadData()
    
    self.isLoading = false

    UIView.animate(withDuration: 0.2, animations: {
      tableView.alpha = 1.0
    })
  }
  
  private func isBlockUser(user: FirebaseUser) -> Bool {
    guard let userId = user.uid else { return false }
    
    if let blockUserIds = ANISessionManager.shared.blockUserIds, blockUserIds.contains(userId) {
      return true
    }
    if let blockingUserIds = ANISessionManager.shared.blockingUserIds, blockingUserIds.contains(userId) {
      return true
    }
    
    return false
  }
}

//MARK: UITableViewDataSource
extension ANIStoryDetailView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let story = self.story else { return UITableViewCell() }

    if story.thumbnailImageUrl != nil {
      let videoStoryCellId = NSStringFromClass(ANIVideoStoryViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: videoStoryCellId, for: indexPath) as! ANIVideoStoryViewCell
      cell.delegate = self

      if let user = self.user {
        cell.user = user
      }

      if let storyVideoAsset = self.storyVideoAsset {
        cell.videoAsset = storyVideoAsset
      } else {
        cell.videoAsset = nil
      }

      cell.indexPath = indexPath.row
      cell.story = story

      return cell
    } else {
      let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
      cell.delegate = self

      if let user = self.user {
        cell.user = user
      }
      cell.indexPath = indexPath.row
      cell.story = story

      return cell
    }
  }
}

//MARK: UITableViewDelegate
extension ANIStoryDetailView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let story = self.story {
      if story.recruitId != nil, let cell = cell as? ANISupportViewCell {
        cell.unobserveLove()
        cell.unobserveComment()
      } else if story.thumbnailImageUrl != nil, let cell = cell as? ANIVideoStoryViewCell {
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
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let tableView = self.tableView else { return }
    
    scollViewContentOffsetY = scrollView.contentOffset.y
    
    //play video
    let centerX = tableView.center.x
    let centerY = tableView.center.y + scrollView.contentOffset.y + UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT
    
    if let indexPath = tableView.indexPathForRow(at: CGPoint(x: centerX, y: centerY)) {
      if let videoCell = tableView.cellForRow(at: indexPath) as? ANIVideoStoryViewCell,
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
extension ANIStoryDetailView: ANIStoryViewCellDelegate, ANIVideoStoryViewCellDelegate {
  func reject() {
  }
  
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, id: id)
  }
  
  func loadedStoryIsLoved(indexPath: Int, isLoved: Bool) {
    guard let story = self.story else { return }
    
    var newStory = story
    newStory.isLoved = isLoved
    self.story = newStory
  }
  
  func loadedStoryUser(user: FirebaseUser) {
    self.user = user
  }
  
  func loadedVideo(urlString: String, asset: AVAsset) {
    self.storyVideoAsset = asset
  }
}

//MARK: data
extension ANIStoryDetailView {
  private func loadStory(storyId: String) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let storyId = self.storyId else { return }

    let database = Firestore.firestore()
    
    activityIndicatorView.startAnimating()

    DispatchQueue.global().async {
      database.collection(KEY_STORIES).document(storyId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        if let snapshot = snapshot, let data = snapshot.data() {
          do {
            let story = try FirestoreDecoder().decode(FirebaseStory.self, from: data)
            if let storyVideoUrl = story.storyVideoUrl, let url = URL(string: storyVideoUrl) {
              let asset = AVAsset(url: url)
              self.storyVideoAsset = asset
            }
            
            self.story = story
            
            DispatchQueue.main.async {
              self.loadDone()
            }
          } catch let error {
            DLog(error)
            
            activityIndicatorView.stopAnimating()
          }
        } else {
          guard let alertLabel = self.alertLabel else { return }
          
          activityIndicatorView.stopAnimating()

          UIView.animate(withDuration: 0.2, animations: {
            alertLabel.alpha = 1.0
          })
        }
      })
    }
  }
}
