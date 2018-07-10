//
//  ANISupportViewCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/20.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import WCLShineButton
import FirebaseDatabase
import CodableFirebase

protocol ANISupportViewCellDelegate {
  func supportCellTapped(story: FirebaseStory, user: FirebaseUser)
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func reject()
}

class ANISupportViewCell: UITableViewCell {
  
  private weak var messageLabel: UILabel?
  
  private weak var recruitBase: UIView?
  private weak var recruitImageView: UIImageView?
  private weak var basicInfoStackView: UIStackView?
  private weak var isRecruitLabel: UILabel?
  private weak var homeLabel: UILabel?
  private weak var ageLabel: UILabel?
  private weak var sexLabel: UILabel?
  private weak var titleLabel: UILabel?
  private weak var subTitleLabel: UILabel?
  
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 32.0
  private weak var profileImageView: UIImageView?
  private weak var userNameLabel: UILabel?
  private weak var loveButtonBG: UIView?
  private weak var loveButton: WCLShineButton?
  private weak var loveCountLabel: UILabel?
  private weak var commentButton: UIButton?
  private weak var commentCountLabel: UILabel?
  private weak var line: UIImageView?
  
  var delegate: ANISupportViewCellDelegate?
  
  var story: FirebaseStory? {
    didSet {
      reloadLayout()
      loadRecruit()
      loadUser()
      isLoved()
      observeLove()
    }
  }
  
  private var recruit: FirebaseRecruit? {
    didSet {
      loadRecruitUser()
    }
  }
  
  private var user: FirebaseUser?

  private var recruitUser: FirebaseUser?
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    self.backgroundColor = ANIColor.bg
    
    //messageLabel
    let messageLabel = UILabel()
    messageLabel.font = UIFont.systemFont(ofSize: 16.0)
    messageLabel.textAlignment = .left
    messageLabel.textColor = ANIColor.subTitle
    messageLabel.numberOfLines = 0
    messageLabel.isUserInteractionEnabled = true
    let labelTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
    messageLabel.addGestureRecognizer(labelTapGesture)
    addSubview(messageLabel)
    messageLabel.topToSuperview(offset: 10.0)
    messageLabel.leftToSuperview(offset: 10.0)
    messageLabel.rightToSuperview(offset: 10.0)
    self.messageLabel = messageLabel
    
    //recruitBase
    let recruitBase = UIView()
    recruitBase.backgroundColor = .white
    recruitBase.layer.cornerRadius = 10.0
    recruitBase.layer.masksToBounds = true
    recruitBase.isUserInteractionEnabled = true
    let recruitTapGesture = UITapGestureRecognizer(target: self, action: #selector(recruitTapped))
    recruitBase.addGestureRecognizer(recruitTapGesture)
    addSubview(recruitBase)
    recruitBase.topToBottom(of: messageLabel, offset: 10.0)
    recruitBase.leftToSuperview(offset: 10.0)
    recruitBase.rightToSuperview(offset: 10.0)
    self.recruitBase = recruitBase
    
    //recruitImageView
    let recruitImageView = UIImageView()
    recruitImageView.backgroundColor = .white
    recruitImageView.contentMode = .redraw
    recruitBase.addSubview(recruitImageView)
    let recruitImageViewHeight: CGFloat = (UIScreen.main.bounds.width - 20) * UIViewController.HEADER_IMAGE_VIEW_RATIO
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
    recruitBase.addSubview(basicInfoStackView)
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
    titleLabel.numberOfLines = 0
    recruitBase.addSubview(titleLabel)
    titleLabel.topToBottom(of: basicInfoStackView, offset: 10.0)
    titleLabel.leftToSuperview(offset: 10.0)
    titleLabel.rightToSuperview(offset: 10.0)
    self.titleLabel = titleLabel
    
    //subTitleLabel
    let subTitleLabel = UILabel()
    subTitleLabel.numberOfLines = 3
    subTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
    subTitleLabel.textColor = ANIColor.subTitle
    recruitBase.addSubview(subTitleLabel)
    subTitleLabel.topToBottom(of: titleLabel, offset: 10.0)
    subTitleLabel.leftToSuperview(offset: 10.0)
    subTitleLabel.rightToSuperview(offset: 10.0)
    subTitleLabel.bottomToSuperview(offset: -10)
    self.subTitleLabel = subTitleLabel
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.backgroundColor = ANIColor.bg
    profileImageView.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
    profileImageView.addGestureRecognizer(tapGesture)
    addSubview(profileImageView)
    profileImageView.topToBottom(of: recruitBase, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    self.profileImageView = profileImageView
    
    //commentCountLabel
    let commentCountLabel = UILabel()
    commentCountLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
    commentCountLabel.textColor = ANIColor.dark
    addSubview(commentCountLabel)
    commentCountLabel.centerY(to: profileImageView)
    commentCountLabel.rightToSuperview(offset: 20.0)
    commentCountLabel.width(30.0)
    commentCountLabel.height(20.0)
    self.commentCountLabel = commentCountLabel
    
    //commentButton
    let commentButton = UIButton()
    commentButton.setImage(UIImage(named: "comment"), for: .normal)
    commentButton.addTarget(self, action: #selector(cellTapped), for: .touchUpInside)
    addSubview(commentButton)
    commentButton.centerY(to: profileImageView)
    commentButton.rightToLeft(of: commentCountLabel, offset: -10.0)
    commentButton.width(25.0)
    commentButton.height(24.0)
    self.commentButton = commentButton
    
    //loveCountLabel
    let loveCountLabel = UILabel()
    loveCountLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
    loveCountLabel.textColor = ANIColor.dark
    addSubview(loveCountLabel)
    loveCountLabel.centerY(to: profileImageView)
    loveCountLabel.rightToLeft(of: commentButton, offset: -10.0)
    loveCountLabel.width(30.0)
    loveCountLabel.height(20.0)
    self.loveCountLabel = loveCountLabel
    
    //loveButtonBG
    let loveButtonBG = UIView()
    loveButtonBG.isUserInteractionEnabled = false
    let loveButtonBGtapGesture = UITapGestureRecognizer(target: self, action: #selector(loveButtonBGTapped))
    loveButtonBG.addGestureRecognizer(loveButtonBGtapGesture)
    addSubview(loveButtonBG)
    loveButtonBG.centerY(to: profileImageView)
    loveButtonBG.rightToLeft(of: loveCountLabel, offset: -10.0)
    loveButtonBG.width(20.0)
    loveButtonBG.height(20.0)
    self.loveButtonBG = loveButtonBG
    
    //loveButton
    var param = WCLShineParams()
    param.bigShineColor = ANIColor.red
    param.smallShineColor = ANIColor.pink
    let loveButton = WCLShineButton(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0), params: param)
    loveButton.fillColor = ANIColor.red
    loveButton.color = ANIColor.gray
    loveButton.image = .heart
    loveButton.isEnabled = false
    loveButton.addTarget(self, action: #selector(love), for: .valueChanged)
    addSubview(loveButton)
    loveButton.centerY(to: profileImageView)
    loveButton.rightToLeft(of: loveCountLabel, offset: -10.0)
    loveButton.width(20.0)
    loveButton.height(20.0)
    self.loveButton = loveButton
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.font = UIFont.systemFont(ofSize: 13.0)
    userNameLabel.textColor = ANIColor.subTitle
    addSubview(userNameLabel)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToLeft(of: loveButton, offset: -10.0)
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
    guard let messageLabel = self.messageLabel,
          let titleLabel = self.titleLabel,
          let subTitleLabel = self.subTitleLabel,
          let loveButtonBG = self.loveButtonBG,
          let loveButton = self.loveButton,
          let loveCountLabel = self.loveCountLabel,
          let commentCountLabel = self.commentCountLabel,
          let story = self.story else { return }
    
    messageLabel.text = story.story
    
    titleLabel.text = story.recruitTitle
    subTitleLabel.text = story.recruitSubTitle

    if ANISessionManager.shared.isAnonymous {
      loveButtonBG.isUserInteractionEnabled = true
      loveButton.isEnabled = false
    } else {
      loveButtonBG.isUserInteractionEnabled = false
      loveButton.isEnabled = true
    }
    loveButton.isSelected = false
    if let loveIds = story.loveIds {
      loveCountLabel.text = "\(loveIds.count)"
    } else {
      loveCountLabel.text = "0"
    }

    if let commentIds = story.commentIds {
      commentCountLabel.text = "\(commentIds.count)"
    } else {
      commentCountLabel.text = "0"
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
  
  private func reloadRecruitLayout(recruit: FirebaseRecruit) {
    guard let recruitImageView = self.recruitImageView,
          let isRecruitLabel = self.isRecruitLabel,
          let homeLabel = self.homeLabel,
          let ageLabel = self.ageLabel,
          let sexLabel = self.sexLabel,
          let headerImageUrl = recruit.headerImageUrl else { return }
    
    recruitImageView.sd_setImage(with: URL(string: headerImageUrl), completed: nil)
    isRecruitLabel.text = recruit.isRecruit ? "募集中" : "決まり！"
    homeLabel.text = recruit.home
    ageLabel.text = recruit.age
    sexLabel.text = recruit.sex
  }
  
  private func loadUser() {
    guard let story = self.story else { return }

    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_USERS).child(story.userId).observeSingleEvent(of: .value, with: { (userSnapshot) in
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
  
  private func loadRecruit() {
    guard let story = self.story,
          let recruitId = story.recruitId else { return }

    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_RECRUITS).child(recruitId).observeSingleEvent(of: .value, with: { (snapshot) in
        if let recruitValue = snapshot.value {
          do {
            let recruit = try FirebaseDecoder().decode(FirebaseRecruit.self, from: recruitValue)
            self.recruit = recruit

            DispatchQueue.main.async {
              self.reloadRecruitLayout(recruit: recruit)
            }
          } catch let error {
            print(error)
          }
        }
      })
    }
  }
  
  private func loadRecruitUser() {
    guard let recruit = self.recruit else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_USERS).child(recruit.userId).observeSingleEvent(of: .value, with: { (userSnapshot) in
        if let userValue = userSnapshot.value {
          do {
            let recruitUser = try FirebaseDecoder().decode(FirebaseUser.self, from: userValue)
            
            self.recruitUser = recruitUser
          } catch let error {
            print(error)
          }
        }
      })
    }
  }
  
  private func observeLove() {
    guard let story = self.story,
          let storyId = story.id else { return }

    let databaseRef = Database.database().reference()
    DispatchQueue.global().async {
      databaseRef.child(KEY_STORIES).child(storyId).child(KEY_LOVE_IDS).observe(.value) { (snapshot) in
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
  
  func unobserveLove() {
    guard let story = self.story,
          let storyId = story.id else { return }
    
    let databaseRef = Database.database().reference()
    DispatchQueue.global().async {
      databaseRef.child(KEY_STORIES).child(storyId).child(KEY_LOVE_IDS).removeAllObservers()
    }
  }
  
  private func isLoved() {
    guard let story = self.story,
          let storyId = story.id,
          let currentUserId = ANISessionManager.shared.currentUserUid else { return }

    let databaseRef = Database.database().reference()
    DispatchQueue.global().async {
      databaseRef.child(KEY_STORIES).child(storyId).child(KEY_LOVE_IDS).observeSingleEvent(of: .value) { (snapshot) in
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
  
  private func updateNoti() {
    guard let story = self.story,
          let storyId = story.id,
          let currentUser = ANISessionManager.shared.currentUser,
          let currentUserName = currentUser.userName,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let user = self.user,
          let userId = user.uid else { return }
    
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      do {
        let noti = "\(currentUserName)さんが「\(story.story)」ストーリーを「いいね」しました。"
        let date = ANIFunction.shared.getToday()
        let notification = FirebaseNotification(userId: currentUserId, noti: noti, kind: KEY_NOTI_KIND_STROY, notiId: storyId, updateDate: date)
        if let data = try FirebaseEncoder().encode(notification) as? [String: AnyObject] {
          
          databaseRef.child(KEY_NOTIFICATIONS).child(userId).child(storyId).updateChildValues(data)
        }
      } catch let error {
        print(error)
      }
    }
  }
  
  private func removeNoti() {
    guard let story = self.story,
          let storyId = story.id,
          let user = self.user,
          let userId = user.uid else { return }
    
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      databaseRef.child(KEY_NOTIFICATIONS).child(userId).child(storyId).removeValue()
    }
  }
  
  //MARK: action
  @objc private func love() {
    guard let story = self.story,
      let storyId = story.id,
      let currentUserId = ANISessionManager.shared.currentUserUid,
      let loveButton = self.loveButton else { return }
    
    let databaseRef = Database.database().reference()
    if loveButton.isSelected == true {
      DispatchQueue.global().async {
        databaseRef.child(KEY_STORIES).child(storyId).child(KEY_LOVE_IDS).updateChildValues([currentUserId: true])
        let date = ANIFunction.shared.getToday()
        databaseRef.child(KEY_LOVE_STORY_IDS).child(currentUserId).updateChildValues([storyId: date])
        
        self.updateNoti()
      }
    } else {
      DispatchQueue.global().async {
        databaseRef.child(KEY_STORIES).child(storyId).child(KEY_LOVE_IDS).child(currentUserId).removeValue()
        databaseRef.child(KEY_LOVE_STORY_IDS).child(currentUserId).child(storyId).removeValue()
        
        self.removeNoti()
      }
    }
  }
  
  @objc private func loveButtonBGTapped() {
    self.delegate?.reject()
  }
  
  @objc private func profileImageViewTapped() {
    guard let story = self.story else { return }
    
    ANINotificationManager.postProfileImageViewTapped(userId: story.userId)
  }
  
  @objc private func cellTapped() {
    guard let story = self.story,
          let user = self.user else { return }
    
    if !ANISessionManager.shared.isAnonymous {
      self.delegate?.supportCellTapped(story: story, user: user)
    } else {
      self.delegate?.reject()
    }
  }
  
  @objc private func recruitTapped() {
    guard let recruit = self.recruit,
          let recruitUser = self.recruitUser else { return }
    
    self.delegate?.supportCellRecruitTapped(recruit: recruit, user: recruitUser)
  }
}
