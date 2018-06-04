//
//  ANIRecuruitView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIRecruitViewDelegate {
  func recruitRowTap(tapRowIndex: Int)
  func recruitViewDidScroll(scrollY: CGFloat)
}

class ANIRecuruitView: UIView {

  private weak var recruitTableView: UITableView? {
    didSet {
      guard let recruitTableView = self.recruitTableView else { return }
      let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT
      recruitTableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    }
  }
  
  var recruits = [Recruit]() {
    didSet {
      guard let recruitTableView = self.recruitTableView else { return }
      recruitTableView.reloadData()
    }
  }

  var delegate:ANIRecruitViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let tableView = UITableView()
    tableView.separatorStyle = .none
    let topInset = UIViewController.NAVIGATION_BAR_HEIGHT + ANIRecruitViewController.CATEGORIES_VIEW_HEIGHT
    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    tableView.backgroundColor = .white
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    tableView.register(ANIRecruitViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.delegate = self
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.recruitTableView = tableView
  }
}

extension ANIRecuruitView: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recruits.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIRecruitViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIRecruitViewCell
    
    cell.recruit = recruits[indexPath.row]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.delegate?.recruitRowTap(tapRowIndex: indexPath.row)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ANINotificationManager.postViewScrolled()
    
    //navigation bar animation
    let scrollY = scrollView.contentOffset.y
    self.delegate?.recruitViewDidScroll(scrollY: scrollY)
  }
}
