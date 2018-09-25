//
//  CommentView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/21.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

class ANICommentView: UIView {
  
  private weak var commentTableView: UITableView?
  
  var commentMode: CommentMode?
  
  var story: FirebaseStory? {
    didSet {
      loadComment()
    }
  }
  var qna: FirebaseQna? {
    didSet {
      loadComment()
    }
  }
  
  private var comments = [FirebaseComment]()
  
  private var originalScrollY: CGFloat = 0.0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //commentTableView
    let commentTableView = UITableView()
    commentTableView.separatorStyle = .none
    let contentCellId = NSStringFromClass(ANICommentContentCell.self)
    commentTableView.register(ANICommentContentCell.self, forCellReuseIdentifier: contentCellId)
    let commentCellId = NSStringFromClass(ANICommentCell.self)
    commentTableView.register(ANICommentCell.self, forCellReuseIdentifier: commentCellId)
    commentTableView.dataSource = self
    commentTableView.delegate = self
    addSubview(commentTableView)
    commentTableView.edgesToSuperview()
    self.commentTableView = commentTableView
  }
}

//MARK: UITableViewDataSource
extension ANICommentView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let commentMode = self.commentMode else { return UITableViewCell() }

    if indexPath.row == 0 {
      let contentCellId = NSStringFromClass(ANICommentContentCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: contentCellId, for: indexPath) as! ANICommentContentCell
      
      switch commentMode {
      case .story:
          if let story = self.story {
            cell.content = story.story
          }
      case .qna:
        if let qna = self.qna {
          cell.content = qna.qna
        }
      }
      
      return cell
    } else {
      let commentCellId = NSStringFromClass(ANICommentCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! ANICommentCell
      
      switch commentMode {
      case .story:
        cell.comment = comments[indexPath.row - 1]
      case .qna:
        cell.comment = comments[indexPath.row - 1]
      }

      return cell
    }
  }
}

//MAKR: UITableViewDelegate
extension ANICommentView: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let scrollY = scrollView.contentOffset.y
    if (originalScrollY - scrollY) > 50 {
      ANINotificationManager.postViewScrolled()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    originalScrollY = scrollView.contentOffset.y
  }
}

//MARK: data
extension ANICommentView {
  private func loadComment() {
    guard let commentMode = self.commentMode else { return }
    
    let database = Firestore.firestore()
    
    switch commentMode {
    case .story:
      guard let story = self.story,
            let storyId = story.id else { return }
      
      DispatchQueue.global().async {
        database.collection(KEY_STORIES).document(storyId).collection(KEY_COMMENTS).order(by: KEY_DATE, descending: false).addSnapshotListener({ (snapshot, error) in
          if let error = error {
            DLog("Error get document: \(error)")

            return
          }

          guard let snapshot = snapshot else { return }
          
          snapshot.documentChanges.forEach({ (diff) in
            if diff.type == .added {
              do {
                let comment = try FirestoreDecoder().decode(FirebaseComment.self, from: diff.document.data())
                
                self.comments.append(comment)
                DispatchQueue.main.async {
                  guard let commentTableView = self.commentTableView else { return }
                  
                  commentTableView.reloadData()
                }
              } catch let error {
                DLog(error)
              }
            }
          })
        })
      }
    case .qna:
      guard let qna = self.qna,
            let qnaId = qna.id else { return }
      
      DispatchQueue.global().async {
        database.collection(KEY_QNAS).document(qnaId).collection(KEY_COMMENTS).order(by: KEY_DATE, descending: false).addSnapshotListener({ (snapshot, error) in
          if let error = error {
            DLog("Error get document: \(error)")
            
            return
          }
          
          guard let snapshot = snapshot else { return }
          
          snapshot.documentChanges.forEach({ (diff) in
            if diff.type == .added {
              do {
                let comment = try FirestoreDecoder().decode(FirebaseComment.self, from: diff.document.data())
                
                self.comments.append(comment)
                DispatchQueue.main.async {
                  guard let commentTableView = self.commentTableView else { return }
                  
                  commentTableView.reloadData()
                }
              } catch let error {
                DLog(error)
              }
            }
          })
        })
      }
    }
  }
}
