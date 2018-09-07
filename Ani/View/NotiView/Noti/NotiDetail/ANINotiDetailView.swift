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
import NVActivityIndicatorView

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
            let notiKind = self.notiKind else { return }
      
      switch contributionKind {
      case .recruit:
        loadRecruit(notiId: noti.notiId)
      case .story:
        loadStory(notiId: noti.notiId)
        
        if notiKind == .comment, let commentId = noti.commentId {
            loadComment(commentId: commentId, contributionKind: .story)
        } else if notiKind == .love {
          loadLoveUserId()
        }
      case .qna:
        loadQna(notiId: noti.notiId)
        
        if notiKind == .comment, let commentId = noti.commentId {
          loadComment(commentId: commentId, contributionKind: .qna)
        } else if notiKind == .love {
          loadLoveUserId()
        }
      }
    }
  }
  
  private var recruit: FirebaseRecruit?
  private var story: FirebaseStory?
  private var qna: FirebaseQna?
  private var comment: FirebaseComment?
  private var loveUsers: [FirebaseUser]?
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
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
    alertLabel.rightToSuperview(offset: 10.0)
    self.alertLabel = alertLabel
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.green, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  private func loadDone() {
    guard let tableView = self.tableView,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    activityIndicatorView.stopAnimating()
    
    tableView.reloadData()
    
    UIView.animate(withDuration: 0.2, animations: {
      tableView.alpha = 1.0
    })
  }
}

//MARK: UITableViewDataSource
extension ANINotiDetailView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let contributionKind = self.contributionKind,
          let notiKind = self.notiKind else { return 0 }

    switch contributionKind {
    case .recruit:
      if let loveUsers = self.loveUsers {
        return 2 + loveUsers.count
      }
      return 1
    case .story:
      if notiKind == .comment {
        return 3
      } else if notiKind == .love, let loveUsers = self.loveUsers {
        return 2 + loveUsers.count
      } else {
        return 1
      }
    case .qna:
      if notiKind == .comment {
        return 3
      } else if notiKind == .love, let loveUsers = self.loveUsers {
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
        
        cell.recruit = recruit
        cell.delegate = self
        
        return cell
      } else if indexPath.row == 1 {
        let headerCellId = NSStringFromClass(ANINotiHeaderViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! ANINotiHeaderViewCell
        
        cell.contributionKind = contributionKind
        cell.headerText = "いいねユーザー"
        
        return cell
      } else {
        let userCellId = NSStringFromClass(ANIUserSearchViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! ANIUserSearchViewCell
        
        if let loveUsers = loveUsers {
          cell.user = loveUsers[indexPath.row - 2]
        }
        
        return cell
      }
    case .story:
      if story?.recruitId != nil {
        if indexPath.row == 0 {
          let supportCellId = NSStringFromClass(ANISupportViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
          
          cell.story = story
          cell.delegate = self
          
          return cell
        } else if indexPath.row == 1 {
          let headerCellId = NSStringFromClass(ANINotiHeaderViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! ANINotiHeaderViewCell
          
          cell.contributionKind = contributionKind
          
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
          
          if let loveUsers = loveUsers {
            cell.user = loveUsers[indexPath.row - 2]
          }
          
          return cell
        }
      } else {
        if indexPath.row == 0 {
          let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
          
          cell.story = story
          cell.delegate = self
          
          return cell
        } else if indexPath.row == 1 {
          let headerCellId = NSStringFromClass(ANINotiHeaderViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! ANINotiHeaderViewCell
          
          cell.contributionKind = contributionKind
          
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
          
          if let loveUsers = loveUsers {
            cell.user = loveUsers[indexPath.row - 2]
          }
          
          return cell
        }
      }
    case .qna:
      if indexPath.row == 0 {
        let qnaCellId = NSStringFromClass(ANIQnaViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: qnaCellId, for: indexPath) as! ANIQnaViewCell
        
        cell.qna = qna
        cell.delegate = self
        
        return cell
      } else if indexPath.row == 1 {
        let headerCellId = NSStringFromClass(ANINotiHeaderViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! ANINotiHeaderViewCell
        
        cell.contributionKind = contributionKind

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
        
        if let loveUsers = loveUsers {
          cell.user = loveUsers[indexPath.row - 2]
        }
        
        return cell
      }
    }
  }
}

//MARK: UITableViewDelegate
extension ANINotiDetailView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 1  {
      guard let contributionKind = self.contributionKind,
            let currentUser = ANISessionManager.shared.currentUser else { return }
      
      if contributionKind == .story {
        guard let story = self.story else { return }
        
        self.delegate?.storyViewCellDidSelect(selectedStory: story, user: currentUser)
      } else if contributionKind == .qna {
        guard let qna = self.qna else { return }

        self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: currentUser)
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
}

//MARK: ANIStoryViewCellDelegate
extension ANINotiDetailView: ANIStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, contentType: contentType, id: id)
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
  
  func loadedRecruit(recruit: FirebaseRecruit) {
  }
}

//MARK: ANIQnaViewCellDelegate
extension ANINotiDetailView: ANIQnaViewCellDelegate {
  func cellTapped(qna: FirebaseQna, user: FirebaseUser) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: user)
  }
}

//MARK: data
extension ANINotiDetailView {
  private func loadRecruit(notiId: String) {
    guard let activityIndicatorView = self.activityIndicatorView else { return }
    
    let database = Firestore.firestore()
    
    activityIndicatorView.startAnimating()
    
    DispatchQueue.global().async {
      database.collection(KEY_RECRUITS).document(notiId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        if let snapshot = snapshot, let data = snapshot.data() {
          do {
            let recruit = try FirestoreDecoder().decode(FirebaseRecruit.self, from: data)
            self.recruit = recruit
          } catch let error {
            print(error)
            
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
          print("Error get document: \(error)")
          
          return
        }
        
        if let snapshot = snapshot, let data = snapshot.data() {
          do {
            let story = try FirestoreDecoder().decode(FirebaseStory.self, from: data)
            self.story = story
            
            if notiKind == .support {
              DispatchQueue.main.async {
                self.loadDone()
              }
            }
          } catch let error {
            print(error)
            
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
    guard let activityIndicatorView = self.activityIndicatorView else { return }

    let database = Firestore.firestore()
    
    activityIndicatorView.startAnimating()
    
    DispatchQueue.global().async {
      database.collection(KEY_QNAS).document(notiId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        if let snapshot = snapshot, let data = snapshot.data() {
          do {
            let qna = try FirestoreDecoder().decode(FirebaseQna.self, from: data)
            self.qna = qna
          } catch let error {
            print(error)
            
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
          print("Error get document: \(error)")
          
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
          print(error)
          
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
  
  private func loadLoveUserId() {
    guard let noti = self.noti,
          let contributionKind = self.contributionKind else { return }
    
    let database = Firestore.firestore()
    
    var collection: String = ""
    if contributionKind == .story {
      collection = KEY_STORIES
    } else if contributionKind == .qna {
      collection = KEY_QNAS
    }
    
    var loveUserId = [String]()
    DispatchQueue.global().async {
      
      database.collection(collection).document(noti.notiId).collection(KEY_LOVE_IDS).limit(to: 20).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          for key in document.data().keys {
            loveUserId.append(key)
            
            if loveUserId.count == snapshot.documents.count {
              self.loadLoveUser(userIds: loveUserId)
            }
          }
        }
      })
    }
  }
  
  private func loadLoveUser(userIds: [String]) {
    guard let activityIndicatorView = self.activityIndicatorView else { return }

    let database = Firestore.firestore()

    for userId in userIds {
      DispatchQueue.global().async {
        database.collection(KEY_USERS).document(userId).getDocument(completion: { (snapshot, error) in
          guard let snapshot = snapshot, let data = snapshot.data() else { return }
          
          do {
            let user = try FirestoreDecoder().decode(FirebaseUser.self, from: data)
            if self.loveUsers != nil {
              self.loveUsers?.append(user)
            } else {
              self.loveUsers = [user]
            }
            
            if self.loveUsers?.count == userIds.count {
              DispatchQueue.main.async {
                self.loadDone()
              }
            }
          } catch let error {
            print(error)
            
            activityIndicatorView.stopAnimating()
          }
        })
      }
    }
  }
}
