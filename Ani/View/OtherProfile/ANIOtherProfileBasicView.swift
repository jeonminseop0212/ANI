//
//  ANIOtherProfileBasicView.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/12.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase
import NVActivityIndicatorView

protocol ANIOtherProfileBasicViewDelegate {
  func followingTapped()
  func followerTapped()
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit, user: FirebaseUser)
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user:FirebaseUser)
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser)
  func reject()
}

class ANIOtherProfileBasicView: UIView {
  
  enum SectionType:Int { case top = 0; case content = 1 }
  enum ContentType:Int { case profile; case recruit; case story; case qna;}
  
  private var contentType:ContentType = .profile {
    didSet {
      self.basicTableView?.reloadData()
      self.layoutIfNeeded()
    }
  }
  
  private weak var basicTableView: UITableView?
  
  private var recruits = [FirebaseRecruit]()
  
  private var stories = [FirebaseStory]()
  
  private var qnas = [FirebaseQna]()
  
  private var isFollowed: Bool?
  
  private var user: FirebaseUser? {
    didSet {
      checkFollowed()
      loadRecruit()
      loadStory()
      loadQna()
      
      guard let basicTableView = self.basicTableView else { return }
      basicTableView.reloadData()
    }
  }
  
  var userId: String? {
    didSet {
      loadUser()
    }
  }
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var delegate: ANIOtherProfileBasicViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let basicTableView = UITableView()
    basicTableView.backgroundColor = ANIColor.bg
    basicTableView.separatorStyle = .none
    basicTableView.dataSource = self
    basicTableView.delegate = self
    let topCellId = NSStringFromClass(ANIOtherProfileTopCell.self)
    basicTableView.register(ANIOtherProfileTopCell.self, forCellReuseIdentifier: topCellId)
    let profileCellid = NSStringFromClass(ANIOtherProfileCell.self)
    basicTableView.register(ANIOtherProfileCell.self, forCellReuseIdentifier: profileCellid)
    let recruitCellid = NSStringFromClass(ANIRecruitViewCell.self)
    basicTableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: recruitCellid)
    let storyCellid = NSStringFromClass(ANIStoryViewCell.self)
    basicTableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellid)
    let supportCellId = NSStringFromClass(ANISupportViewCell.self)
    basicTableView.register(ANISupportViewCell.self, forCellReuseIdentifier: supportCellId)
    let qnaCellid = NSStringFromClass(ANIQnaViewCell.self)
    basicTableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: qnaCellid)
    basicTableView.alpha = 0.0
    addSubview(basicTableView)
    basicTableView.edgesToSuperview()
    self.basicTableView = basicTableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.green, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
  }
  
  private func checkFollowed() {
    guard let user = self.user,
          let userId = user.uid,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    if let currentUserId = ANISessionManager.shared.currentUserUid {
      let databaseRef = Database.database().reference()
      
      DispatchQueue.global().async {
        databaseRef.child(KEY_FOLLOWING_USER_IDS).child(currentUserId).observeSingleEvent(of: .value) { (snapshot) in
          guard let followingUser = snapshot.value as? [String: String] else { return }
          
          for id in followingUser.keys {
            if id == userId {
              
              self.isFollowed = true
              
              guard let basicTableView = self.basicTableView else { return }
              
              basicTableView.reloadData()
              
              activityIndicatorView.stopAnimating()
              
              UIView.animate(withDuration: 0.2, animations: {
                basicTableView.alpha = 1.0
              })
            } else {
              self.isFollowed = false
              
              guard let basicTableView = self.basicTableView else { return }
              
              basicTableView.reloadData()
              
              activityIndicatorView.stopAnimating()
              
              UIView.animate(withDuration: 0.2, animations: {
                basicTableView.alpha = 1.0
              })
            }
          }
          
          if snapshot.value as? [String: Any] == nil {
            guard let activityIndicatorView = self.activityIndicatorView else { return }
            
            activityIndicatorView.stopAnimating()
          }
        }
      }
    } else {
      self.isFollowed = false
      
      guard let basicTableView = self.basicTableView else { return }
      
      basicTableView.reloadData()
      
      activityIndicatorView.stopAnimating()
      
      UIView.animate(withDuration: 0.2, animations: {
        basicTableView.alpha = 1.0
      })
    }
  }
}

//MARK: UITableViewDataSource
extension ANIOtherProfileBasicView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else {
      if contentType == .profile {
        tableView.backgroundColor = .white
        return 1
      } else if contentType == .recruit {
        tableView.backgroundColor = ANIColor.bg
        return recruits.count
      } else if contentType == .story {
        tableView.backgroundColor = ANIColor.bg
        return stories.count
      } else {
        tableView.backgroundColor = ANIColor.bg
        return qnas.count
      }
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    
    if section == 0 {
      let topCellId = NSStringFromClass(ANIOtherProfileTopCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: topCellId, for: indexPath) as! ANIOtherProfileTopCell
      
      cell.delegate = self
      cell.selectedIndex = contentType.rawValue
      cell.user = user
      
      return cell
    } else {
      if contentType == .profile {
        let profileCellid = NSStringFromClass(ANIOtherProfileCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCellid, for: indexPath) as! ANIOtherProfileCell
        
        cell.user = user
        if let isFollowed = self.isFollowed {
          cell.isFollowed = isFollowed
        }
        cell.delegate = self
        
        return cell
      } else if contentType == .recruit {
        let recruitCellid = NSStringFromClass(ANIRecruitViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: recruitCellid, for: indexPath) as! ANIRecruitViewCell
        
        cell.recruit = recruits[indexPath.row]
        cell.delegate = self
        
        return cell
      } else if contentType == .story {
        if !stories.isEmpty {
          if stories[indexPath.row].recruitId != nil {
            let supportCellId = NSStringFromClass(ANISupportViewCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
            
            cell.story = stories[indexPath.row]
            cell.delegate = self
            
            return cell
          } else {
            let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
            
            cell.story = stories[indexPath.row]
            cell.delegate = self
            
            return cell
          }
        } else {
          return UITableViewCell()
        }
      } else {
        let qnaCellid = NSStringFromClass(ANIQnaViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: qnaCellid, for: indexPath) as! ANIQnaViewCell
        
        cell.qna = qnas[indexPath.row]
        cell.delegate = self
        
        return cell
      }
    }
  }
}

//MARK: UITableViewDelegate
extension ANIOtherProfileBasicView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if contentType == .recruit, let cell = cell as? ANIRecruitViewCell {
      cell.unobserveLove()
      cell.unobserveSupport()
    } else if contentType == .story {
      if !stories.isEmpty {
        if stories[indexPath.row].recruitId != nil, let cell = cell as? ANISupportViewCell {
          cell.unobserveLove()
        } else if let cell = cell as? ANIStoryViewCell {
          cell.unobserveLove()
        }
      }
    } else if contentType == .qna, let cell = cell as? ANIRecruitViewCell {
      cell.unobserveLove()
    }
  }
}

//MARK: ANIProfileMenuBarDelegate
extension ANIOtherProfileBasicView: ANIProfileMenuBarDelegate {
  func didSelecteMenuItem(selectedIndex: Int) {
    guard let basicTableView = self.basicTableView else { return }
    
    switch selectedIndex {
    case ContentType.profile.rawValue:
      contentType = .profile
    case ContentType.story.rawValue:
      contentType = .story
    case ContentType.recruit.rawValue:
      contentType = .recruit
    case ContentType.qna.rawValue:
      contentType = .qna
    default:
      print("default")
    }
    
    basicTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
  }
}

//MARK: ANIOtherProfileCellDelegate
extension ANIOtherProfileBasicView: ANIOtherProfileCellDelegate {
  func followingTapped() {
    self.delegate?.followingTapped()
  }
  
  func followerTapped() {
    self.delegate?.followerTapped()
  }
}

//MARK: ANIRecruitViewCellDelegate
extension ANIOtherProfileBasicView: ANIRecruitViewCellDelegate {
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportButtonTapped(supportRecruit: supportRecruit, user: user)
  }
  
  func cellTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.recruitViewCellDidSelect(selectedRecruit: recruit, user: user)
  }
  
  func reject() {
    self.delegate?.reject()
  }
}

//MARK: ANIStoryViewCellDelegate
extension ANIOtherProfileBasicView: ANIStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
}

//MARK: ANISupportViewCellDelegate
extension ANIOtherProfileBasicView: ANISupportViewCellDelegate {
  func supportCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportCellRecruitTapped(recruit: recruit, user: user)
  }
}

//MARK: ANIQnaViewCellDelegate
extension ANIOtherProfileBasicView: ANIQnaViewCellDelegate {
  func cellTapped(qna: FirebaseQna, user: FirebaseUser) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: user)
  }
}

//MARK: data
extension ANIOtherProfileBasicView {
  private func loadUser() {
    guard let userId = self.userId,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    activityIndicatorView.startAnimating()
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_USERS).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
        
        guard let value = snapshot.value else { return }
        do {
          let user = try FirebaseDecoder().decode(FirebaseUser.self, from: value)
          
          self.user = user
        } catch let error {
          print(error)
        }
      })
    }
  }
  
  private func loadRecruit() {
    guard let user = self.user,
          let uid = user.uid else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_POST_RECRUIT_IDS).child(uid).queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot {
            databaseRef.child(KEY_RECRUITS).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
              
              guard let value = snapshot.value else { return }
              do {
                let recruit = try FirebaseDecoder().decode(FirebaseRecruit.self, from: value)
                self.recruits.insert(recruit, at: 0)
                
                DispatchQueue.main.async {
                  guard let basicTableView = self.basicTableView else { return }
                  basicTableView.reloadData()
                }
              } catch let error {
                print(error)
              }
            })
          }
        }
      }
    }
  }
  
  private func loadStory() {
    guard let user = self.user,
          let uid = user.uid else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_POST_STORY_IDS).child(uid).queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot {
            databaseRef.child(KEY_STORIES).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
              
              guard let value = snapshot.value else { return }
              do {
                let story = try FirebaseDecoder().decode(FirebaseStory.self, from: value)
                self.stories.insert(story, at: 0)
                
                DispatchQueue.main.async {
                  guard let basicTableView = self.basicTableView else { return }
                  basicTableView.reloadData()
                }
              } catch let error {
                print(error)
              }
            })
          }
        }
      }
    }
  }
  
  private func loadQna() {
    guard let user = self.user,
          let uid = user.uid else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_POST_QNA_IDS).child(uid).queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
        
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot {
            databaseRef.child(KEY_QNAS).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
              guard let value = snapshot.value else { return }
              do {
                let qna = try FirebaseDecoder().decode(FirebaseQna.self, from: value)
                self.qnas.insert(qna, at: 0)
                
                DispatchQueue.main.async {
                  guard let basicTableView = self.basicTableView else { return }
                  basicTableView.reloadData()
                }
              } catch let error {
                print(error)
              }
            })
          }
        }
      }
    }
  }
}
