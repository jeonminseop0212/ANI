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
  
  var delegate: ANIQnaViewDelegate?
  
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
    let window = UIApplication.shared.keyWindow
    var bottomSafeArea: CGFloat = 0.0
    if let windowUnrap = window {
      bottomSafeArea = windowUnrap.safeAreaInsets.bottom
    }
    
    //reloadView
    let reloadView = ANIReloadView()
    reloadView.alpha = 0.0
    reloadView.messege = "Q&Aがありません。"
    reloadView.delegate = self
    addSubview(reloadView)
    reloadView.dropShadow()
    reloadView.centerInSuperview()
    reloadView.leftToSuperview(offset: 50.0)
    reloadView.rightToSuperview(offset: 50.0)
    self.reloadView = reloadView
    
    //tableView
    let tableView = UITableView()
    tableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    tableView.backgroundColor = ANIColor.bg
    let id = NSStringFromClass(ANIQnaViewCell.self)
    tableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    tableView.alpha = 0.0
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(loadQna(sender:)), for: .valueChanged)
    tableView.addSubview(refreshControl)
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.qnaTableView = tableView
    
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
    ANINotificationManager.receive(logout: self, selector: #selector(reloadQna))
    ANINotificationManager.receive(login: self, selector: #selector(reloadQna))
    ANINotificationManager.receive(communityTabTapped: self, selector: #selector(scrollToTop))
    ANINotificationManager.receive(deleteQna: self, selector: #selector(deleteQna))
  }
  
  @objc private func reloadQna() {
    loadQna(sender: nil)
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
    
    qnaTableView.deleteRows(at: [indexPath], with: .automatic)
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
      for user in users {
        if qnas[indexPath.row].userId == user.uid {
          cell.user = user
          break
        }
      }
      if users.isEmpty {
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
      database.collection(KEY_QNAS).order(by: KEY_DATE, descending: true).limit(to: 20).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          do {
            let qna = try FirestoreDecoder().decode(FirebaseQna.self.self, from: document.data())
            self.qnas.append(qna)
            
            DispatchQueue.main.async {
              if let sender = sender {
                sender.endRefreshing()
              }
              
              activityIndicatorView.stopAnimating()
              
              qnaTableView.reloadData()
              
              UIView.animate(withDuration: 0.2, animations: {
                qnaTableView.alpha = 1.0
              })
            }
          } catch let error {
            print(error)
            
            activityIndicatorView.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: {
              reloadView.alpha = 1.0
            })
            
            if let sender = sender {
              sender.endRefreshing()
            }
          }
        }
        
        if snapshot.documents.isEmpty {
          if !self.qnas.isEmpty {
            self.qnas.removeAll()
          }
          
          if let sender = sender {
            sender.endRefreshing()
          }
          
          activityIndicatorView.stopAnimating()
          
          qnaTableView.alpha = 0.0
          
          UIView.animate(withDuration: 0.2, animations: {
            reloadView.alpha = 1.0
          })
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
