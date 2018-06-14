//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

protocol ANIQnaViewDelegate {
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user: FirebaseUser)
}

class ANIQnaView: UIView {
  
  var qnaTableView: UITableView?
  
  var qnas = [FirebaseQna]()
  
  var delegate: ANIQnaViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadQna(sender: nil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let window = UIApplication.shared.keyWindow
    var bottomSafeArea: CGFloat = 0.0
    if let windowUnrap = window {
      bottomSafeArea = windowUnrap.safeAreaInsets.bottom
    }
    let tableView = UITableView()
    tableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    tableView.backgroundColor = ANIColor.bg
    let id = NSStringFromClass(ANIQnaViewCell.self)
    tableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.separatorStyle = .none
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(loadQna(sender:)), for: .valueChanged)
    tableView.addSubview(refreshControl)
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.qnaTableView = tableView
  }
  
  @objc private func loadQna(sender: UIRefreshControl?) {
    if !self.qnas.isEmpty {
      self.qnas.removeAll()
    }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_QNAS).queryLimited(toFirst: 20).observe(.value, with: { (snapshot) in
        databaseRef.child(KEY_QNAS).removeAllObservers()
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot, let value = snapshot.value {
            do {
              let qna = try FirebaseDecoder().decode(FirebaseQna.self, from: value)
              self.qnas.insert(qna, at: 0)
              
              DispatchQueue.main.async {
                if let sender = sender {
                  sender.endRefreshing()
                }
                
                guard let qnaTableView = self.qnaTableView else { return }
                qnaTableView.reloadData()
              }
            } catch let error {
              print(error)
              
              if let sender = sender {
                sender.endRefreshing()
              }
            }
          }
        }
        
        if let sender = sender, snapshot.value as? [String: AnyObject] == nil {
          sender.endRefreshing()
        }
      })
    }
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
      cell.qna = qnas[indexPath.row]
      cell.observeQna()
      cell.delegate = self
    }
    
    return cell
  }
}

//MARK: ANIQnaViewCellDelegate
extension ANIQnaView: ANIQnaViewCellDelegate {
  func cellTapped(qna: FirebaseQna, user: FirebaseUser) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: user)
  }
}
