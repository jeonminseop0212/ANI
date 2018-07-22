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
}

enum NotiKind {
  case recruit;
  case story;
  case qna;
}

class ANINotiDetailView: UIView {
  
  private weak var tableView: UITableView?
  
  var notiKind: NotiKind?
  var noti: FirebaseNotification? {
    didSet {
      guard let noti = self.noti,
            let notiKind = self.notiKind else { return }
      
      switch notiKind {
      case .recruit:
        loadRecruit(notiId: noti.notiId)
      case .story:
        loadStory(notiId: noti.notiId)
        
        if let commentId = noti.commentId {
          loadComment(commentId: commentId, notiKind: .story)
        }
      case .qna:
        loadQna(notiId: noti.notiId)
        
        if let commentId = noti.commentId {
          loadComment(commentId: commentId, notiKind: .qna)
        }
      }
    }
  }
  
  private var recruit: FirebaseRecruit?
  private var story: FirebaseStory?
  private var qna: FirebaseQna?
  private var comment: FirebaseComment?
  
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
    let commentCellId = NSStringFromClass(ANINotiCommentViewCell.self)
    tableView.register(ANINotiCommentViewCell.self, forCellReuseIdentifier: commentCellId)
    tableView.alpha = 0.0
    tableView.dataSource = self
    tableView.delegate = self
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.tableView = tableView
    
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
    guard let notiKind = self.notiKind,
          let noti = self.noti else { return 0 }
    
    switch notiKind {
    case .recruit:
      return 1
    case .story:
      if noti.commentId != nil {
        return 2
      } else {
        return 1
      }
    case .qna:
      if noti.commentId != nil {
        return 2
      } else {
        return 1
      }
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let notiKind = self.notiKind else { return UITableViewCell() }
    
    switch notiKind {
    case .recruit:
      let recruitCellId = NSStringFromClass(ANIRecruitViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: recruitCellId, for: indexPath) as! ANIRecruitViewCell
      
      cell.recruit = recruit
      cell.delegate = self
      
      return cell
    case .story:
      if story?.recruitId != nil {
        if indexPath.row == 0 {
          let supportCellId = NSStringFromClass(ANISupportViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
          
          cell.story = story
          cell.delegate = self
          
          return cell
        } else {
          let commentCellId = NSStringFromClass(ANINotiCommentViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! ANINotiCommentViewCell

          cell.comment = comment
          cell.notiKind = .story
          
          return cell
        }
      } else {
        if indexPath.row == 0 {
          let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
          
          cell.story = story
          cell.delegate = self
          
          return cell
        } else {
          let commentCellId = NSStringFromClass(ANINotiCommentViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! ANINotiCommentViewCell

          cell.comment = comment
          cell.notiKind = .story

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
      } else {
        let commentCellId = NSStringFromClass(ANINotiCommentViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! ANINotiCommentViewCell
        
        cell.comment = comment
        cell.notiKind = .qna

        return cell
      }
    }
  }
}

//MARK: UITableViewDelegate
extension ANINotiDetailView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 1  {
      guard let notiKind = self.notiKind,
            let currentUser = ANISessionManager.shared.currentUser else { return }
      
      if notiKind == .story {
        guard let story = self.story else { return }
        
        self.delegate?.storyViewCellDidSelect(selectedStory: story, user: currentUser)
      } else if notiKind == .qna {
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
}

//MARK: ANISupportViewCellDelegate
extension ANINotiDetailView: ANISupportViewCellDelegate {
  func supportCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportCellRecruitTapped(recruit: recruit, user: user)
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
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          let recruit = try FirestoreDecoder().decode(FirebaseRecruit.self, from: data)
          self.recruit = recruit
          
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
  
  private func loadStory(notiId: String) {
    guard let activityIndicatorView = self.activityIndicatorView else { return }

    let database = Firestore.firestore()
    
    activityIndicatorView.startAnimating()

    DispatchQueue.global().async {
      database.collection(KEY_STORIES).document(notiId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          let story = try FirestoreDecoder().decode(FirebaseStory.self, from: data)
          self.story = story
          
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
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          let qna = try FirestoreDecoder().decode(FirebaseQna.self, from: data)
          self.qna = qna
          
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
  
  private func loadComment(commentId: String, notiKind: NotiKind) {
    guard let noti = self.noti,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    let database = Firestore.firestore()
    
    activityIndicatorView.startAnimating()
    
    var collection: String = ""
    if notiKind == .story {
      collection = KEY_STORIES
    } else if notiKind == .qna {
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
}
