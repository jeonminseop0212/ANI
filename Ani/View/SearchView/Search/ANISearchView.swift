//
//  UserSearchView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase
import NVActivityIndicatorView

protocol ANISearchViewDelegate {
  func searchViewDidScroll(scrollY: CGFloat)
}

enum SearchCategory: String {
  case user = "ユーザー";
  case story = "ストリー";
  case qna = "質問";
}

class ANISearchView: UIView {
  
  private weak var tableView: UITableView?
  
  private var searchUsers = [FirebaseUser]()
  private var searchStories = [FirebaseStory]()
  private var searchQnas = [FirebaseQna]()
  
  var selectedCategory: SearchCategory = .user {
    didSet {
      guard let tableView = self.tableView else { return }
      
      tableView.alpha = 0.0
      
      switch selectedCategory {
      case .user:
        loadUser()
      case .story:
        loadStory()
      case .qna:
        loadQna()
      }
    }
  }
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var delegate: ANISearchViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    loadUser()
    setupNotifications()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //tableView
    let tableView = UITableView()
    tableView.separatorStyle = .none
    let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT
    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    tableView.backgroundColor = .white
    let userId = NSStringFromClass(ANIUserSearchViewCell.self)
    tableView.register(ANIUserSearchViewCell.self, forCellReuseIdentifier: userId)
    let storyId = NSStringFromClass(ANIStoryViewCell.self)
    tableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyId)
    let supportCellId = NSStringFromClass(ANISupportViewCell.self)
    tableView.register(ANISupportViewCell.self, forCellReuseIdentifier: supportCellId)
    let qnaId = NSStringFromClass(ANIQnaViewCell.self)
    tableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: qnaId)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.alpha = 0.0
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
  
  private func setupNotifications() {
    ANINotificationManager.receive(searchTabTapped: self, selector: #selector(scrollToTop))
  }
  
  @objc private func scrollToTop() {
    guard let userTableView = tableView,
          !searchUsers.isEmpty else { return }
    
    userTableView.scrollToRow(at: [0, 0], at: .top, animated: true)
  }
}

//MARK: UITableViewDataSource
extension ANISearchView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedCategory {
    case .user:
      return searchUsers.count
    case .story:
      return searchStories.count
    case .qna:
      return searchQnas.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch selectedCategory {
    case .user:
      let userId = NSStringFromClass(ANIUserSearchViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: userId, for: indexPath) as! ANIUserSearchViewCell
      
      cell.user = searchUsers[indexPath.row]
      
      return cell
    case .story:
      if !searchStories.isEmpty {
        if searchStories[indexPath.row].recruitId != nil {
          let supportCellId = NSStringFromClass(ANISupportViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
          
          cell.story = searchStories[indexPath.row]
          
          return cell
        } else {
          let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
          
          cell.story = searchStories[indexPath.row]
          
          return cell
        }
      } else {
        return UITableViewCell()
      }
    case .qna:
      let qnaId = NSStringFromClass(ANIQnaViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: qnaId, for: indexPath) as! ANIQnaViewCell
      
      cell.qna = searchQnas[indexPath.row]
      
      return cell
    }
  }
}

//MARK: UITableViewDelegate
extension ANISearchView: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ANINotificationManager.postViewScrolled()
    
    //navigation bar animation
    let scrollY = scrollView.contentOffset.y
    self.delegate?.searchViewDidScroll(scrollY: scrollY)
  }
}

//MARK: data
extension ANISearchView {
  private func loadUser() {
    guard let activityIndicatorView = self.activityIndicatorView,
          let currenUserUid = ANISessionManager.shared.currentUserUid else { return }

    if !searchUsers.isEmpty {
      searchUsers.removeAll()
    }
    
    activityIndicatorView.startAnimating()

    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_USERS).queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snapshot) in
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot, let value = snapshot.value {
            do {
              let user = try FirebaseDecoder().decode(FirebaseUser.self, from: value)
              if user.uid != currenUserUid {
                self.searchUsers.append(user)
              }
              
              DispatchQueue.main.async {
                guard let tableView = self.tableView else { return }
                
                activityIndicatorView.stopAnimating()
                
                tableView.reloadData()
                
                UIView.animate(withDuration: 0.2, animations: {
                  tableView.alpha = 1.0
                })
              }
            } catch let error {
              print(error)
              
              activityIndicatorView.stopAnimating()
            }
          }
        }
        
        if snapshot.value as? [String: AnyObject] == nil {
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
  
  private func loadStory() {
    guard let activityIndicatorView = self.activityIndicatorView else { return }
    
    if !searchStories.isEmpty {
      searchStories.removeAll()
    }
    
    activityIndicatorView.startAnimating()
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_STORIES).queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snapshot) in
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot, let value = snapshot.value {
            do {
              let story = try FirebaseDecoder().decode(FirebaseStory.self, from: value)
              self.searchStories.insert(story, at: 0)
              
              DispatchQueue.main.async {
                
                guard let tableView = self.tableView else { return }
                
                activityIndicatorView.stopAnimating()
                
                tableView.reloadData()
                
                UIView.animate(withDuration: 0.2, animations: {
                  tableView.alpha = 1.0
                })
              }
            } catch let error {
              print(error)
              
              activityIndicatorView.stopAnimating()
            }
          }
        }
        
        if snapshot.value as? [String: AnyObject] == nil {
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
  
  private func loadQna() {
    guard let activityIndicatorView = self.activityIndicatorView else { return }
    
    if !searchQnas.isEmpty {
      searchQnas.removeAll()
    }
    
    activityIndicatorView.startAnimating()
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_QNAS).queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snapshot) in
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot, let value = snapshot.value {
            do {
              let qna = try FirebaseDecoder().decode(FirebaseQna.self, from: value)
              self.searchQnas.insert(qna, at: 0)
              
              DispatchQueue.main.async {
                
                guard let tableView = self.tableView else { return }
                
                activityIndicatorView.stopAnimating()
                
                tableView.reloadData()
                
                UIView.animate(withDuration: 0.2, animations: {
                  tableView.alpha = 1.0
                })
              }
            } catch let error {
              print(error)
              
              activityIndicatorView.stopAnimating()
            }
          }
        }
        
        if snapshot.value as? [String: AnyObject] == nil {
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
}
