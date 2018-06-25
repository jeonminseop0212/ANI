//
//  ANIOptionView.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/22.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIOptionViewDelegate {
  func listTapped(list: List)
  func logoutTapped()
}

enum List: String {
  case loveRecruit = "『いいね』した募集";
  case loveStroy = "『いいね』したストーリ";
  case loveQuestion = "『いいね』した質問";
  case clipRecruit = "『クリップ』した募集";
}

class ANIOptionView: UIView {
  
  private weak var tableView: UITableView?
  
  private var list = [List.loveRecruit, List.loveStroy, List.loveQuestion, List.clipRecruit]
  private var account = ["ログアウト"]
  
  var delegate: ANIOptionViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let tableView = UITableView()
    let id = NSStringFromClass(ANIOptionViewCell.self)
    tableView.register(ANIOptionViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.delegate = self
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.tableView = tableView
  }
}

//MARK: UITableViewDataSource
extension ANIOptionView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return list.count
    case 1:
      return account.count
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIOptionViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIOptionViewCell
    
    switch indexPath.section {
    case 0:
      cell.titleLabel?.text = list[indexPath.row].rawValue
    case 1:
      cell.titleLabel?.text = account[indexPath.row]
    default:
      cell.titleLabel?.text = ""
    }
    
    return cell
  }
}

//MARK: UITableViewDelegate
extension ANIOptionView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    headerView.backgroundColor = ANIColor.bg
    
    let titleLabel = UILabel()
    titleLabel.textColor = ANIColor.dark
    titleLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
    headerView.addSubview(titleLabel)
    let insets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: -10)
    titleLabel.edgesToSuperview(insets: insets)
    
    switch section {
    case 0:
      titleLabel.text = "リスト"
    case 1:
      titleLabel.text = "アカウント"
    default:
      titleLabel.text = ""
    }
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case 0:
      self.delegate?.listTapped(list: list[indexPath.row])
    case 1:
      if account[indexPath.row] == "ログアウト" {
        self.delegate?.logoutTapped()
      }
    default:
      print("default")
    }
  }
}
