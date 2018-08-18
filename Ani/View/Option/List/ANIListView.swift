//
//  ANIListView.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/25.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import NVActivityIndicatorView

protocol ANIListViewDelegate {
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit, user: FirebaseUser)
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user:FirebaseUser)
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser)
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String)
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
  
  func deleteData(id: String) {
    guard let list = self.list,
          let listTableView = self.listTableView else { return }
    
    var indexPath: IndexPath = [0, 0]
    
    switch list {
    case .loveRecruit:
      for (index, loveRecruit) in loveRecruits.enumerated() {
        if loveRecruit.id == id {
          loveRecruits.remove(at: index)
          indexPath = [0, index]
        }
      }
    case .loveStroy:
      for (index, loveStory) in loveStories.enumerated() {
        if loveStory.id == id {
          loveStories.remove(at: index)
          indexPath = [0, index]
        }
      }
    case .loveQuestion:
      for (index, loveQna) in loveQnas.enumerated() {
        if loveQna.id == id {
          loveQnas.remove(at: index)
          indexPath = [0, index]
        }
      }
    case .clipRecruit:
      for (index, clipRecruit) in clipRecruits.enumerated() {
        if clipRecruit.id == id {
          clipRecruits.remove(at: index)
          indexPath = [0, index]
        }
      }
    }
    
    listTableView.deleteRows(at: [indexPath], with: .automatic)
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
          cell.unobserveComment()
        } else if let cell = cell as? ANIStoryViewCell {
          cell.unobserveLove()
          cell.unobserveComment()
        }
      }
    case .loveQuestion:
      if let cell = cell as? ANIQnaViewCell {
        cell.unobserveLove()
        cell.unobserveComment()
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
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, contentType: contentType, id: id)
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
    guard let currentUserId = ANISessionManager.shared.currentUserUid,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_USERS).document(currentUserId).collection(KEY_LOVE_RECRUIT_IDS).order(by: KEY_DATE, descending: true).limit(to: 20).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        let group =  DispatchGroup()
        var loveRecruitsTemp = [FirebaseRecruit?]()
        
        for (index, document) in snapshot.documents.enumerated() {
          
          group.enter()
          loveRecruitsTemp.append(nil)
          
          DispatchQueue(label: "loveRecruit").async {
            database.collection(KEY_RECRUITS).document(document.documentID).getDocument(completion: { (recruitSnapshot, recruitError) in
              if let recruitError = recruitError {
                print("Error get document: \(recruitError)")
                
                return
              }
              
              guard let recruitSnapshot = recruitSnapshot, let data = recruitSnapshot.data() else { return }
              
              do {
                let recruit = try FirestoreDecoder().decode(FirebaseRecruit.self, from: data)
                loveRecruitsTemp[index] = recruit
                
                group.leave()
              } catch let error {
                print(error)
                
                activityIndicatorView.stopAnimating()
              }
            })
          }
        }

        group.notify(queue: DispatchQueue(label: "loveRecruit")) {
          DispatchQueue.main.async {
            guard let listTableView = self.listTableView else { return }
            
            for loveRecruit in loveRecruitsTemp {
              if let loveRecruit = loveRecruit {
                self.loveRecruits.append(loveRecruit)
              }
            }
            
            listTableView.reloadData()
            
            activityIndicatorView.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: {
              listTableView.alpha = 1.0
            })
          }
        }
        
        if snapshot.documents.isEmpty {
          guard let activityIndicatorView = self.activityIndicatorView else { return }
          
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
  
  private func loadLoveStory() {
    guard let currentUserId = ANISessionManager.shared.currentUserUid,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_USERS).document(currentUserId).collection(KEY_LOVE_STORY_IDS).order(by: KEY_DATE, descending: true).limit(to: 20).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        let group =  DispatchGroup()
        var loveStoriesTemp = [FirebaseStory?]()
        
        for (index, document) in snapshot.documents.enumerated() {
          
          group.enter()
          loveStoriesTemp.append(nil)
          
          DispatchQueue(label: "loveStory").async {
            database.collection(KEY_STORIES).document(document.documentID).getDocument(completion: { (storySnapshot, storyError) in
              if let storyError = storyError {
                print("Error get document: \(storyError)")
                
                return
              }
              
              guard let storySnapshot = storySnapshot, let data = storySnapshot.data() else {
                group.leave()
                
                return
              }
              
              do {
                let story = try FirestoreDecoder().decode(FirebaseStory.self, from: data)
                loveStoriesTemp[index] = story
                
                group.leave()
              } catch let error {
                print(error)
                
                group.leave()                
              }
            })
          }
        }
        
        group.notify(queue: DispatchQueue(label: "loveStory")) {
          DispatchQueue.main.async {
            guard let listTableView = self.listTableView else { return }
            
            for loveStory in loveStoriesTemp {
              if let loveStory = loveStory {
                self.loveStories.append(loveStory)
              }
            }
            
            listTableView.reloadData()
            
            activityIndicatorView.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: {
              listTableView.alpha = 1.0
            })
          }
        }
        
        if snapshot.documents.isEmpty {
          guard let activityIndicatorView = self.activityIndicatorView else { return }
          
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
  
  private func loadLoveQna() {
    guard let currentUserId = ANISessionManager.shared.currentUserUid,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_USERS).document(currentUserId).collection(KEY_LOVE_QNA_IDS).order(by: KEY_DATE, descending: true).limit(to: 20).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        let group =  DispatchGroup()
        var loveQnasTemp = [FirebaseQna?]()
        
        for (index, document) in snapshot.documents.enumerated() {
          
          group.enter()
          loveQnasTemp.append(nil)
          
          DispatchQueue(label: "loveQna").async {
            database.collection(KEY_QNAS).document(document.documentID).getDocument(completion: { (qnaSnapshot, qnaError) in
              if let qnaError = qnaError {
                print("Error get document: \(qnaError)")
                
                return
              }
              
              guard let qnaSnapshot = qnaSnapshot, let data = qnaSnapshot.data() else {
                group.leave()
                return
              }
              
              do {
                let qna = try FirestoreDecoder().decode(FirebaseQna.self, from: data)
                loveQnasTemp[index] = qna
                
                group.leave()
              } catch let error {
                print(error)
                
                group.leave()
              }
            })
          }
        }
        
        group.notify(queue: DispatchQueue(label: "loveQna")) {
          DispatchQueue.main.async {
            guard let listTableView = self.listTableView else { return }
            
            for loveQna in loveQnasTemp {
              if let loveQna = loveQna {
                self.loveQnas.append(loveQna)
              }
            }
            
            listTableView.reloadData()
            
            activityIndicatorView.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: {
              listTableView.alpha = 1.0
            })
          }
        }
        
        if snapshot.documents.isEmpty {
          guard let activityIndicatorView = self.activityIndicatorView else { return }
          
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
  
  private func loadClipRecruit() {
    guard let currentUserId = ANISessionManager.shared.currentUserUid,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_USERS).document(currentUserId).collection(KEY_CLIP_RECRUIT_IDS).order(by: KEY_DATE, descending: true).limit(to: 20).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        let group =  DispatchGroup()
        var clipRecruitsTemp = [FirebaseRecruit?]()
        
        for (index, document) in snapshot.documents.enumerated() {
          
          group.enter()
          clipRecruitsTemp.append(nil)
          
          DispatchQueue(label: "clipRecruit").async {
            database.collection(KEY_RECRUITS).document(document.documentID).getDocument(completion: { (recruitSnapshot, recruitError) in
              if let recruitError = recruitError {
                print("Error get document: \(recruitError)")
                
                return
              }
              
              guard let recruitSnapshot = recruitSnapshot, let data = recruitSnapshot.data() else {
                group.leave()
                
                return
              }
              
              do {
                let recruit = try FirestoreDecoder().decode(FirebaseRecruit.self, from: data)
                clipRecruitsTemp[index] = recruit
                
                group.leave()
              } catch let error {
                print(error)
                
                group.leave()
              }
            })
          }
        }
        
        group.notify(queue: DispatchQueue(label: "clipRecruit")) {
          DispatchQueue.main.async {
            guard let listTableView = self.listTableView else { return }
            
            for clipRecruit in clipRecruitsTemp {
              if let clipRecruit = clipRecruit {
                self.clipRecruits.append(clipRecruit)
              }
            }
            
            listTableView.reloadData()
            
            activityIndicatorView.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: {
              listTableView.alpha = 1.0
            })
          }
        }
        
        if snapshot.documents.isEmpty {
          guard let activityIndicatorView = self.activityIndicatorView else { return }
          
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
}
