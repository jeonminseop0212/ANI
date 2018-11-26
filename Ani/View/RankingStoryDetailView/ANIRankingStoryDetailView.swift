//
//  ANIRankingStoryDetailView.swift
//  Ani
//
//  Created by jeonminseop on 2018/11/26.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIRankingStoryDetailViewDelegate {
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser)
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String)
  func reject()
}

class ANIRankingStoryDetailView: UIView {
  
  private weak var rankingStoryTableView: UITableView?
  
  var stroy: FirebaseStory? {
    didSet {
      guard let rankingStoryTableView = self.rankingStoryTableView else { return }
      
      rankingStoryTableView.reloadData()
    }
  }
  
  var delegate: ANIRankingStoryDetailViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //basic
    self.backgroundColor = .white
    
    //rankingStoryTableView
    let rankingStoryTableView = UITableView()
    rankingStoryTableView.separatorStyle = .none
    rankingStoryTableView.backgroundColor = ANIColor.bg
    let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
    rankingStoryTableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: storyCellId)
    rankingStoryTableView.rowHeight = UITableView.automaticDimension
    rankingStoryTableView.dataSource = self
    addSubview(rankingStoryTableView)
    rankingStoryTableView.edgesToSuperview()
    self.rankingStoryTableView = rankingStoryTableView
  }
}

//MARK: UITableViewDataSource
extension ANIRankingStoryDetailView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let storyCellId = NSStringFromClass(ANIStoryViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: storyCellId, for: indexPath) as! ANIStoryViewCell

    cell.indexPath = indexPath.row
    cell.story = stroy
    cell.delegate = self
    
    return cell
  }
}

//MARK: ANIStoryViewCellDelegate
extension ANIRankingStoryDetailView: ANIStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser) {
    self.delegate?.storyViewCellDidSelect(selectedStory: story, user: user)
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.delegate?.popupOptionView(isMe: isMe, contentType: contentType, id: id)
  }
  
  func loadedStoryIsLoved(indexPath: Int, isLoved: Bool) {
  }
  
  func loadedStoryUser(user: FirebaseUser) {
  }
  
  func reject() {
    self.delegate?.reject()
  }
}