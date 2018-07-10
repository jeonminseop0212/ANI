//
//  ANIListView.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/25.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase
import NVActivityIndicatorView

protocol ANIListViewDelegate {
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit, user: FirebaseUser)
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user:FirebaseUser)
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser)
}

class ANIListView: UIView {
  
  private weak var listTableView: UITableView?
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var list: List? {
    didSet {
      guard let list = self.list,
            let activityIndicatorView = self.activityIndicatorView else { return }
      
      activityIndicatorView.startAnimating()
      
      switch list {
      case .loveRecruit:
        loadLoveRecruit()
      case .loveStroy:
        loadLoveStory()
      case .loveQuestion:
        loadLoveQna()
      case .clipRecruit:
        loadClipRecruit()
      }
    }
  }
  
  private var loveRecruits = [FirebaseRecruit]()
  
  private var loveStories = [FirebaseStory]()
  
  private var loveQnas = [FirebaseQna]()
  
  private var clipRecruits = [FirebaseRecruit]()
  
  var delegate: ANIListViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = ANIColor.bg
    
    //listTableView
    let listTableView = UITableView()
    let recruitCellId = NSStringFromClass(ANIRecruitViewCell.self)
    listTableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: recruitCellId)
    let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
    listTableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellId)
    let supportCellId = NSStringFromClass(ANISupportViewCell.self)
    listTableView.register(ANISupportViewCell.self, forCellReuseIdentifier: supportCellId)
    let qnaCellId = NSStringFromClass(ANIQnaViewCell.self)
    listTableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: qnaCellId)
    listTableView.dataSource = self
    listTableView.delegate = self
    listTableView.separatorStyle = .none
    listTableView.backgroundColor = ANIColor.bg
    listTableView.alpha = 0.0
    addSubview(listTableView)
    listTableView.edgesToSuperview()
    self.listTableView = listTableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.green, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
}

//MARK: UITableViewDataSource
extension ANIListView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let list = self.list else { return 0 }
    
    switch list {
    case .loveRecruit:
      return loveRecruits.count
    case .loveStroy:
      return loveStories.count
    case .loveQuestion:
      return loveQnas.count
    case .clipRecruit:
      return clipRecruits.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let list = self.list else { return UITableViewCell() }
    
    switch list {
    case .loveRecruit:
      let recruitCellid = NSStringFromClass(ANIRecruitViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: recruitCellid, for: indexPath) as! ANIRecruitViewCell
      
      cell.recruit = loveRecruits[indexPath.row]
      cell.delegate = self
      
      return cell
    case .loveStroy:
      if !loveStories.isEmpty {
        if loveStories[indexPath.row].recruitId != nil {
          let supportCellId = NSStringFromClass(ANISupportViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
          
          cell.story = loveStories[indexPath.row]
          cell.delegate = self
          
          return cell
        } else {
          let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
          
          cell.story = loveStories[indexPath.row]
          cell.delegate = self
          
          return cell
        }
      } else {
        return UITableViewCell()
      }
    case .loveQuestion:
      let qnaCellid = NSStringFromClass(ANIQnaViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: qnaCellid, for: indexPath) as! ANIQnaViewCell
      
      cell.qna = loveQnas[indexPath.row]
      cell.delegate = self
      
      return cell
    case .clipRecruit:
      let recruitCellid = NSStringFromClass(ANIRecruitViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: recruitCellid, for: indexPath) as! ANIRecruitViewCell
      
      cell.recruit = clipRecruits[indexPath.row]
      cell.delegate = self
      
      return cell
    }
  }
}

//MARK: UITableViewDelegate
extension ANIListView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let list = self.list else { return }
    
    switch list {
    case .loveRecruit:
      if let cell = cell as? ANIRecruitViewCell {
        cell.unobserveLove()
        cell.unobserveSupport()
      }
    case .loveStroy:
      if !loveStories.isEmpty {
        if loveStories[indexPath.row].recruitId != nil, let cell = cell as? ANISupportViewCell {
          cell.unobserveLove()
        } else if let cell = cell as? ANIStoryViewCell {
          cell.unobserveLove()
        }
      }
    case .loveQuestion:
      if let cell = cell as? ANIRecruitViewCell {
        cell.unobserveLove()
      }
    case .clipRecruit:
      if let cell = cell as? ANIRecruitViewCell {
        cell.unobserveLove()
        cell.unobserveSupport()
      }
    }
  }
}

//MARK: ANIRecruitViewCellDelegate
extension ANIListView: ANIRecruitViewCellDelegate {
  func reject() {
    print("reject")
  }
  
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportButtonTapped(supportRecruit: supportRecruit, user: user)
  }
  
  func cellTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.recruitViewCellDidSelect(selectedRecruit: recruit, user: user)
  }
}

//MARK: ANIStoryViewCellDelegate
extension ANIListView: ANIStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
}

//MARK: ANISupportViewCellDelegate
extension ANIListView: ANISupportViewCellDelegate {
  func supportCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportCellRecruitTapped(recruit: recruit, user: user)
  }
}

//MARK: ANIQnaViewCellDelegate
extension ANIListView: ANIQnaViewCellDelegate {
  func cellTapped(qna: FirebaseQna, user: FirebaseUser) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: user)
  }
}

//MARK: data
extension ANIListView {
  private func loadLoveRecruit() {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let uid = currentUser.uid else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_LOVE_RECRUIT_IDS).child(uid).queryOrderedByValue().queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot {
            databaseRef.child(KEY_RECRUITS).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
              
              guard let value = snapshot.value else { return }
              do {
                let recruit = try FirebaseDecoder().decode(FirebaseRecruit.self, from: value)
                self.loveRecruits.insert(recruit, at: 0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                  guard let listTableView = self.listTableView,
                        let activityIndicatorView = self.activityIndicatorView else { return }
                  
                  listTableView.reloadData()
                  activityIndicatorView.stopAnimating()
                  
                  UIView.animate(withDuration: 0.2, animations: {
                    listTableView.alpha = 1.0
                  })
                })
              } catch let error {
                guard let activityIndicatorView = self.activityIndicatorView else { return }
                
                print(error)
                activityIndicatorView.stopAnimating()
              }
            })
          }
        }
        
        if snapshot.value as? [String: Any] == nil {
          guard let activityIndicatorView = self.activityIndicatorView else { return }
          
          activityIndicatorView.stopAnimating()
        }
      }
    }
  }
  
  private func loadLoveStory() {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let uid = currentUser.uid else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_LOVE_STORY_IDS).child(uid).queryOrderedByValue().queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot {
            databaseRef.child(KEY_STORIES).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
              
              guard let value = snapshot.value else { return }
              do {
                let story = try FirebaseDecoder().decode(FirebaseStory.self, from: value)
                self.loveStories.insert(story, at: 0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                  guard let listTableView = self.listTableView,
                    let activityIndicatorView = self.activityIndicatorView else { return }
                  
                  listTableView.reloadData()
                  activityIndicatorView.stopAnimating()
                  
                  UIView.animate(withDuration: 0.2, animations: {
                    listTableView.alpha = 1.0
                  })
                })
              } catch let error {
                guard let activityIndicatorView = self.activityIndicatorView else { return }

                print(error)
                activityIndicatorView.stopAnimating()
              }
            })
          }
        }
        
        if snapshot.value as? [String: Any] == nil {
          guard let activityIndicatorView = self.activityIndicatorView else { return }
          
          activityIndicatorView.stopAnimating()
        }
      }
    }
  }
  
  private func loadLoveQna() {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let uid = currentUser.uid else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_LOVE_QNA_IDS).child(uid).queryOrderedByValue().queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot {
            databaseRef.child(KEY_QNAS).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
              
              guard let value = snapshot.value else { return }
              do {
                let qna = try FirebaseDecoder().decode(FirebaseQna.self, from: value)
                self.loveQnas.insert(qna, at: 0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                  guard let listTableView = self.listTableView,
                    let activityIndicatorView = self.activityIndicatorView else { return }
                  
                  listTableView.reloadData()
                  activityIndicatorView.stopAnimating()
                  
                  UIView.animate(withDuration: 0.2, animations: {
                    listTableView.alpha = 1.0
                  })
                })
              } catch let error {
                guard let activityIndicatorView = self.activityIndicatorView else { return }

                print(error)
                activityIndicatorView.stopAnimating()
              }
            })
          }
        }
        
        if snapshot.value as? [String: Any] == nil {
          guard let activityIndicatorView = self.activityIndicatorView else { return }
          
          activityIndicatorView.stopAnimating()
        }
      }
    }
  }
  
  private func loadClipRecruit() {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let uid = currentUser.uid else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_CLIP_RECRUIT_IDS).child(uid).queryOrderedByValue().queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot {
            databaseRef.child(KEY_RECRUITS).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
              
              guard let value = snapshot.value else { return }
              do {
                let recruit = try FirebaseDecoder().decode(FirebaseRecruit.self, from: value)
                self.clipRecruits.insert(recruit, at: 0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                  guard let listTableView = self.listTableView,
                    let activityIndicatorView = self.activityIndicatorView else { return }
                  
                  listTableView.reloadData()
                  activityIndicatorView.stopAnimating()
                  
                  UIView.animate(withDuration: 0.2, animations: {
                    listTableView.alpha = 1.0
                  })
                })
              } catch let error {
                guard let activityIndicatorView = self.activityIndicatorView else { return }
                
                print(error)
                activityIndicatorView.stopAnimating()
              }
            })
          }
        }
        
        if snapshot.value as? [String: Any] == nil {
          guard let activityIndicatorView = self.activityIndicatorView else { return }
          
          activityIndicatorView.stopAnimating()
        }
      }
    }
  }
}
