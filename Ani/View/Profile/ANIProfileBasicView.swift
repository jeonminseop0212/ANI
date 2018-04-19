//
//  ANIProfileBasicView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIProfileBasicView: UIView {
  
  enum ContentType:Int { case profile; case recruit; case love; case clip;}
  private var contentType:ContentType = .profile

  private weak var basicTableView: UITableView?
  
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
    let topCellId = NSStringFromClass(ANIProfileTopCell.self)
    basicTableView.register(ANIProfileTopCell.self, forCellReuseIdentifier: topCellId)
    let profileCellid = NSStringFromClass(ANIProfileProfileCell.self)
    basicTableView.register(ANIProfileProfileCell.self, forCellReuseIdentifier: profileCellid)
    let recruitCellid = NSStringFromClass(ANIProfileRecruitCell.self)
    basicTableView.register(ANIProfileRecruitCell.self, forCellReuseIdentifier: recruitCellid)
    let loveCellid = NSStringFromClass(ANIProfileLoveCell.self)
    basicTableView.register(ANIProfileLoveCell.self, forCellReuseIdentifier: loveCellid)
    let clipCellid = NSStringFromClass(ANIProfileClipCell.self)
    basicTableView.register(ANIProfileClipCell.self, forCellReuseIdentifier: clipCellid)
    addSubview(basicTableView)
    basicTableView.edgesToSuperview()
    self.basicTableView = basicTableView
  }
}

extension ANIProfileBasicView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else {
      return 1
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section

    if section == 0 {
      let topCellId = NSStringFromClass(ANIProfileTopCell.self)
      let cell = tableView.dequeueReusableCell(withIdentifier: topCellId, for: indexPath) as! ANIProfileTopCell
      return cell
    } else {
      if contentType == .profile {
        let profileCellid = NSStringFromClass(ANIProfileProfileCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCellid, for: indexPath) as! ANIProfileProfileCell
        return cell
      } else if contentType == .recruit {
        let recruitCellid = NSStringFromClass(ANIProfileRecruitCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: recruitCellid, for: indexPath) as! ANIProfileRecruitCell
        return cell
      } else if contentType == .love {
        let loveCellid = NSStringFromClass(ANIProfileLoveCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: loveCellid, for: indexPath) as! ANIProfileLoveCell
        return cell
      } else {
        let clipCellid = NSStringFromClass(ANIProfileClipCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: clipCellid, for: indexPath) as! ANIProfileClipCell
        return cell
      }
    }
  }
}
