//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

protocol ANIStoryViewDelegate {
  func storyViewCellDidSelect(selectedStory: FirebaseStory)
}

class ANIStoryView: UIView {
  
  var storyTableView: UITableView?
  
  var storys = [FirebaseStory]()
  
  var delegate: ANIStoryViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadStory()
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let window = UIApplication.shared.keyWindow
    var bottomSafeArea: CGFloat = 0.0
    if let windowUnrap = window {
      bottomSafeArea = windowUnrap.safeAreaInsets.bottom
    }
    let tableView = UITableView()
    tableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: UIViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    let id = NSStringFromClass(ANIStoryViewCell.self)
    tableView.register(ANIStoryViewCell.self, forCellReuseIdentifier: id)
    tableView.separatorStyle = .none
    tableView.dataSource = self
    tableView.delegate = self
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.storyTableView = tableView
  }
  
  private func loadStory() {
    DispatchQueue.global().async {
      Database.database().reference().child(KEY_STORIES).observe(.childAdded, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
          let story = try FirebaseDecoder().decode(FirebaseStory.self, from: value)
          self.storys.insert(story, at: 0)
          
          DispatchQueue.main.async {
            guard let storyTableView = self.storyTableView else { return }
            storyTableView.reloadData()
          }
        } catch let error {
          print(error)
        }
      })
    }
  }
}

//MARK: UITableViewDataSource
extension ANIStoryView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return storys.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIStoryViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIStoryViewCell
    
    cell.story = storys[indexPath.row]

    return cell
  }
}

//MARK: UITableViewDelegate
extension ANIStoryView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.delegate?.storyViewCellDidSelect(selectedStory: storys[indexPath.row])
  }
}
