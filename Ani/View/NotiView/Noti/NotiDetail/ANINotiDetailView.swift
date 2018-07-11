//
//  ANINotiDetailView.swift
//  Ani
//
//  Created by jeonminseop on 2018/07/09.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

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
      case .qna:
        loadQna(notiId: noti.notiId)
      }
      
      if let commentId = noti.commentId {
        loadComment(commentId: commentId)
      }
    }
  }
  
  private var recruit: FirebaseRecruit?
  private var story: FirebaseStory?
  private var qna: FirebaseQna?
  private var comment: FirebaseComment?
  
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
    tableView.dataSource = self
    tableView.delegate = self
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.tableView = tableView
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
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      databaseRef.child(KEY_RECRUITS).child(notiId).observeSingleEvent(of: .value, with: { (snapshot) in
        
        guard let value = snapshot.value else { return }
        do {
          let recruit = try FirebaseDecoder().decode(FirebaseRecruit.self, from: value)
          self.recruit = recruit
          
          DispatchQueue.main.async {
            guard let tableView = self.tableView else { return }
            
            tableView.reloadData()
          }
        } catch let error {
          print(error)
        }
      })
    }
  }
  
  private func loadStory(notiId: String) {
    let databaseRef = Database.database().reference()

    DispatchQueue.global().async {
      databaseRef.child(KEY_STORIES).child(notiId).observeSingleEvent(of: .value, with: { (snapshot) in
        
        guard let value = snapshot.value else { return }
        do {
          let story = try FirebaseDecoder().decode(FirebaseStory.self, from: value)
          self.story = story
          
          DispatchQueue.main.async {
            guard let tableView = self.tableView else { return }
            tableView.reloadData()
          }
        } catch let error {
          print(error)
        }
      })
    }
  }
  
  private func loadQna(notiId: String) {
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      databaseRef.child(KEY_QNAS).child(notiId).observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
          let qna = try FirebaseDecoder().decode(FirebaseQna.self, from: value)
          self.qna = qna
          
          DispatchQueue.main.async {
            guard let tableView = self.tableView else { return }
            tableView.reloadData()
          }
        } catch let error {
          print(error)
        }
      })
    }
  }
  
  private func loadComment(commentId: String) {
    guard let noti = self.noti else { return }
    
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      databaseRef.child(KEY_COMMENTS).child(noti.notiId).child(commentId).observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
          let comment = try FirebaseDecoder().decode(FirebaseComment.self, from: value)
          self.comment = comment
          
          DispatchQueue.main.async {
            guard let tableView = self.tableView else { return }
            tableView.reloadData()
          }
        } catch let error {
          print(error)
        }
      })
    }
  }
}