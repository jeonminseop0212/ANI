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
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit)
  func storyViewCellDidSelect(selectedStory: FirebaseStory)
  func qnaViewCellDidSelect(index: Int)
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
  
  var recruits = [FirebaseRecruit]()
  
  var storys = [FirebaseStory]()
  
  var qnas = [Qna]()
  
  var user: User?
  var currentUser: FirebaseUser? {
    didSet {
      loadRecruit()
      loadStory()

      guard let basicTableView = self.basicTableView else { return }
      basicTableView.reloadData()
    }
  }
  
  var delegate: ANIProfileBasicViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let basicTableView = UITableView()
    basicTableView.separatorStyle = .none
    basicTableView.dataSource = self
    basicTableView.delegate = self
    let topCellId = NSStringFromClass(ANIProfileTopCell.self)
    basicTableView.register(ANIProfileTopCell.self, forCellReuseIdentifier: topCellId)
    let profileCellid = NSStringFromClass(ANIProfileCell.self)
    basicTableView.register(ANIProfileCell.self, forCellReuseIdentifier: profileCellid)
    let recruitCellid = NSStringFromClass(ANIRecruitViewCell.self)
    basicTableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: recruitCellid)
    let storyCellid = NSStringFromClass(ANIStoryViewCell.self)
    basicTableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellid)
    let qnaCellid = NSStringFromClass(ANIQnaViewCell.self)
    basicTableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: qnaCellid)
    addSubview(basicTableView)
    basicTableView.edgesToSuperview()
    self.basicTableView = basicTableView
  }
  
  private func loadRecruit() {
    guard let currentUser = self.currentUser,
          let postRecruitIds = currentUser.postRecruitIds else { return }
    
    let sortedIds = postRecruitIds.sorted(by: {$0.key < $1.key})
    
    for sortedId in sortedIds {
      DispatchQueue.global().async {
        Database.database().reference().child(KEY_RECRUITS).child(sortedId.key).observe(.value, with: { (snapshot) in
          
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
    DispatchQueue.global().async {
      Database.database().reference().child(KEY_STORIES).observe(.childAdded, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
          let story = try FirebaseDecoder().decode(FirebaseStory.self, from: value)
          self.storys.insert(story, at: 0)
          
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
        return 1
      } else if contentType == .recruit {
        return recruits.count
      } else if contentType == .story {
        return storys.count
      } else {
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
        return cell
      } else if contentType == .recruit {
        let recruitCellid = NSStringFromClass(ANIRecruitViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: recruitCellid, for: indexPath) as! ANIRecruitViewCell
        
        cell.recruit = recruits[indexPath.row]

        return cell
      } else if contentType == .story {
        let storyCellid = NSStringFromClass(ANIStoryViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: storyCellid, for: indexPath) as! ANIStoryViewCell
        
        cell.story = storys[indexPath.row]

        return cell
      } else {
        let qnaCellid = NSStringFromClass(ANIQnaViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: qnaCellid, for: indexPath) as! ANIQnaViewCell
        
        cell.qna = qnas[indexPath.row]

        return cell
      }
    }
  }
}

extension ANIProfileBasicView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch contentType {
    case .profile:
      return
    case .recruit:
      self.delegate?.recruitViewCellDidSelect(selectedRecruit: recruits[indexPath.row])
    case .story:
      self.delegate?.storyViewCellDidSelect(selectedStory: storys[indexPath.row])
    case .qna:
      self.delegate?.qnaViewCellDidSelect(index: indexPath.row)
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
