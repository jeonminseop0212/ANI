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

protocol ANIQnaViewDelegate {
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user: FirebaseUser)
  func reject()
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String)
}

class ANIQnaView: UIView {
  
  private weak var reloadView: ANIReloadView?
  
  private weak var qnaTableView: UITableView?
  
  private var qnas = [FirebaseQna]()
  private var users = [FirebaseUser]()
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var isCellSelected: Bool = false
  
  private var lastQna: QueryDocumentSnapshot?
  private var isLastQnaPage: Bool = false
  private var isLoading: Bool = false
  private let COUNT_LAST_CELL: Int = 4
  
  var delegate: ANIQnaViewDelegate?
  
  private var cellHeight = [IndexPath: CGFloat]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    loadQna(sender: nil)
    setupNotifications()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = ANIColor.bg
    
    //reloadView
    let reloadView = ANIReloadView()
    reloadView.alpha = 0.0
    reloadView.messege = "Q&Aがありません。"
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
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
    tableView.backgroundColor = ANIColor.bg
    let id = NSStringFromClass(ANIQnaViewCell.self)
    tableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    tableView.alpha = 0.0
    tableView.rowHeight = UITableView.automaticDimension
    let refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = .clear
    refreshControl.tintColor = ANIColor.moreDarkGray
    refreshControl.addTarget(self, action: #selector(loadQna(sender:)), for: .valueChanged)
    tableView.addSubview(refreshControl)
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.qnaTableView = tableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.emerald, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  //MARK: Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(logout: self, selector: #selector(reloadQnaLayout))
    ANINotificationManager.receive(login: self, selector: #selector(reloadQnaLayout))
    ANINotificationManager.receive(communityTabTapped: self, selector: #selector(scrollToTop))
    ANINotificationManager.receive(deleteQna: self, selector: #selector(deleteQna))
  }
  
  @objc private func reloadQnaLayout() {
    guard let qnaTableView = self.qnaTableView else { return }
    
    for (index, qna) in qnas.enumerated() {
      var qnaTemp = qna
      qnaTemp.isLoved = nil
      self.qnas[index] = qnaTemp
    }
    
    qnaTableView.reloadData()
  }
  
  @objc private func scrollToTop() {
    guard let qnaTableView = qnaTableView,
          !qnas.isEmpty,
          isCellSelected else { return }
    
    qnaTableView.scrollToRow(at: [0, 0], at: .top, animated: true)
  }
  
  @objc private func deleteQna(_ notification: NSNotification) {
    guard let id = notification.object as? String,
          let qnaTableView = self.qnaTableView else { return }
    
    var indexPath: IndexPath = [0, 0]
    
    for (index, qna) in qnas.enumerated() {
      if qna.id == id {
        qnas.remove(at: index)
        indexPath = [0, index]
      }
    }
    
    if qnas.isEmpty {
      qnaTableView.reloadData()
      qnaTableView.alpha = 0.0
      showReloadView(sender: nil)
    } else {
      qnaTableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
  private func showReloadView(sender: UIRefreshControl?) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let reloadView = self.reloadView,
          let qnaTableView = self.qnaTableView else { return }
    
    activityIndicatorView.stopAnimating()
    
    qnaTableView.reloadData()
    
    if let sender = sender {
      sender.endRefreshing()
    }
    
    qnaTableView.alpha = 0.0
    
    UIView.animate(withDuration: 0.2, animations: {
      reloadView.alpha = 1.0
    })
    
    self.isLoading = false
  }
  
  private func isBlockQna(qna: FirebaseQna) -> Bool {
    guard let currentUserUid = ANISessionManager.shared.currentUserUid else { return false }

    if let blockUserIds = ANISessionManager.shared.blockUserIds, blockUserIds.contains(qna.userId) {
      return true
    }
    if let blockingUserIds = ANISessionManager.shared.blockingUserIds, blockingUserIds.contains(qna.userId) {
      return true
    }
    if let hideUserIds = qna.hideUserIds, hideUserIds.contains(currentUserUid) {
      return true
    }
    
    return false
  }
}

//MARK: UITableViewDataSource
extension ANIQnaView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return qnas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIQnaViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIQnaViewCell

    if !qnas.isEmpty {
      if users.contains(where: { $0.uid == qnas[indexPath.row].userId }) {
        for user in users {
          if qnas[indexPath.row].userId == user.uid {
            cell.user = user
            break
          }
        }
      } else {
        cell.user = nil
      }
      cell.qna = qnas[indexPath.row]
      cell.delegate = self
      cell.indexPath = indexPath.row
    }
    
    return cell
  }
}

//MARK: UITableViewDelegate
extension ANIQnaView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? ANIQnaViewCell {
      cell.unobserveLove()
      cell.unobserveComment()
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let element = self.qnas.count - COUNT_LAST_CELL
    if !isLoading, indexPath.row >= element {
      loadMoreQna()
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

//MARK: ANIQnaViewCellDelegate
extension ANIQnaView: ANIQnaViewCellDelegate {
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, contentType: contentType, id: id)
  }
  
  func cellTapped(qna: FirebaseQna, user: FirebaseUser) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: user)
  }
  
  func reject() {
    self.delegate?.reject()
  }
  
  func loadedQnaIsLoved(indexPath: Int, isLoved: Bool) {
    var qna = self.qnas[indexPath]
    qna.isLoved = isLoved
    self.qnas[indexPath] = qna
  }
  
  func loadedQnaUser(user: FirebaseUser) {
    self.users.append(user)
  }
}

//MARK: data
extension ANIQnaView {
  @objc private func loadQna(sender: UIRefreshControl?) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let reloadView = self.reloadView,
          let qnaTableView = self.qnaTableView else { return }
    
    reloadView.alpha = 0.0
    
    if !self.qnas.isEmpty {
      self.qnas.removeAll()
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
      self.isLastQnaPage = false

      database.collection(KEY_QNAS).order(by: KEY_DATE, descending: true).limit(to: 25).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          self.isLoading = false
          
          return
        }
        
        guard let snapshot = snapshot,
              let lastQna = snapshot.documents.last else {
                if !self.qnas.isEmpty {
                  self.qnas.removeAll()
                }
                
                self.isLoading = false
                
                self.showReloadView(sender: sender)
                return }
        
        self.lastQna = lastQna
        
        for (index, document) in snapshot.documents.enumerated() {
          do {
            let qna = try FirestoreDecoder().decode(FirebaseQna.self, from: document.data())
            if !self.isBlockQna(qna: qna) {
              self.qnas.append(qna)
            }
            
            DispatchQueue.main.async {
              if index + 1 == snapshot.documents.count {
                if let sender = sender {
                  sender.endRefreshing()
                }
                
                qnaTableView.reloadData()
                
                self.isLoading = false
                
                if self.qnas.isEmpty {
                  self.loadMoreQna()
                } else {
                  activityIndicatorView.stopAnimating()
                  
                  UIView.animate(withDuration: 0.2, animations: {
                    qnaTableView.alpha = 1.0
                  })
                }
              }
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
      })
    }
  }
  
  private func loadMoreQna() {
    guard let qnaTableView = self.qnaTableView,
          let lastQna = self.lastQna,
          let activityIndicatorView = self.activityIndicatorView,
          !isLoading,
          !isLastQnaPage else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      self.isLoading = true
      
      database.collection(KEY_QNAS).order(by: KEY_DATE, descending: true).start(afterDocument: lastQna).limit(to: 25).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          self.isLoading = false
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        guard let lastQna = snapshot.documents.last else {
          self.isLastQnaPage = true
          self.isLoading = false
          return
        }
        
        self.lastQna = lastQna
        
        for (index, document) in snapshot.documents.enumerated() {
          do {
            let qna = try FirestoreDecoder().decode(FirebaseQna.self, from: document.data())
            if !self.isBlockQna(qna: qna) {
              self.qnas.append(qna)
            }
            
            DispatchQueue.main.async {
              if index + 1 == snapshot.documents.count {
                qnaTableView.reloadData()
                
                self.isLoading = false
                
                if self.qnas.isEmpty {
                  self.loadMoreQna()
                } else {
                  if qnaTableView.alpha == 0.0 {
                    activityIndicatorView.stopAnimating()
                    
                    UIView.animate(withDuration: 0.2, animations: {
                      qnaTableView.alpha = 1.0
                    })
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
extension ANIQnaView: ANIReloadViewDelegate {
  func reloadButtonTapped() {
    loadQna(sender: nil)
  }
}
