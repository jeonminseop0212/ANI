//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIStoryViewDelegate {
  func storyViewCellDidSelect(index: Int)
}

class ANIStoryView: UIView {
  
  var storyTableView: UITableView?
  
  var storys = [Story]() {
    didSet {
      guard let storyTableView = self.storyTableView else { return }
      storyTableView.reloadData()
    }
  }
  
  var delegate: ANIStoryViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
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
    self.delegate?.storyViewCellDidSelect(index: indexPath.row)
  }
}
