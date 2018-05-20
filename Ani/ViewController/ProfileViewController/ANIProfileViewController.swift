//
//  ANIProfileViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIProfileViewController: UIViewController {
  
  private weak var profileBasicView: ANIProfileBasicView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    setupNotification()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
  }
  
  private func setup() {
    //basic
    Orientation.lockOrientation(.portrait)
    self.view.backgroundColor = .white
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationItem.title = "PROFILE"
    self.navigationController?.navigationBar.tintColor = ANIColor.dark
    
    //profileBasicView
    let profileBasicView = ANIProfileBasicView()
    self.view.addSubview(profileBasicView)
    profileBasicView.edgesToSuperview()
    self.profileBasicView = profileBasicView
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(imageCellTapped: self, selector: #selector(presentImageBrowser(_:)))
    ANINotificationManager.receive(profileEditButtonTapped: self, selector: #selector(openProfileEdit))
  }
  
  //MARK: action
  @objc private func presentImageBrowser(_ notification: NSNotification) {
    guard let item = notification.object as? (Int, [UIImage?]) else { return }
    let selectedIndex = item.0
    let images = item.1
    let imageBrowserViewController = ANIImageBrowserViewController()
    imageBrowserViewController.selectedIndex = selectedIndex
    imageBrowserViewController.images = images
    imageBrowserViewController.modalPresentationStyle = .overCurrentContext
    //overCurrentContextだとtabBarが消えないのでtabBarからpresentする
    self.tabBarController?.present(imageBrowserViewController, animated: false, completion: nil)
  }
  
  @objc private func openProfileEdit() {
    guard let profileBasicView = self.profileBasicView else { return }
    
    let profileEditViewController = ANIProfileEditViewController()
    profileEditViewController.user = profileBasicView.user
    self.present(profileEditViewController, animated: true, completion: nil)
  }
}
