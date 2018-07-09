//
//  ANINotiDetailView.swift
//  Ani
//
//  Created by jeonminseop on 2018/07/09.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

protocol ANINotiDetailViewDelegate {
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit, user: FirebaseUser)
  func supportButtonTapped()
}

enum NotiKind {
  case recruit;
  case story;
  case qna;
}

class ANINotiDetailView: UIView {
  
  private weak var tableView: UITableView?
  
  var notiKind: NotiKind?
  var notiId: String? {
    didSet {
      guard let notiId = self.notiId,
            let notiKind = self.notiKind else { return }
      
      switch notiKind {
      case .recruit:
        loadRecruit(notiId: notiId)
      case .story:
        loadStory(notiId: notiId)
      case .qna:
        loadQna(notiId: notiId)
      }
    }
  }
  
  private var recruit: FirebaseRecruit?
  private var story: FirebaseStory?
  private var qna: FirebaseQna?
  
  var delegate: ANINotiDetailViewDelegate?
  
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
    let recruitCellid = NSStringFromClass(ANIRecruitViewCell.self)
    tableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: recruitCellid)
    let storyCellid = NSStringFromClass(ANIStoryViewCell.self)
    tableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellid)
    let supportCellId = NSStringFromClass(ANISupportViewCell.self)
    tableView.register(ANISupportViewCell.self, forCellReuseIdentifier: supportCellId)
    let qnaCellid = NSStringFromClass(ANIQnaViewCell.self)
    tableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: qnaCellid)
    tableView.dataSource = self
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.tableView = tableView
  }
}

//MARK: UITableViewDataSource
extension ANINotiDetailView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let notiKind = self.notiKind else { return UITableViewCell() }
    
    switch notiKind {
    case .recruit:
      let recruitCellid = NSStringFromClass(ANIRecruitViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: recruitCellid, for: indexPath) as! ANIRecruitViewCell
      
      cell.recruit = recruit
      cell.delegate = self
      
      return cell
    case .story:
      if story?.recruitId != nil {
        let supportCellId = NSStringFromClass(ANISupportViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
        
        cell.story = story
//        cell.delegate = self
        
        return cell
      } else {
        let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
        
        cell.story = story
//        cell.delegate = self
        
        return cell
      }
    case .qna:
      let qnaCellid = NSStringFromClass(ANIQnaViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: qnaCellid, for: indexPath) as! ANIQnaViewCell
      
      cell.qna = qna
//      cell.delegate = self
      
      return cell
    }
  }
}

//MARK: ANIRecruitViewCellDelegate
extension ANINotiDetailView: ANIRecruitViewCellDelegate {
  func supportButtonTapped(supportRecruit: FirebaseRecruit) {
    self.delegate?.supportButtonTapped()
  }
  
  func cellTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.recruitViewCellDidSelect(selectedRecruit: recruit, user: user)
  }
  
  func reject() {
  }
}

//MARK: data
extension ANINotiDetailView {
  private func loadRecruit(notiId: String) {
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      databaseRef.child(KEY_RECRUITS).child(notiId).observeSingleEvent(of: .value, with: { (snapshot) in
        
        guard let value = snapshot.value else { return }
        do {
          let recruit = try FirebaseDecoder().decode(FirebaseRecruit.self, from: value)
          self.recruit = recruit
          
          DispatchQueue.main.async {
            guard let tableView = self.tableView else { return }
            
            tableView.reloadData()
          }
        } catch let error {
          print(error)
        }
      })
    }
  }
  
  private func loadStory(notiId: String) {
    let databaseRef = Database.database().reference()

    DispatchQueue.global().async {
      databaseRef.child(KEY_STORIES).child(notiId).observeSingleEvent(of: .value, with: { (snapshot) in
        
        guard let value = snapshot.value else { return }
        do {
          let story = try FirebaseDecoder().decode(FirebaseStory.self, from: value)
          self.story = story
          
          DispatchQueue.main.async {
            guard let tableView = self.tableView else { return }
            tableView.reloadData()
          }
        } catch let error {
          print(error)
        }
      })
    }
  }
  
  private func loadQna(notiId: String) {
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      databaseRef.child(KEY_QNAS).child(notiId).observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
          let qna = try FirebaseDecoder().decode(FirebaseQna.self, from: value)
          self.qna = qna
          
          DispatchQueue.main.async {
            guard let tableView = self.tableView else { return }
            tableView.reloadData()
          }
        } catch let error {
          print(error)
        }
      })
    }
  }
}
