//
//  ANIProfileView.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIProfileProfileCell: UICollectionViewCell {
  
  private weak var profileTableView: UITableView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = .yellow
    //profileTableView
    let profileTableView = UITableView()
    profileTableView.separatorStyle = .none
    profileTableView.backgroundColor = .white
    profileTableView.dataSource = self
    profileTableView.delegate = self
    let id = NSStringFromClass(profileTableViewCell.self)
    profileTableView.register(profileTableViewCell.self, forCellReuseIdentifier: id)
    addSubview(profileTableView)
    profileTableView.edgesToSuperview()
    self.profileTableView = profileTableView
  }
}

extension ANIProfileProfileCell: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(profileTableViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! profileTableViewCell
    return cell
  }
}
