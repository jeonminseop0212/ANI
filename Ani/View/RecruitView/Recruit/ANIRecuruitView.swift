//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import NVActivityIndicatorView

protocol ANIRecruitViewDelegate {
  func recruitCellTap(selectedRecruit: FirebaseRecruit, user: FirebaseUser)
  func recruitViewDidScroll(scrollY: CGFloat)
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser)
  func reject()
}

class ANIRecuruitView: UIView {
  
  private weak var reloadView: ANIReloadView?

  private weak var recruitTableView: UITableView? {
    didSet {
      guard let recruitTableView = self.recruitTableView else { return }
      let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.FILTERS_VIEW_HEIGHT + TABLE_VIEW_TOP_MARGIN
      recruitTableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    }
  }
  
  private let TABLE_VIEW_TOP_MARGIN: CGFloat = 10.0
  
  private var recruits = [FirebaseRecruit]()
  private var users = [FirebaseUser]()
  
  private var isLastRecruitPage: Bool = false
  private var lastRecruit: QueryDocumentSnapshot?
  private var isLoading: Bool = false
  private let COUNT_LAST_CELL: Int = 4
  
  var pickMode: FilterPickMode?
  var pickItem: String? {
    didSet {
      guard let pickMode = self.pickMode,
            let pickItem = self.pickItem else { return }
      
      switch pickMode {
      case .home:
        if pickItem == "選択しない" || pickItem == "" {
          homeFilter = nil
        } else {
          homeFilter = pickItem
        }
      case .kind:
        if pickItem == "選択しない" || pickItem == "" {
          kindFilter = nil
        } else {
          kindFilter = pickItem
        }
      case .age:
        if pickItem == "選択しない" || pickItem == "" {
          ageFilter = nil
        } else {
          ageFilter = pickItem
        }
      case .sex:
        if pickItem == "選択しない" || pickItem == "" {
          sexFilter = nil
        } else {
          sexFilter = pickItem
        }
      }
      
      setupQuery()
    }
  }
  
  private var homeFilter: String?
  private var kindFilter: String?
  private var ageFilter: String?
  private var sexFilter: String?
  
  private var query: Query?
  
  private weak var activityIndicatorView: NVActivityIndicatorView?
  
  var delegate:ANIRecruitViewDelegate?
  
  private var cellHeight = [IndexPath: CGFloat]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupNotifications()
    loadRecruit(sender: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //basic
    self.backgroundColor = ANIColor.bg
    
    //reloadView
    let reloadView = ANIReloadView()
    reloadView.alpha = 0.0
    reloadView.messege = "募集がありません。"
    reloadView.delegate = self
    addSubview(reloadView)
    reloadView.dropShadow()
    reloadView.centerInSuperview()
    reloadView.leftToSuperview(offset: 50.0)
    reloadView.rightToSuperview(offset: -50.0)
    self.reloadView = reloadView
    
    //recruitTableView
    let tableView = UITableView()
    tableView.separatorStyle = .none
    let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.FILTERS_VIEW_HEIGHT + TABLE_VIEW_TOP_MARGIN
    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.backgroundColor = ANIColor.bg
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    tableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.delegate = self
    let refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = .clear
    refreshControl.tintColor = ANIColor.moreDarkGray
    refreshControl.addTarget(self, action: #selector(loadRecruit(sender:)), for: .valueChanged)
    tableView.alpha = 0.0
    tableView.rowHeight = UITableView.automaticDimension
    tableView.addSubview(refreshControl)
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.recruitTableView = tableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.emerald, padding: 0)
    addSubview(activityIndicatorView)
    activityIndicatorView.width(40.0)
    activityIndicatorView.height(40.0)
    activityIndicatorView.centerInSuperview()
    self.activityIndicatorView = activityIndicatorView
    
    let database = Firestore.firestore()
    
    query = database.collection(KEY_RECRUITS)
  }
  
  //MARK: Notifications
  private func setupNotifications() {
    ANINotificationManager.receive(logout: self, selector: #selector(reloadRecruitLayout))
    ANINotificationManager.receive(login: self, selector: #selector(reloadRecruitLayout))
    ANINotificationManager.receive(recruitTabTapped: self, selector: #selector(scrollToTop))
    ANINotificationManager.receive(deleteRecruit: self, selector: #selector(deleteRecruit))
  }
  
  @objc private func reloadRecruitLayout() {
    guard let recruitTableView = self.recruitTableView else { return }
    
    for (index, recruit) in recruits.enumerated() {
      var recruitTemp = recruit
      recruitTemp.isLoved = nil
      recruitTemp.isCliped = nil
      recruitTemp.isSupported = nil
      self.recruits[index] = recruitTemp
    }
    
    recruitTableView.reloadData()
  }
  
  @objc private func scrollToTop() {
    guard let recruitTableView = recruitTableView,
          !recruits.isEmpty else { return }
    
    recruitTableView.scrollToRow(at: [0, 0], at: .top, animated: true)
  }
  
  private func setupQuery() {
    guard let recruitTableView = self.recruitTableView else { return }
    
    recruitTableView.alpha = 0.0
    
    let database = Firestore.firestore()

    var queryTemp: Query = database.collection(KEY_RECRUITS)
    
    if let homeFilter = homeFilter {
      queryTemp = queryTemp.whereField(KEY_RECRUIT_HOME, isEqualTo: homeFilter)
    }
    
    if let kindFilter = kindFilter {
      queryTemp = queryTemp.whereField(KEY_RECRUIT_KIND, isEqualTo: kindFilter)
    }
    
    if let ageFilter = ageFilter {
      queryTemp = queryTemp.whereField(KEY_RECRUIT_AGE, isEqualTo: ageFilter)
    }
    
    if let sexFilter = sexFilter {
      queryTemp = queryTemp.whereField(KEY_RECRUIT_SEX, isEqualTo: sexFilter)
    }
    
    query = queryTemp
    
    loadRecruit(sender: nil)
  }
  
  @objc private func deleteRecruit(_ notification: NSNotification) {
    guard let id = notification.object as? String,
          let recruitTableView = self.recruitTableView else { return }

    var indexPath: IndexPath = [0, 0]

    for (index, recruit) in recruits.enumerated() {
      if recruit.id == id {
        recruits.remove(at: index)
        indexPath = [0, index]
      }
    }

    recruitTableView.deleteRows(at: [indexPath], with: .automatic)
  }
  
  private func showReloadView(sender: UIRefreshControl?) {
    guard let activityIndicatorView = self.activityIndicatorView,
          let reloadView = self.reloadView,
          let recruitTableView = self.recruitTableView else { return }

    activityIndicatorView.stopAnimating()
    
    recruitTableView.reloadData()
    
    if let sender = sender {
      sender.endRefreshing()
    }
    
    recruitTableView.alpha = 0.0
    
    UIView.animate(withDuration: 0.2, animations: {
      reloadView.alpha = 1.0
    })
    
    self.isLoading = false
  }
}

//MARK: UITableViewDataSource
extension ANIRecuruitView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recruits.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIRecruitViewCell
    
    if !recruits.isEmpty {
      if users.contains(where: { $0.uid == recruits[indexPath.row].userId }) {
        for user in users {
          if recruits[indexPath.row].userId == user.uid {
            cell.user = user
            break
          }
        }
      } else {
        cell.user = nil
      }
      cell.recruit = recruits[indexPath.row]
      cell.delegate = self
      cell.indexPath = indexPath.row
    }
    
    return cell
  }
}

//MARK: UITableViewDelegate
extension ANIRecuruitView: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ANINotificationManager.postViewScrolled()
    
    //navigation bar animation
    let scrollY = scrollView.contentOffset.y
    self.delegate?.recruitViewDidScroll(scrollY: scrollY)
  }
  
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? ANIRecruitViewCell {
      cell.unobserveLove()
      cell.unobserveSupport()
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let element = self.recruits.count - COUNT_LAST_CELL
    if !isLoading, indexPath.row >= element {
      loadMoreRecruit()
    }
    
    self.cellHeight[indexPath] = cell.frame.size.height
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    if let height = self.cellHeight[indexPath] {
      return height
    } else {
      return UITableView.automaticDimension
    }
  }
}

//MARK: ANIRecruitViewCellDelegate
extension ANIRecuruitView: ANIRecruitViewCellDelegate {
  func cellTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.recruitCellTap(selectedRecruit: recruit, user: user)
  }
  
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser) {
    self.delegate?.supportButtonTapped(supportRecruit: supportRecruit, user: user)
  }
  
  func reject() {
    self.delegate?.reject()
  }
  
  func loadedRecruitIsLoved(indexPath: Int, isLoved: Bool) {
    var recruit = self.recruits[indexPath]
    recruit.isLoved = isLoved
    self.recruits[indexPath] = recruit
  }
  
  func loadedRecruitIsCliped(indexPath: Int, isCliped: Bool) {
    var recruit = self.recruits[indexPath]
    recruit.isCliped = isCliped
    self.recruits[indexPath] = recruit
  }
  
  func loadedRecruitIsSupported(indexPath: Int, isSupported: Bool) {
    var recruit = self.recruits[indexPath]
    recruit.isSupported = isSupported
    self.recruits[indexPath] = recruit
  }
  
  func loadedRecruitUser(user: FirebaseUser) {
    self.users.append(user)
  }
}

//MARK: data
extension ANIRecuruitView {
  @objc private func loadRecruit(sender: UIRefreshControl?) {
    guard let query = self.query,
          let activityIndicatorView = self.activityIndicatorView,
          let reloadView = self.reloadView,
          let recruitTableView = self.recruitTableView else { return }
    
    reloadView.alpha = 0.0
    
    if !self.recruits.isEmpty {
      self.recruits.removeAll()
    }
    if !self.users.isEmpty {
      self.users.removeAll()
    }
    
    if sender == nil {
      activityIndicatorView.startAnimating()
    }
    
    DispatchQueue.global().async {
      self.isLoading = true
      self.isLastRecruitPage = false

      query.order(by: KEY_DATE, descending: true).limit(to: 15).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          self.isLoading = false

          return
        }
        
        guard let snapshot = snapshot,
              let lastRecruit = snapshot.documents.last else {
                if !self.recruits.isEmpty {
                  self.recruits.removeAll()
                }
                
                self.isLoading = false
                
                self.showReloadView(sender: sender)
                return }
        
        self.lastRecruit = lastRecruit
        
        for document in snapshot.documents {
          do {
            let recruit = try FirestoreDecoder().decode(FirebaseRecruit.self, from: document.data())
            self.recruits.append(recruit)

            DispatchQueue.main.async {
              if let sender = sender {
                sender.endRefreshing()
              }
              
              activityIndicatorView.stopAnimating()
              
              recruitTableView.reloadData()
              
              UIView.animate(withDuration: 0.2, animations: {
                recruitTableView.alpha = 1.0
              })
              
              self.isLoading = false
            }
          } catch let error {
            DLog(error)
            
            activityIndicatorView.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: {
              reloadView.alpha = 1.0
            })

            if let sender = sender {
              sender.endRefreshing()
            }
            
            self.isLoading = false
          }
        }
      })
    }
  }
  
  private func loadMoreRecruit() {
    guard let query = self.query,
          let recruitTableView = self.recruitTableView,
          let lastRecruit = self.lastRecruit,
          !isLoading,
          !isLastRecruitPage else { return }
    
    DispatchQueue.global().async {
      self.isLoading = true
      
      query.order(by: KEY_DATE, descending: true).start(afterDocument: lastRecruit).limit(to: 15).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          self.isLoading = false

          return
        }
        
        guard let snapshot = snapshot else { return }
        guard let lastRecruit = snapshot.documents.last else {
          self.isLastRecruitPage = true
          self.isLoading = false
          return
        }
        
        self.lastRecruit = lastRecruit
        
        for (index, document) in snapshot.documents.enumerated() {
          do {
            let recruit = try FirestoreDecoder().decode(FirebaseRecruit.self, from: document.data())
            self.recruits.append(recruit)
            
            DispatchQueue.main.async {
              if index + 1 == snapshot.documents.count {
                recruitTableView.reloadData()
                
                self.isLoading = false
              }
            }
          } catch let error {
            DLog(error)
            self.isLoading = false
          }
        }
      })
    }
  }
}


//MARK: ANIReloadViewDelegate
extension ANIRecuruitView: ANIReloadViewDelegate {
  func reloadButtonTapped() {
    loadRecruit(sender: nil)
  }
}
