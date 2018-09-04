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

  private weak var recruitTableView: UITableView? {
    didSet {
      guard let recruitTableView = self.recruitTableView else { return }
      let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.FILTERS_VIEW_HEIGHT
      recruitTableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    }
  }
  
  private var recruits = [FirebaseRecruit]()
  
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
    //recruitTableView
    let tableView = UITableView()
    tableView.separatorStyle = .none
    let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.FILTERS_VIEW_HEIGHT
    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.backgroundColor = ANIColor.bg
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    tableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.delegate = self
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(loadRecruit(sender:)), for: .valueChanged)
    tableView.alpha = 0.0
    tableView.addSubview(refreshControl)
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.recruitTableView = tableView
    
    //activityIndicatorView
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: ANIColor.green, padding: 0)
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
    ANINotificationManager.receive(logout: self, selector: #selector(reloadRecruit))
    ANINotificationManager.receive(login: self, selector: #selector(reloadRecruit))
    ANINotificationManager.receive(recruitTabTapped: self, selector: #selector(scrollToTop))
    ANINotificationManager.receive(deleteRecruit: self, selector: #selector(deleteRecruit))
  }
  
  @objc private func reloadRecruit() {
    loadRecruit(sender: nil)
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
      cell.recruit = recruits[indexPath.row]
      cell.delegate = self
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
}

//MARK: data
extension ANIRecuruitView {
  @objc private func loadRecruit(sender: UIRefreshControl?) {
    guard let query = self.query,
          let activityIndicatorView = self.activityIndicatorView else { return }
    
    if !self.recruits.isEmpty {
      self.recruits.removeAll()
    }
    
    if sender == nil {
      activityIndicatorView.startAnimating()
    }
    
    DispatchQueue.global().async {
      query.order(by: KEY_DATE, descending: true).limit(to: 20).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")

          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          do {
            let recruit = try FirestoreDecoder().decode(FirebaseRecruit.self, from: document.data())
            self.recruits.append(recruit)

            DispatchQueue.main.async {
              if let sender = sender {
                sender.endRefreshing()
              }

              guard let recruitTableView = self.recruitTableView else { return }
              
              activityIndicatorView.stopAnimating()
              
              recruitTableView.reloadData()
              
              UIView.animate(withDuration: 0.2, animations: {
                recruitTableView.alpha = 1.0
              })
            }
          } catch let error {
            print(error)
            
            activityIndicatorView.stopAnimating()

            if let sender = sender {
              sender.endRefreshing()
            }
          }
        }
        
        if snapshot.documents.isEmpty {
          guard let recruitTableView = self.recruitTableView else { return }
          
          activityIndicatorView.stopAnimating()
          
          recruitTableView.reloadData()
          
          if let sender = sender {
            sender.endRefreshing()
          }
        }
      })
    }
  }
}
