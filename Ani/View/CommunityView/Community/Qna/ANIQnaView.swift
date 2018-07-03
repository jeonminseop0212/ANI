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
import NVActivityIndicatorView

protocol ANIQnaViewDelegate {
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user: FirebaseUser)
  func reject()
}

class ANIQnaView: UIView {
  
  private weak var qnaTableView: UITableView?
  
  private var qnas = [FirebaseQna]()
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
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
  }
  
  @objc private func loadQna(sender: UIRefreshControl?) {
    guard let activityIndicatorView = self.activityIndicatorView else { return }
    
    if !self.qnas.isEmpty {
      self.qnas.removeAll()
    }
    
    if sender == nil {
      activityIndicatorView.startAnimating()
    }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_QNAS).queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snapshot) in
        
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
                
                activityIndicatorView.stopAnimating()

                qnaTableView.reloadData()
                
                UIView.animate(withDuration: 0.2, animations: {
                  qnaTableView.alpha = 1.0
                })
              }
            } catch let error {
              print(error)
              
              activityIndicatorView.stopAnimating()
              
              if let sender = sender {
                sender.endRefreshing()
              }
            }
          }
        }
        
        if let sender = sender, snapshot.value as? [String: AnyObject] == nil {
          activityIndicatorView.stopAnimating()
          sender.endRefreshing()
        }
      })
    }
  }
  
  @objc private func reloadQna() {
    loadQna(sender: nil)
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
      cell.delegate = self
    }
    
    return cell
  }
}

//MARK: UITableViewDelegate
extension ANIQnaView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? ANIQnaViewCell {
      cell.unobserveLove()
    }
  }
}

//MARK: ANIQnaViewCellDelegate
extension ANIQnaView: ANIQnaViewCellDelegate {
  func cellTapped(qna: FirebaseQna, user: FirebaseUser) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: user)
  }
  
  func reject() {
    self.delegate?.reject()
  }
}
