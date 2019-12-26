//
//  ANIQnaDetailView.swift
//  Ani
//
//  Created by jeonminseop on 2019/12/26.
//  Copyright © 2019 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

protocol ANIQnaDetailViewDelegate {
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user: FirebaseUser)
  func popupOptionView(isMe: Bool, id: String)
}

class ANIQnaDetailView: UIView {
  
  private weak var tableView: UITableView?
  private weak var alertLabel: UILabel?
  
  var qnaId: String? {
    didSet {
      guard let qnaId = self.qnaId,
            let tableView = self.tableView else { return }
      
      tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

      loadStory(storyId: qnaId)
    }
  }
  
  private var qna: FirebaseQna?
  private var user: FirebaseUser?
  
  private var isLoading: Bool = false
      
  private weak var activityIndicatorView: ANIActivityIndicator?
  
  var delegate: ANIQnaDetailViewDelegate?
  
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
    let storyCellId = NSStringFromClass(ANIQnaViewCell.self)
    tableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: storyCellId)
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
extension ANIQnaDetailView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let qna = self.qna else { return UITableViewCell() }

    let qnaCellId = NSStringFromClass(ANIQnaViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: qnaCellId, for: indexPath) as! ANIQnaViewCell
    cell.delegate = self

    if let user = self.user {
      cell.user = user
    }
    cell.indexPath = indexPath.row
    cell.qna = qna

    return cell
  }
}

//MARK: UITableViewDelegate
extension ANIQnaDetailView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? ANIQnaViewCell {
      cell.unobserveLove()
      cell.unobserveComment()
    }
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

//MARK: ANIQnaViewCellDelegate
extension ANIQnaDetailView: ANIQnaViewCellDelegate {
  func reject() {
  }
  
  func cellTapped(qna: FirebaseQna, user: FirebaseUser) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: user)
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, id: id)
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
extension ANIQnaDetailView {
  private func loadStory(storyId: String) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let qnaId = self.qnaId else { return }

    let database = Firestore.firestore()
    
    activityIndicatorView.startAnimating()

    DispatchQueue.global().async {
      database.collection(KEY_QNAS).document(qnaId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        if let snapshot = snapshot, let data = snapshot.data() {
          do {
            let qna = try FirestoreDecoder().decode(FirebaseQna.self, from: data)
            
            self.qna = qna
            
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
