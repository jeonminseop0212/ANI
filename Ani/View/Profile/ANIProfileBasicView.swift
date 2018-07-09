//
//  ANIProfileBasicView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

protocol ANIProfileBasicViewDelegate {
  func followingTapped()
  func followerTapped()
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit, user: FirebaseUser)
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user:FirebaseUser)
  func supportButtonTapped()
  func reject()
}

class ANIProfileBasicView: UIView {
  
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
  
  var currentUser: FirebaseUser? {
    didSet {
      loadRecruit()
      loadStory()
      loadQna()

      guard let basicTableView = self.basicTableView else { return }
      basicTableView.reloadData()
    }
  }
  
  var delegate: ANIProfileBasicViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupNotifications()
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
    let topCellId = NSStringFromClass(ANIProfileTopCell.self)
    basicTableView.register(ANIProfileTopCell.self, forCellReuseIdentifier: topCellId)
    let profileCellId = NSStringFromClass(ANIProfileCell.self)
    basicTableView.register(ANIProfileCell.self, forCellReuseIdentifier: profileCellId)
    let recruitCellId = NSStringFromClass(ANIRecruitViewCell.self)
    basicTableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: recruitCellId)
    let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
    basicTableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellId)
    let supportCellId = NSStringFromClass(ANISupportViewCell.self)
    basicTableView.register(ANISupportViewCell.self, forCellReuseIdentifier: supportCellId)
    let qnaCellId = NSStringFromClass(ANIQnaViewCell.self)
    basicTableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: qnaCellId)
    addSubview(basicTableView)
    basicTableView.edgesToSuperview()
    self.basicTableView = basicTableView
  }
  
  private func setupNotifications() {
    ANINotificationManager.receive(login: self, selector: #selector(reloadUser))
    ANINotificationManager.receive(profileTabTapped: self, selector: #selector(scrollToTop))
  }
  
  @objc private func reloadUser() {
    guard let currentUser = ANISessionManager.shared.currentUser else { return }
    
    self.currentUser = currentUser
  }
  
  @objc private func scrollToTop() {
    guard let basicTableView = basicTableView else { return }
    
    basicTableView.scrollToRow(at: [0, 0], at: .top, animated: true)
  }
}

//MARK: UITableViewDataSource
extension ANIProfileBasicView: UITableViewDataSource {
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
      let topCellId = NSStringFromClass(ANIProfileTopCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: topCellId, for: indexPath) as! ANIProfileTopCell
      
      cell.delegate = self
      cell.selectedIndex = contentType.rawValue
      cell.user = currentUser
      
      return cell
    } else {
      if contentType == .profile {
        let profileCellid = NSStringFromClass(ANIProfileCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCellid, for: indexPath) as! ANIProfileCell
        
        cell.user = currentUser
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
extension ANIProfileBasicView: UITableViewDelegate {
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
extension ANIProfileBasicView: ANIProfileMenuBarDelegate {
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

//MARK: ANIProfileCellDelegate
extension ANIProfileBasicView: ANIProfileCellDelegate {
  func followingTapped() {
    self.delegate?.followingTapped()
  }
  
  func followerTapped() {
    self.delegate?.followerTapped()
  }
}

//MARK: ANIRecruitViewCellDelegate
extension ANIProfileBasicView: ANIRecruitViewCellDelegate {
  func reject() {
    self.delegate?.reject()
  }
  
  func supportButtonTapped(supportRecruit: FirebaseRecruit) {
    self.delegate?.supportButtonTapped()
  }
  
  func cellTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.recruitViewCellDidSelect(selectedRecruit: recruit, user: user)
  }
}

//MARK: ANIStoryViewCellDelegate
extension ANIProfileBasicView: ANIStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
}

//MARK: ANISupportViewCellDelegate
extension ANIProfileBasicView: ANISupportViewCellDelegate {
  func supportCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportCellRecruitTapped(recruit: recruit, user: user)
  }
}

//MARK: ANIQnaViewCellDelegate
extension ANIProfileBasicView: ANIQnaViewCellDelegate {
  func cellTapped(qna: FirebaseQna, user: FirebaseUser) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: user)
  }
}

//MARK: data
extension ANIProfileBasicView {
  private func loadRecruit() {
    guard let currentUser = self.currentUser,
          let uid = currentUser.uid else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_POST_RECRUIT_IDS).child(uid).queryLimited(toFirst: 20).observe(.childAdded) { (snapshot) in
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
  
  private func loadStory() {
    guard let currentUser = self.currentUser,
          let uid = currentUser.uid else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_POST_STORY_IDS).child(uid).queryLimited(toFirst: 20).observe(.childAdded) { (snapshot) in
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
  
  private func loadQna() {
    guard let currentUser = self.currentUser,
          let uid = currentUser.uid else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_POST_QNA_IDS).child(uid).queryLimited(toFirst: 20).observe(.childAdded) { (snapshot) in
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
