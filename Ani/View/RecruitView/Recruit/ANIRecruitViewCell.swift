//
//  ANIRecruitViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import WCLShineButton
import FirebaseDatabase
import CodableFirebase

protocol ANIRecruitViewCellDelegate {
  func cellTapped(recruit: FirebaseRecruit, user: FirebaseUser)
}

class ANIRecruitViewCell: UITableViewCell {
  private weak var tapArea: UIView?
  private weak var recruitImageView: UIImageView?
  private weak var basicInfoStackView: UIStackView?
  private weak var isRecruitLabel: UILabel?
  private weak var homeLabel: UILabel?
  private weak var ageLabel: UILabel?
  private weak var sexLabel: UILabel?
  private weak var titleLabel: UILabel?
  private weak var subTitleLabel: UILabel?
  private let PROFILE_IMAGE_HEIGHT: CGFloat = 32.0
  private weak var profileImageView: UIImageView?
  private weak var userNameLabel: UILabel?
  private weak var supportCountLabel: UILabel?
  private weak var supportButton: UIButton?
  private weak var loveButton: WCLShineButton?
  private weak var loveCountLabel: UILabel?
  private weak var clipButton: UIButton?
  private weak var line: UIImageView?
  
  var recruit: FirebaseRecruit? {
    didSet {
      reloadLayout()
      loadUser()
      isLoved()
      observeLove()
    }
  }
  
  var user: FirebaseUser?
  
  var delegate: ANIRecruitViewCellDelegate?
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    self.backgroundColor = .white
    
    //tapArea
    let tapArea = UIView()
    let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
    tapArea.addGestureRecognizer(cellTapGesture)
    addSubview(tapArea)
    tapArea.edgesToSuperview(excluding: .bottom)
    self.tapArea = tapArea
    
    //recruitImageView
    let recruitImageView = UIImageView()
    recruitImageView.backgroundColor = ANIColor.bg
    recruitImageView.contentMode = .redraw
    tapArea.addSubview(recruitImageView)
    let recruitImageViewHeight: CGFloat = UIScreen.main.bounds.width * UIViewController.HEADER_IMAGE_VIEW_RATIO
    recruitImageView.topToSuperview()
    recruitImageView.leftToSuperview()
    recruitImageView.rightToSuperview()
    recruitImageView.height(recruitImageViewHeight)
    self.recruitImageView = recruitImageView
    
    //basicInfoStackView
    let basicInfoStackView = UIStackView()
    basicInfoStackView.axis = .horizontal
    basicInfoStackView.distribution = .fillEqually
    basicInfoStackView.alignment = .center
    basicInfoStackView.spacing = 8.0
    tapArea.addSubview(basicInfoStackView)
    basicInfoStackView.topToBottom(of: recruitImageView, offset: 10.0)
    basicInfoStackView.leftToSuperview(offset: 10.0)
    basicInfoStackView.rightToSuperview(offset: 10.0)
    self.basicInfoStackView = basicInfoStackView
    
    //isRecruitLabel
    let isRecruitLabel = UILabel()
    isRecruitLabel.textColor = .white
    isRecruitLabel.textAlignment = .center
    isRecruitLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
    isRecruitLabel.layer.cornerRadius = 5.0
    isRecruitLabel.layer.masksToBounds = true
    isRecruitLabel.backgroundColor = ANIColor.green
    basicInfoStackView.addArrangedSubview(isRecruitLabel)
    isRecruitLabel.height(24.0)
    self.isRecruitLabel = isRecruitLabel
    
    //homeLabel
    let homeLabel = UILabel()
    homeLabel.textColor = ANIColor.darkGray
    homeLabel.textAlignment = .center
    homeLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
    homeLabel.layer.cornerRadius = 5.0
    homeLabel.layer.masksToBounds = true
    homeLabel.layer.borderColor = ANIColor.darkGray.cgColor
    homeLabel.layer.borderWidth = 1.2
    basicInfoStackView.addArrangedSubview(homeLabel)
    homeLabel.height(24.0)
    self.homeLabel = homeLabel
    
    //ageLabel
    let ageLabel = UILabel()
    ageLabel.textColor = ANIColor.darkGray
    ageLabel.textAlignment = .center
    ageLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
    ageLabel.layer.cornerRadius = 5.0
    ageLabel.layer.masksToBounds = true
    ageLabel.layer.borderColor = ANIColor.darkGray.cgColor
    ageLabel.layer.borderWidth = 1.2
    basicInfoStackView.addArrangedSubview(ageLabel)
    ageLabel.height(24.0)
    self.ageLabel = ageLabel
    
    //sexLabel
    let sexLabel = UILabel()
    sexLabel.textColor = ANIColor.darkGray
    sexLabel.textAlignment = .center
    sexLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
    sexLabel.layer.cornerRadius = 5.0
    sexLabel.layer.masksToBounds = true
    sexLabel.layer.borderColor = ANIColor.darkGray.cgColor
    sexLabel.layer.borderWidth = 1.2
    basicInfoStackView.addArrangedSubview(sexLabel)
    sexLabel.height(24.0)
    self.sexLabel = sexLabel
    
    //titleLabel
    let titleLabel = UILabel()
    titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    titleLabel.textAlignment = .left
    titleLabel.textColor = ANIColor.dark
    tapArea.addSubview(titleLabel)
    titleLabel.topToBottom(of: basicInfoStackView, offset: 10.0)
    titleLabel.leftToSuperview(offset: 10.0)
    titleLabel.rightToSuperview(offset: 10.0)
    titleLabel.height(20.0)
    self.titleLabel = titleLabel
    
    //subTitleLabel
    let subTitleLabel = UILabel()
    subTitleLabel.numberOfLines = 3
    subTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
    subTitleLabel.textColor = ANIColor.subTitle
    tapArea.addSubview(subTitleLabel)
    subTitleLabel.topToBottom(of: titleLabel, offset: 10.0)
    subTitleLabel.leftToSuperview(offset: 10.0)
    subTitleLabel.rightToSuperview(offset: 10.0)
    self.subTitleLabel = subTitleLabel
    
    tapArea.bottom(to: subTitleLabel)
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.isUserInteractionEnabled = true
    let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
    profileImageView.addGestureRecognizer(profileImageTapGesture)
    profileImageView.backgroundColor = ANIColor.bg
    addSubview(profileImageView)
    profileImageView.topToBottom(of: tapArea, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(PROFILE_IMAGE_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_HEIGHT)
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    self.profileImageView = profileImageView
    
    //clipButton
    let clipButton = UIButton()
    clipButton.setImage(UIImage(named: "clip"), for: .normal)
    addSubview(clipButton)
    clipButton.centerY(to: profileImageView)
    clipButton.rightToSuperview(offset: 20.0)
    clipButton.width(21.0)
    clipButton.height(21.0)
    self.clipButton = clipButton
    
    //loveCountLabel
    let loveCountLabel = UILabel()
    loveCountLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
    loveCountLabel.textColor = ANIColor.dark
    addSubview(loveCountLabel)
    loveCountLabel.centerY(to: profileImageView)
    loveCountLabel.rightToLeft(of: clipButton, offset: -10.0)
    loveCountLabel.width(30.0)
    loveCountLabel.height(20.0)
    self.loveCountLabel = loveCountLabel
    
    //loveButton
    var param = WCLShineParams()
    param.bigShineColor = ANIColor.red
    param.smallShineColor = ANIColor.pink
    let loveButton = WCLShineButton(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0), params: param)
    loveButton.fillColor = ANIColor.red
    loveButton.color = ANIColor.gray
    loveButton.image = .heart
    loveButton.addTarget(self, action: #selector(love), for: .valueChanged)
    addSubview(loveButton)
    loveButton.centerY(to: profileImageView)
    loveButton.rightToLeft(of: loveCountLabel, offset: -10.0)
    loveButton.width(20.0)
    loveButton.height(20.0)
    self.loveButton = loveButton
    
    //supportCountLabel
    let supportCountLabel = UILabel()
    supportCountLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
    supportCountLabel.textColor = ANIColor.dark
    addSubview(supportCountLabel)
    supportCountLabel.centerY(to: profileImageView)
    supportCountLabel.rightToLeft(of: loveButton, offset: -10.0)
    supportCountLabel.width(30.0)
    supportCountLabel.height(20.0)
    self.supportCountLabel = supportCountLabel
    
    //supportButton
    let supportButton = UIButton()
    supportButton.setImage(UIImage(named: "support"), for: .normal)
    addSubview(supportButton)
    supportButton.centerY(to: profileImageView)
    supportButton.rightToLeft(of: supportCountLabel, offset: -10.0)
    supportButton.width(21.0)
    supportButton.height(21.0)
    self.supportButton = supportButton
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.font = UIFont.systemFont(ofSize: 13.0)
    userNameLabel.textColor = ANIColor.subTitle
    addSubview(userNameLabel)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToLeft(of: supportButton, offset: 10.0)
    userNameLabel.centerY(to: profileImageView)
    userNameLabel.height(20.0)
    self.userNameLabel = userNameLabel
    
    //line
    let line = UIImageView()
    line.image = UIImage(named: "line")
    addSubview(line)
    line.topToBottom(of: profileImageView, offset: 10.0)
    line.leftToSuperview()
    line.rightToSuperview()
    line.height(0.5)
    line.bottomToSuperview()
    self.line = line
  }
  
  private func reloadLayout() {
    guard let recruitImageView = self.recruitImageView,
          let isRecruitLabel = self.isRecruitLabel,
          let homeLabel = self.homeLabel,
          let ageLabel = self.ageLabel,
          let sexLabel = self.sexLabel,
          let titleLabel = self.titleLabel,
          let subTitleLabel = self.subTitleLabel,
          let supportCountLabel = self.supportCountLabel,
          let loveButton = self.loveButton,
          let loveCountLabel = self.loveCountLabel,
          let recruit = self.recruit,
          let headerImageUrl = recruit.headerImageUrl else { return }
    
    recruitImageView.sd_setImage(with: URL(string: headerImageUrl), completed: nil)
    isRecruitLabel.text = recruit.isRecruit ? "募集中" : "決まり！"
    homeLabel.text = recruit.home
    ageLabel.text = recruit.age
    sexLabel.text = recruit.sex
    titleLabel.text = recruit.title
    subTitleLabel.text = recruit.reason
    supportCountLabel.text = "\(recruit.supportCount)"
    loveButton.isSelected = false
    if let loveIds = recruit.loveIds {
      loveCountLabel.text = "\(loveIds.count)"
    } else {
      loveCountLabel.text = "0"
    }
  }
  
  private func reloadUserLayout(user: FirebaseUser) {
    guard let userNameLabel = self.userNameLabel,
          let profileImageView = self.profileImageView,
          let profileImageUrl = user.profileImageUrl,
          let userName = user.userName else { return }
    
    profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    userNameLabel.text = userName
  }
  
  private func loadUser() {
    guard let recruit = self.recruit else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_USERS).child(recruit.userId).observeSingleEvent(of: .value, with: { (userSnapshot) in
        if let userValue = userSnapshot.value {
          do {
            let user = try FirebaseDecoder().decode(FirebaseUser.self, from: userValue)
            self.user = user
            
            DispatchQueue.main.async {
              self.reloadUserLayout(user: user)
            }
          } catch let error {
            print(error)
          }
        }
      })
    }
  }
  
  private func observeLove() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id else { return }
    
    let databaseRef = Database.database().reference()
    DispatchQueue.global().async {
      databaseRef.child(KEY_RECRUITS).child(recuritId).child(KEY_LOVE_IDS).observe(.value) { (snapshot) in
        if let loveIds = snapshot.value as? [String: AnyObject] {
          DispatchQueue.main.async {
            guard let loveCountLabel = self.loveCountLabel else { return }
            
            loveCountLabel.text = "\(loveIds.count)"
          }
        } else {
          DispatchQueue.main.async {
            guard let loveCountLabel = self.loveCountLabel else { return }
            
            loveCountLabel.text = "0"
          }
        }
      }
    }
  }
  
  private func isLoved() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUserId = ANISessionManager.shared.currentUserUid else { return }
    
    let databaseRef = Database.database().reference()
    DispatchQueue.global().async {
      databaseRef.child(KEY_RECRUITS).child(recuritId).child(KEY_LOVE_IDS).observeSingleEvent(of: .value) { (snapshot) in
        for item in snapshot.children {
          if let snapshot = item as? DataSnapshot {
            if snapshot.key == currentUserId {
              DispatchQueue.main.async {
                guard let loveButton = self.loveButton else { return }
                
                loveButton.isSelected = true
              }
            }
          }
        }
      }
    }
  }
  
  //MARK: action
  @objc private func love() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let loveButton = self.loveButton else { return }
    
    let databaseRef = Database.database().reference()
    if loveButton.isSelected == true {
      DispatchQueue.global().async {
        databaseRef.child(KEY_RECRUITS).child(recuritId).child(KEY_LOVE_IDS).updateChildValues([currentUserId: true])
        databaseRef.child(KEY_USERS).child(currentUserId).child(KEY_LOVE_RECRUIT_IDS).updateChildValues([recuritId: true])
      }
    } else {
      DispatchQueue.global().async {
        databaseRef.child(KEY_RECRUITS).child(recuritId).child(KEY_LOVE_IDS).child(currentUserId).removeValue()
        databaseRef.child(KEY_USERS).child(currentUserId).child(KEY_LOVE_RECRUIT_IDS).child(recuritId).removeValue()
      }
    }
  }
  
  @objc private func profileImageViewTapped() {
    guard let recruit = self.recruit else { return }
    
    ANINotificationManager.postProfileImageViewTapped(userId: recruit.userId)
  }
  
  @objc private func cellTapped() {
    guard let recruit = self.recruit,
          let user = self.user else { return }
    
    self.delegate?.cellTapped(recruit: recruit, user: user)
  }
}
