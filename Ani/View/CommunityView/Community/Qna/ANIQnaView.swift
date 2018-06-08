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

protocol ANIQnaViewDelegate {
  func qnaViewCellDidSelect(selectedQna: FirebaseQna)
}

class ANIQnaView: UIView {
  
  var qnaTableView: UITableView?
  
  var qnas = [FirebaseQna]()
  
  var delegate: ANIQnaViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadQna()
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
    tableView.contentInset = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    tableView.scrollIndicatorInsets  = UIEdgeInsets(top: ANICommunityViewController.NAVIGATION_BAR_HEIGHT, left: 0, bottom: ANICommunityViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT + bottomSafeArea, right: 0)
    tableView.backgroundColor = ANIColor.bg
    let id = NSStringFromClass(ANIQnaViewCell.self)
    tableView.register(ANIQnaViewCell.self, forCellReuseIdentifier: id)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    addSubview(tableView)
    tableView.edgesToSuperview()
    self.qnaTableView = tableView
  }
  
  private func loadQna() {
    DispatchQueue.global().async {
      Database.database().reference().child(KEY_QNAS).observe(.childAdded, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
          let qna = try FirebaseDecoder().decode(FirebaseQna.self, from: value)
          self.qnas.insert(qna, at: 0)
          
          DispatchQueue.main.async {
            guard let qnaTableView = self.qnaTableView else { return }
            qnaTableView.reloadData()
          }
        } catch let error {
          print(error)
        }
      })
    }
  }
}

//MARK: UITableViewDataSource
extension ANIQnaView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return qnas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = NSStringFromClass(ANIQnaViewCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ANIQnaViewCell

    cell.qna = qnas[indexPath.row]
    cell.observeQna()
    
    return cell
  }
}

//MARK: UITableViewDelegate
extension ANIQnaView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.delegate?.qnaViewCellDidSelect(selectedQna: qnas[indexPath.row])
  }
}
