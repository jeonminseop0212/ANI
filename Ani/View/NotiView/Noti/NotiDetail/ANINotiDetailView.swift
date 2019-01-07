//
//  ANINotiDetailView.swift
//  Ani
//
//  Created by jeonminseop on 2018/07/09.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import AVKit

protocol ANINotiDetailViewDelegate {
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit, user: FirebaseUser)
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser)
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user:FirebaseUser)
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String)
}

enum ContributionKind {
  case recruit;
  case story;
  case qna;
}

enum NotiKind {
  case follow;
  case love;
  case comment;
  case support;
}

class ANINotiDetailView: UIView {
  
  private weak var tableView: UITableView?
  private weak var alertLabel: UILabel?
  
  var contributionKind: ContributionKind?
  var notiKind: NotiKind?
  
  var noti: FirebaseNotification? {
    didSet {
      guard let noti = self.noti,
            let contributionKind = self.contributionKind,
            let notiKind = self.notiKind,
            let tableView = self.tableView else { return }
      
      switch contributionKind {
      case .recruit:
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        loadRecruit(notiId: noti.notiId)
        
        loadLoveUser()
      case .story:
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        loadStory(notiId: noti.notiId)
        
        if notiKind == .comment, let commentId = noti.commentId {
            loadComment(commentId: commentId, contributionKind: .story)
        } else if notiKind == .love {
          loadLoveUser()
        }
      case .qna:
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        loadQna(notiId: noti.notiId)
        
        if notiKind == .comment, let commentId = noti.commentId {
          loadComment(commentId: commentId, contributionKind: .qna)
        } else if notiKind == .love {
          loadLoveUser()
        }
      }
    }
  }
  
  private var recruit: FirebaseRecruit?
  private var story: FirebaseStory?
  private var qna: FirebaseQna?
  private var comment: FirebaseComment?
  private var loveUsers = [FirebaseUser]()
  private var user: FirebaseUser?
  private var storyVideoAsset: AVAsset?
  
  private var isLastPage: Bool = false
  private var lastUserId: QueryDocumentSnapshot?
  private var isLoading: Bool = false
  private let COUNT_LAST_CELL: Int = 4
  private let COUNT_NOTI_AND_HEADER_CELL: Int = 2
  
  private var beforeVideoViewCell: ANIVideoStoryViewCell?
  
  private var cellHeight = [IndexPath: CGFloat]()
  
  private weak var activityIndicatorView: ANIActivityIndicator?
  
  private var scollViewContentOffsetY: CGFloat = 0.0

  var delegate: ANINotiDetailViewDelegate?
  
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
    let recruitCellId = NSStringFromClass(ANIRecruitViewCell.self)
    tableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: recruitCellId)
    let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
    tableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellId)
    let videoStoryCellId = NSStringFromClass(ANIVideoStoryViewCell.self)
    tableView.register(ANIVideoStoryViewCell.self, forCellReuseIdentifier: videoStoryCellId)
    let supportCellId = NSStringFromClass(ANISupportViewCell.self)
    tableView.register(ANISupportViewCell.self, forCellReuseIdentifier: supportCellId)
    let qnaCellId = NSStringFromClass(ANIQnaViewCell.self)
    tableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: qnaCellId)
    let headerCellId = NSStringFromClass(ANINotiHeaderViewCell.self)
    tableView.register(ANINotiHeaderViewCell.self, forCellReuseIdentifier: headerCellId)
    let commentCellId = NSStringFromClass(ANINotiCommentViewCell.self)
    tableView.register(ANINotiCommentViewCell.self, forCellReuseIdentifier: commentCellId)
    let userCellId = NSStringFromClass(ANIUserSearchViewCell.self)
    tableView.register(ANIUserSearchViewCell.self, forCellReuseIdentifier: userCellId)
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
  
  private func loadLoveUserDone() {
    guard let tableView = self.tableView,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    tableView.reloadData()
    
    self.isLoading = false
    
    if self.loveUsers.isEmpty {
      self.loadMoreLoveUser()
    } else {
      activityIndicatorView.stopAnimating()

      UIView.animate(withDuration: 0.2, animations: {
        tableView.alpha = 1.0
      })
    }
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
extension ANINotiDetailView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let contributionKind = self.contributionKind,
          let notiKind = self.notiKind else { return 0 }

    switch contributionKind {
    case .recruit:
      if notiKind == .love {
        return 2 + loveUsers.count
      }
      return 1
    case .story:
      if notiKind == .comment {
        return 3
      } else if notiKind == .love {
        return 2 + loveUsers.count
      } else {
        return 1
      }
    case .qna:
      if notiKind == .comment {
        return 3
      } else if notiKind == .love {
        return 2 + loveUsers.count
      } else {
        return 1
      }
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let contributionKind = self.contributionKind,
          let noti = self.noti else { return UITableViewCell() }
    
    switch contributionKind {
    case .recruit:
      if indexPath.row == 0 {
        let recruitCellId = NSStringFromClass(ANIRecruitViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: recruitCellId, for: indexPath) as! ANIRecruitViewCell
        
        if let user = self.user {
          cell.user = user
        }
        cell.indexPath = indexPath.row
        cell.recruit = recruit
        cell.delegate = self
        
        return cell
      } else if indexPath.row == 1 {
        let headerCellId = NSStringFromClass(ANINotiHeaderViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! ANINotiHeaderViewCell
        
        cell.headerText = "いいねユーザー"
        
        return cell
      } else {
        let userCellId = NSStringFromClass(ANIUserSearchViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! ANIUserSearchViewCell
        
        if !loveUsers.isEmpty {
          cell.user = loveUsers[indexPath.row - 2]
        }
        
        return cell
      }
    case .story:
      guard let story = self.story else { return UITableViewCell() }
      
      if story.recruitId != nil {
        if indexPath.row == 0 {
          let supportCellId = NSStringFromClass(ANISupportViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
          cell.delegate = self

          if let user = self.user {
            cell.user = user
          }
          cell.indexPath = indexPath.row
          cell.recruit = nil
          cell.isDeleteRecruit = nil
          cell.story = story
          
          return cell
        } else if indexPath.row == 1 {
          let headerCellId = NSStringFromClass(ANINotiHeaderViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! ANINotiHeaderViewCell
          
          if noti.commentId != nil {
            cell.headerText = "新しいコメント"
          } else {
            cell.headerText = "いいねユーザー"
          }
          
          return cell
        } else if noti.commentId != nil {
          let commentCellId = NSStringFromClass(ANINotiCommentViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! ANINotiCommentViewCell

          cell.comment = comment
          
          return cell
        } else {
          let userCellId = NSStringFromClass(ANIUserSearchViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! ANIUserSearchViewCell
          
          if !loveUsers.isEmpty {
            cell.user = loveUsers[indexPath.row - 2]
          }
          
          return cell
        }
      } else if story.thumbnailImageUrl != nil {
        if indexPath.row == 0 {
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
        } else if indexPath.row == 1 {
          let headerCellId = NSStringFromClass(ANINotiHeaderViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! ANINotiHeaderViewCell
          
          if noti.commentId != nil {
            cell.headerText = "新しいコメント"
          } else {
            cell.headerText = "いいねユーザー"
          }
          
          return cell
        } else if noti.commentId != nil  {
          let commentCellId = NSStringFromClass(ANINotiCommentViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! ANINotiCommentViewCell
          
          cell.comment = comment
          
          return cell
        } else {
          let userCellId = NSStringFromClass(ANIUserSearchViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! ANIUserSearchViewCell
          
          if !loveUsers.isEmpty {
            cell.user = loveUsers[indexPath.row - 2]
          }
          
          return cell
        }
      } else {
        if indexPath.row == 0 {
          let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
          cell.delegate = self

          if let user = self.user {
            cell.user = user
          }
          cell.indexPath = indexPath.row
          cell.story = story
          
          return cell
        } else if indexPath.row == 1 {
          let headerCellId = NSStringFromClass(ANINotiHeaderViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! ANINotiHeaderViewCell
          
          if noti.commentId != nil {
            cell.headerText = "新しいコメント"
          } else {
            cell.headerText = "いいねユーザー"
          }
          
          return cell
        } else if noti.commentId != nil  {
          let commentCellId = NSStringFromClass(ANINotiCommentViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! ANINotiCommentViewCell

          cell.comment = comment

          return cell
        } else {
          let userCellId = NSStringFromClass(ANIUserSearchViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! ANIUserSearchViewCell
          
          if !loveUsers.isEmpty {
            cell.user = loveUsers[indexPath.row - 2]
          }
          
          return cell
        }
      }
    case .qna:
      if indexPath.row == 0 {
        let qnaCellId = NSStringFromClass(ANIQnaViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: qnaCellId, for: indexPath) as! ANIQnaViewCell
        cell.delegate = self

        if let user = self.user {
          cell.user = user
        }
        cell.indexPath = indexPath.row
        cell.qna = qna
        
        return cell
      } else if indexPath.row == 1 {
        let headerCellId = NSStringFromClass(ANINotiHeaderViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! ANINotiHeaderViewCell
        
        if noti.commentId != nil {
          cell.headerText = "新しいコメント"
        } else {
          cell.headerText = "いいねユーザー"
        }
        
        return cell
      } else if noti.commentId != nil {
        let commentCellId = NSStringFromClass(ANINotiCommentViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! ANINotiCommentViewCell
        
        cell.comment = comment

        return cell
      } else {
        let userCellId = NSStringFromClass(ANIUserSearchViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! ANIUserSearchViewCell
        
        if !loveUsers.isEmpty {
          cell.user = loveUsers[indexPath.row - 2]
        }
        
        return cell
      }
    }
  }
}

//MARK: UITableViewDelegate
extension ANINotiDetailView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let notiKind = self.notiKind, notiKind == .love {
      let element = loveUsers.count + COUNT_NOTI_AND_HEADER_CELL - COUNT_LAST_CELL
      if !isLoading, indexPath.row >= element {
        loadMoreLoveUser()
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

//MARK: ANIRecruitViewCellDelegate
extension ANINotiDetailView: ANIRecruitViewCellDelegate {
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportButtonTapped(supportRecruit: supportRecruit, user: user)
  }
  
  func cellTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.recruitViewCellDidSelect(selectedRecruit: recruit, user: user)
  }
  
  func reject() {
  }
  
  func loadedRecruitIsLoved(indexPath: Int, isLoved: Bool) {
    guard let recruit = self.recruit else { return }
    
    var newRecruit = recruit
    newRecruit.isLoved = isLoved
    self.recruit = newRecruit
  }
  
  func loadedRecruitIsCliped(indexPath: Int, isCliped: Bool) {
    guard let recruit = self.recruit else { return }
    
    var newRecruit = recruit
    newRecruit.isCliped = isCliped
    self.recruit = newRecruit
  }
  
  func loadedRecruitIsSupported(indexPath: Int, isSupported: Bool) {
    guard let recruit = self.recruit else { return }
    
    var newRecruit = recruit
    newRecruit.isSupported = isSupported
    self.recruit = newRecruit
  }
  
  func loadedRecruitUser(user: FirebaseUser) {
    self.user = user
  }
}

//MARK: ANIStoryViewCellDelegate, ANIVideoStoryViewCellDelegate
extension ANINotiDetailView: ANIStoryViewCellDelegate, ANIVideoStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, contentType: contentType, id: id)
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

//MARK: ANISupportViewCellDelegate
extension ANINotiDetailView: ANISupportViewCellDelegate {
  func supportCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportCellRecruitTapped(recruit: recruit, user: user)
  }
  
  func loadedRecruit(recruitId: String, recruit: FirebaseRecruit?) {
  }
}

//MARK: ANIQnaViewCellDelegate
extension ANINotiDetailView: ANIQnaViewCellDelegate {
  func cellTapped(qna: FirebaseQna, user: FirebaseUser) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: user)
  }
  
  func loadedQnaIsLoved(indexPath: Int, isLoved: Bool) {
    guard let qna = self.qna else { return }
    
    var newQna = qna
    newQna.isLoved = isLoved
    self.qna = newQna
  }
  
  func loadedQnaUser(user: FirebaseUser) {
    self.user = user
  }
}

//MARK: data
extension ANINotiDetailView {
  private func loadRecruit(notiId: String) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let notiKind = self.notiKind else { return }
    
    let database = Firestore.firestore()
    
    activityIndicatorView.startAnimating()
    
    DispatchQueue.global().async {
      database.collection(KEY_RECRUITS).document(notiId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        if let snapshot = snapshot, let data = snapshot.data() {
          do {
            let recruit = try FirestoreDecoder().decode(FirebaseRecruit.self, from: data)
            self.recruit = recruit
            
            if notiKind != .love {
              DispatchQueue.main.async {
                self.loadDone()
              }
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
  
  private func loadStory(notiId: String) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let notiKind = self.notiKind else { return }

    let database = Firestore.firestore()
    
    activityIndicatorView.startAnimating()

    DispatchQueue.global().async {
      database.collection(KEY_STORIES).document(notiId).getDocument(completion: { (snapshot, error) in
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
            
            if notiKind == .support {
              DispatchQueue.main.async {
                self.loadDone()
              }
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
  
  private func loadQna(notiId: String) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let notiKind = self.notiKind else { return }

    let database = Firestore.firestore()
    
    activityIndicatorView.startAnimating()
    
    DispatchQueue.global().async {
      database.collection(KEY_QNAS).document(notiId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        if let snapshot = snapshot, let data = snapshot.data() {
          do {
            let qna = try FirestoreDecoder().decode(FirebaseQna.self, from: data)
            self.qna = qna
            
            if notiKind != .love {
              DispatchQueue.main.async {
                self.loadDone()
              }
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
  
  private func loadComment(commentId: String, contributionKind: ContributionKind) {
    guard let noti = self.noti,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    let database = Firestore.firestore()
    
    var collection: String = ""
    if contributionKind == .story {
      collection = KEY_STORIES
    } else if contributionKind == .qna {
      collection = KEY_QNAS
    }
    
    DispatchQueue.global().async {
      database.collection(collection).document(noti.notiId).collection(KEY_COMMENTS).document(commentId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          let comment = try FirestoreDecoder().decode(FirebaseComment.self, from: data)
          self.comment = comment
          
          DispatchQueue.main.async {
            self.loadDone()
          }
        } catch let error {
          DLog(error)
          
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
  
  private func loadLoveUser() {
    guard let noti = self.noti,
          let contributionKind = self.contributionKind,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    let database = Firestore.firestore()
        
    var collection: String = ""
    if contributionKind == .recruit {
      collection = KEY_RECRUITS
    }
    else if contributionKind == .story {
      collection = KEY_STORIES
    } else if contributionKind == .qna {
      collection = KEY_QNAS
    }
    
    DispatchQueue.global().async {
      self.isLoading = true
      self.isLastPage = false
      
      database.collection(collection).document(noti.notiId).collection(KEY_LOVE_IDS).order(by: KEY_DATE, descending: true).limit(to: 20).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          self.isLoading = false
          
          return
        }
        
        guard let snapshot = snapshot,
              let lastUserId = snapshot.documents.last else {
                self.isLoading = false
                activityIndicatorView.stopAnimating()
                return }
        
        self.lastUserId = lastUserId
        
        let group = DispatchGroup()
        var loveUserTemp = [FirebaseUser?]()
        
        for (index, document) in snapshot.documents.enumerated() {
          group.enter()
          loveUserTemp.append(nil)
          
          DispatchQueue(label: "loveUser").async {
            database.collection(KEY_USERS).document(document.documentID).getDocument(completion: { (userSnapshot, userError) in
              if let userError = userError {
                DLog("Error get document: \(userError)")
                self.isLoading = false
                
                return
              }
              
              guard let userSnapshot = userSnapshot, let data = userSnapshot.data() else {
                group.leave()
                return
              }
              
              do {
                let user = try FirestoreDecoder().decode(FirebaseUser.self, from: data)
                loveUserTemp[index] = user
                
                group.leave()
              } catch let error {
                DLog(error)
                
                group.leave()
              }
            })
          }
        }
        
        group.notify(queue: DispatchQueue(label: "loveUser")) {
          DispatchQueue.main.async {
            for loveUser in loveUserTemp {
              if let loveUser = loveUser {
                if !self.isBlockUser(user: loveUser) {
                  self.loveUsers.append(loveUser)
                }
              }
            }
            
            self.loadLoveUserDone()
          }
        }
        
        if snapshot.documents.isEmpty {
          activityIndicatorView.stopAnimating()

          self.isLoading = false
        }
      })
    }
  }
  
  private func loadMoreLoveUser() {
    guard let noti = self.noti,
          let contributionKind = self.contributionKind,
          let lastUserId = self.lastUserId,
          !isLoading,
          !isLastPage else { return }

    let database = Firestore.firestore()

    var collection: String = ""
    if contributionKind == .recruit {
      collection = KEY_RECRUITS
    }
    else if contributionKind == .story {
      collection = KEY_STORIES
    } else if contributionKind == .qna {
      collection = KEY_QNAS
    }

    DispatchQueue.global().async {
      self.isLoading = true

      database.collection(collection).document(noti.notiId).collection(KEY_LOVE_IDS).order(by: KEY_DATE, descending: true).start(afterDocument: lastUserId).limit(to: 20).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          self.isLoading = false

          return
        }

        guard let snapshot = snapshot,
              let lastUserId = snapshot.documents.last else {
                self.isLastPage = true
                self.isLoading = false
                return }

        self.lastUserId = lastUserId
        
        let group = DispatchGroup()
        var loveUserTemp = [FirebaseUser?]()
        
        for (index, document) in snapshot.documents.enumerated() {
          group.enter()
          loveUserTemp.append(nil)
          
          DispatchQueue(label: "loveUser").async {
            database.collection(KEY_USERS).document(document.documentID).getDocument(completion: { (userSnapshot, userError) in
              if let userError = userError {
                DLog("Error get document: \(userError)")
                self.isLoading = false
                
                return
              }
              
              guard let userSnapshot = userSnapshot, let data = userSnapshot.data() else {
                group.leave()
                return
              }
              
              do {
                let user = try FirestoreDecoder().decode(FirebaseUser.self, from: data)
                loveUserTemp[index] = user
                
                group.leave()
              } catch let error {
                DLog(error)
                
                group.leave()
              }
            })
          }
        }
        
        group.notify(queue: DispatchQueue(label: "loveUser")) {
          DispatchQueue.main.async {
            for loveUser in loveUserTemp {
              if let loveUser = loveUser {
                if !self.isBlockUser(user: loveUser) {
                  self.loveUsers.append(loveUser)
                }
              }
            }
            
            self.loadLoveUserDone()
          }
        }

        if snapshot.documents.isEmpty {
          self.isLoading = false
        }
      })
    }
  }
}
