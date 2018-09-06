//
//  ANIProfileBasicView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

protocol ANIProfileBasicViewDelegate {
  func followingTapped()
  func followerTapped()
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit, user: FirebaseUser)
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user:FirebaseUser)
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser)
  func reject()
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String)
}

enum ContentType: Int {
  case profile;
  case recruit;
  case story;
  case qna;
}

class ANIProfileBasicView: UIView {
  
  enum SectionType:Int { case top = 0; case content = 1 }
  
  private var contentType:ContentType = .profile {
    didSet {
      self.basicTableView?.reloadData()
      self.layoutIfNeeded()
      
      isMenuChange = false
    }
  }
  
  private weak var basicTableView: UITableView?
  
  private var recruits = [FirebaseRecruit]()
  private var stories = [FirebaseStory]()
  private var qnas = [FirebaseQna]()
  private var supportRecruits = [FirebaseRecruit]()
  
  var currentUser: FirebaseUser? {
    didSet {
      guard let basicTableView = self.basicTableView else { return }
      
      basicTableView.reloadData()
    }
  }
  
  private var isMenuChange: Bool = false
  
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
  
  func loadData() {
    loadRecruit()
    loadStory()
    loadQna()
  }
  
  func deleteData(id: String) {
    guard let basicTableView = self.basicTableView else { return }
    
    var indexPath: IndexPath = [0, 0]
    
    switch contentType {
    case .recruit:
      for (index, recruit) in recruits.enumerated() {
        if recruit.id == id {
          recruits.remove(at: index)
          indexPath = [1, index]
        }
      }
    case .story:
      for (index, story) in stories.enumerated() {
        if story.id == id {
          stories.remove(at: index)
          indexPath = [1, index]
        }
      }
    case .qna:
      for (index, qna) in qnas.enumerated() {
        if qna.id == id {
          qnas.remove(at: index)
          indexPath = [1, index]
        }
      }
    default:
      print("profile")
    }
    
    basicTableView.deleteRows(at: [indexPath], with: .automatic)
  }
  
  private func unobserveBeforeMenu() {
    guard let basicTableView = self.basicTableView else { return }
    
    if contentType == .recruit {
      for i in 0 ..< recruits.count {
        if let recruitCell = basicTableView.cellForRow(at: [1, i]) as? ANIRecruitViewCell {
          recruitCell.unobserveLove()
          recruitCell.unobserveSupport()
        }
      }
    } else if contentType == .story {
      for i in 0 ..< stories.count {
        if let storyCell = basicTableView.cellForRow(at: [1, i]) as? ANIStoryViewCell {
          storyCell.unobserveLove()
          storyCell.unobserveComment()
        } else if let supportCell = basicTableView.cellForRow(at: [1, i]) as? ANISupportViewCell {
          supportCell.unobserveLove()
          supportCell.unobserveComment()
        }
      }
    } else if contentType == .qna {
      for i in 0 ..< qnas.count {
        if let qnaCell = basicTableView.cellForRow(at: [1, i]) as? ANIQnaViewCell {
          qnaCell.unobserveLove()
          qnaCell.unobserveComment()
        }
      }
    }
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
    if indexPath.section == 0 {
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
            
            if let recruitId = stories[indexPath.row].recruitId, supportRecruits.count != 0 {
              for supportRecruit in supportRecruits {
                if let supportRecruitId = supportRecruit.id, supportRecruitId == recruitId {
                  cell.recruit = supportRecruit
                  break
                }
              }
            } else {
              cell.recruit = nil
            }
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
    guard !isMenuChange else { return }
    
    if contentType == .recruit, let cell = cell as? ANIRecruitViewCell {
        cell.unobserveLove()
        cell.unobserveSupport()
    } else if contentType == .story {
      if !stories.isEmpty {
        if stories[indexPath.row].recruitId != nil, let cell = cell as? ANISupportViewCell {
          cell.unobserveLove()
          cell.unobserveComment()
        } else if let cell = cell as? ANIStoryViewCell {
          cell.unobserveLove()
          cell.unobserveComment()
        }
      }
    } else if contentType == .qna, let cell = cell as? ANIQnaViewCell {
      cell.unobserveLove()
      cell.unobserveComment()
    }
  }
}

//MARK: ANIProfileMenuBarDelegate
extension ANIProfileBasicView: ANIProfileMenuBarDelegate {
  func didSelecteMenuItem(selectedIndex: Int) {
    guard let basicTableView = self.basicTableView else { return }
    
    isMenuChange = true
    unobserveBeforeMenu()
    
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
  
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportButtonTapped(supportRecruit: supportRecruit, user: user)
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
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, contentType: contentType, id: id)
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
  
  func loadedRecruit(recruit: FirebaseRecruit) {
    self.supportRecruits.append(recruit)
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
    guard let currentUserId = ANISessionManager.shared.currentUserUid else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_RECRUITS).whereField(KEY_USER_ID, isEqualTo: currentUserId).order(by: KEY_DATE, descending: false).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        snapshot.documentChanges.forEach({ (diff) in
          if diff.type == .added {
            do {
              let recruit = try FirestoreDecoder().decode(FirebaseRecruit.self, from: diff.document.data())
              
              self.recruits.insert(recruit, at: 0)
              
              DispatchQueue.main.async {
                guard let basicTableView = self.basicTableView else { return }
                basicTableView.reloadData()
              }
            } catch let error {
              print(error)
            }
          } else if diff.type == .removed {
            do {
              let deleteRecruit = try FirestoreDecoder().decode(FirebaseRecruit.self, from: diff.document.data())

              for (index, recruit) in self.recruits.enumerated() {
                if recruit.id == deleteRecruit.id {
                  self.recruits.remove(at: index)
                  
                  DispatchQueue.main.async {
                    guard let basicTableView = self.basicTableView else { return }
                    basicTableView.reloadData()
                    return
                  }
                }
              }
            } catch let error {
              print(error)
            }
          }
        })
      })
    }
  }
  
  private func loadStory() {
    guard let currentUserId = ANISessionManager.shared.currentUserUid else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_STORIES).whereField(KEY_USER_ID, isEqualTo: currentUserId).order(by: KEY_DATE, descending: false).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        snapshot.documentChanges.forEach({ (diff) in
          if diff.type == .added {
            do {
              let story = try FirestoreDecoder().decode(FirebaseStory.self, from: diff.document.data())
              
              self.stories.insert(story, at: 0)
              
              DispatchQueue.main.async {
                guard let basicTableView = self.basicTableView else { return }
                basicTableView.reloadData()
              }
            } catch let error {
              print(error)
            }
          } else if diff.type == .removed {
            do {
              let deleteStory = try FirestoreDecoder().decode(FirebaseStory.self, from: diff.document.data())
              
              for (index, story) in self.stories.enumerated() {
                if story.id == deleteStory.id {
                  self.stories.remove(at: index)
                  
                  DispatchQueue.main.async {
                    guard let basicTableView = self.basicTableView else { return }
                    basicTableView.reloadData()
                    return
                  }
                }
              }
            } catch let error {
              print(error)
            }
          }
        })
      })
    }
  }
  
  private func loadQna() {
    guard let currentUserId = ANISessionManager.shared.currentUserUid else { return }
    
    let database = Firestore.firestore()

    DispatchQueue.global().async {
      database.collection(KEY_QNAS).whereField(KEY_USER_ID, isEqualTo: currentUserId).order(by: KEY_DATE, descending: false).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        snapshot.documentChanges.forEach({ (diff) in
          if diff.type == .added {
            do {
              let qna = try FirestoreDecoder().decode(FirebaseQna.self, from: diff.document.data())
              
              self.qnas.insert(qna, at: 0)
              DispatchQueue.main.async {
                guard let basicTableView = self.basicTableView else { return }
                
                basicTableView.reloadData()
              }
            } catch let error {
              print(error)
            }
          } else if diff.type == .removed {
            do {
              let deleteQna = try FirestoreDecoder().decode(FirebaseQna.self, from: diff.document.data())
              
              for (index, qna) in self.qnas.enumerated() {
                if qna.id == deleteQna.id {
                  self.qnas.remove(at: index)
                  
                  DispatchQueue.main.async {
                    guard let basicTableView = self.basicTableView else { return }
                    basicTableView.reloadData()
                    return
                  }
                }
              }
            } catch let error {
              print(error)
            }
          }
        })
      })
    }
  }
}
