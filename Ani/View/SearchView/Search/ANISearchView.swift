//
//  UserSearchView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import CodableFirebase
import NVActivityIndicatorView
import InstantSearchClient

protocol ANISearchViewDelegate {
  func searchViewDidScroll(scrollY: CGFloat)
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user:FirebaseUser)
  func reject()
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String)
}

enum SearchCategory: String {
  case user = "ユーザー";
  case story = "ストーリー";
  case qna = "Q&A";
}

class ANISearchView: UIView {
  
  private weak var tableView: UITableView?
  
  private var searchUsers = [FirebaseUser]()
  private var searchStories = [FirebaseStory]()
  private var searchQnas = [FirebaseQna]()
  private var supportRecruits = [FirebaseRecruit]()
  
  var selectedCategory: SearchCategory = .user {
    didSet {
      if searchText != "" {
        guard let tableView = self.tableView else { return }

        UIView.animate(withDuration: 0.2) {
          tableView.alpha = 0.0
        }
        
        search(category: selectedCategory, searchText: searchText)
      }
    }
  }
  
  var searchText: String = "" {
    didSet {
      if searchText != "" {
        guard let tableView = self.tableView else { return }
        
        UIView.animate(withDuration: 0.2) {
          tableView.alpha = 0.0
        }
        
        search(category: selectedCategory, searchText: searchText)
      }
    }
  }
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var delegate: ANISearchViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupNotifications()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = ANIColor.bg
    
    //tableView
    let tableView = UITableView()
    tableView.separatorStyle = .none
    let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.FILTERS_VIEW_HEIGHT
    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    tableView.backgroundColor = ANIColor.bg
    tableView.alpha = 0.0
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
  
  func deleteData(id: String) {
    guard let tableView = self.tableView else { return }
    
    var indexPath: IndexPath = [0, 0]
    
    if selectedCategory == .story {
      for (index, searchStory) in searchStories.enumerated() {
        if searchStory.id == id {
          searchStories.remove(at: index)
          indexPath = [0, index]
        }
      }
    } else if selectedCategory == .qna {
      for (index, searchQna) in searchQnas.enumerated() {
        if searchQna.id == id {
          searchQnas.remove(at: index)
          indexPath = [0, index]
        }
      }
    }
    
    tableView.deleteRows(at: [indexPath], with: .automatic)
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
      cell.delegate = self
      
      return cell
    case .story:
      if !searchStories.isEmpty {
        if searchStories[indexPath.row].recruitId != nil {
          let supportCellId = NSStringFromClass(ANISupportViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: supportCellId, for: indexPath) as! ANISupportViewCell
          
          if let recruitId = searchStories[indexPath.row].recruitId, supportRecruits.count != 0 {
            for supportRecruit in supportRecruits {
              if let supportRecruitId = supportRecruit.id, supportRecruitId == recruitId {
                cell.recruit = supportRecruit
                break
              }
            }
          } else {
            cell.recruit = nil
          }
          cell.story = searchStories[indexPath.row]
          cell.delegate = self
          cell.indexPath = indexPath.row
          
          return cell
        } else {
          let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
          let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell
          
          cell.story = searchStories[indexPath.row]
          cell.delegate = self
          cell.indexPath = indexPath.row
          
          return cell
        }
      } else {
        return UITableViewCell()
      }
    case .qna:
      let qnaId = NSStringFromClass(ANIQnaViewCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: qnaId, for: indexPath) as! ANIQnaViewCell
      
      cell.qna = searchQnas[indexPath.row]
      cell.delegate = self
      cell.indexPath = indexPath.row
      
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
  
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if selectedCategory == .story {
      if !searchStories.isEmpty {
        if searchStories[indexPath.row].recruitId != nil, let cell = cell as? ANISupportViewCell {
          cell.unobserveLove()
        } else if let cell = cell as? ANIStoryViewCell {
          cell.unobserveLove()
        }
      }
    } else if selectedCategory == .qna, let cell = cell as? ANIRecruitViewCell {
      cell.unobserveLove()
    }
  }
}

//MARK: ANIUserSearchViewCellDelegate
extension ANISearchView: ANIUserSearchViewCellDelegate {
  func reject() {
    self.delegate?.reject()
  }
}

//MARK: ANIStoryViewCellDelegate
extension ANISearchView: ANIStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, contentType: contentType, id: id)
  }
  
  func loadedStoryIsLoved(indexPath: Int, isLoved: Bool) {
    var searchStory = self.searchStories[indexPath]
    searchStory.isLoved = isLoved
    self.searchStories[indexPath] = searchStory
  }
}

//MARK: ANISupportViewCellDelegate
extension ANISearchView: ANISupportViewCellDelegate {
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
extension ANISearchView: ANIQnaViewCellDelegate {
  func cellTapped(qna: FirebaseQna, user: FirebaseUser) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qna, user: user)
  }
  
  func loadedQnaIsLoved(indexPath: Int, isLoved: Bool) {
    var searchQna = self.searchQnas[indexPath]
    searchQna.isLoved = isLoved
    self.searchQnas[indexPath] = searchQna
  }
}

//MARK: search
extension ANISearchView {
  private func search(category: SearchCategory, searchText: String) {
    guard let activityIndicatorView = self.activityIndicatorView else { return }
    
    var index: Index?
    
    switch category {
    case .user:
      index = ANISessionManager.shared.client.index(withName: KEY_USERS_INDEX)
      
      if !searchUsers.isEmpty {
        searchUsers.removeAll()
      }
    case .story:
      index = ANISessionManager.shared.client.index(withName: KEY_STORIES_INDEX)
      
      if !searchStories.isEmpty {
        searchStories.removeAll()
        supportRecruits.removeAll()
      }
    case .qna:
      index = ANISessionManager.shared.client.index(withName: KEY_QNAS_INDEX)
      
      if !searchQnas.isEmpty {
        searchQnas.removeAll()
      }
    }
    
    activityIndicatorView.startAnimating()
    
    DispatchQueue.global().async {
      index?.search(Query(query: searchText), completionHandler: { (content, error) -> Void in
        if let content = content, let hits = content[KEY_HITS] as? [AnyObject], !hits.isEmpty {
          for hit in hits {
            guard let hitDic = hit as? [String: AnyObject] else { return }
            
            do {
              switch category {
              case .user:
                let user = try FirebaseDecoder().decode(FirebaseUser.self, from: hitDic)
                
                if let currenUserUid = ANISessionManager.shared.currentUserUid {
                  if user.uid != currenUserUid {
                    self.searchUsers.append(user)
                  }
                } else {
                  self.searchUsers.append(user)
                }
              case .story:
                let story = try FirebaseDecoder().decode(FirebaseStory.self, from: hitDic)
                
                self.searchStories.append(story)
              case .qna:
                let qna = try FirebaseDecoder().decode(FirebaseQna.self, from: hitDic)
                
                self.searchQnas.append(qna)
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
              guard let tableView = self.tableView else { return }
              
              tableView.reloadData()

              print(error)
              
              activityIndicatorView.stopAnimating()
            }
          }
        } else if let error = error {
          guard let tableView = self.tableView else { return }
          
          tableView.reloadData()
          
          print("error: \(error)")
          
          activityIndicatorView.stopAnimating()
        } else {
          guard let tableView = self.tableView else { return }
          
          tableView.reloadData()
          
          activityIndicatorView.stopAnimating()
        }
      })
    }
  }
}
