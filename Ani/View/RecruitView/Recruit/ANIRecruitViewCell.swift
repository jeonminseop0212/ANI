//
//  ANIRecruitViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import WCLShineButton
import FirebaseFirestore
import CodableFirebase

protocol ANIRecruitViewCellDelegate {
  func cellTapped(recruit: FirebaseRecruit, user: FirebaseUser)
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser)
  func reject()
}

class ANIRecruitViewCell: UITableViewCell {
  private weak var tapArea: UIView?
  private weak var recruitImageView: UIImageView?
  private weak var basicInfoStackView: UIStackView?
  private weak var recruitStateLabel: UILabel?
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
  private weak var loveButtonBG: UIView?
  private weak var loveButton: WCLShineButton?
  private weak var loveCountLabel: UILabel?
  private weak var clipButton: UIButton?
  private weak var line: UIImageView?
  
  var recruit: FirebaseRecruit? {
    didSet {
      reloadLayout()
      loadUser()
      isLoved()
      isSupported()
      isClipped()
      observeLove()
      observeSupport()
    }
  }
  
  private var user: FirebaseUser?
  
  private var loveListener: ListenerRegistration?
  private var supportListener: ListenerRegistration?
  
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
    recruitImageView.contentMode = .scaleAspectFill
    recruitImageView.clipsToBounds = true
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
    
    //recruitStateLabel
    let recruitStateLabel = UILabel()
    recruitStateLabel.textColor = .white
    recruitStateLabel.textAlignment = .center
    recruitStateLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
    recruitStateLabel.layer.cornerRadius = 5.0
    recruitStateLabel.layer.masksToBounds = true
    recruitStateLabel.backgroundColor = ANIColor.green
    basicInfoStackView.addArrangedSubview(recruitStateLabel)
    recruitStateLabel.height(24.0)
    self.recruitStateLabel = recruitStateLabel
    
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
    tapArea.addSubview(titleLabel)
    titleLabel.topToBottom(of: basicInfoStackView, offset: 10.0)
    titleLabel.leftToSuperview(offset: 10.0)
    titleLabel.rightToSuperview(offset: 10.0)
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
    subTitleLabel.bottomToSuperview()
    self.subTitleLabel = subTitleLabel
    
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
    clipButton.setImage(UIImage(named: "clip")?.withRenderingMode(.alwaysTemplate), for: .normal)
    clipButton.tintColor = ANIColor.gray
    clipButton.addTarget(self, action: #selector(clip), for: .touchUpInside)
    addSubview(clipButton)
    clipButton.centerY(to: profileImageView)
    clipButton.rightToSuperview(offset: 10.0)
    clipButton.width(20.0)
    clipButton.height(20.0)
    self.clipButton = clipButton
    
    //loveCountLabel
    let loveCountLabel = UILabel()
    loveCountLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
    loveCountLabel.textColor = ANIColor.dark
    addSubview(loveCountLabel)
    loveCountLabel.centerY(to: profileImageView)
    loveCountLabel.rightToLeft(of: clipButton, offset: -10.0)
    loveCountLabel.width(25.0)
    loveCountLabel.height(20.0)
    self.loveCountLabel = loveCountLabel
    
    //loveButtonBG
    let loveButtonBG = UIView()
    loveButtonBG.isUserInteractionEnabled = false
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(loveButtonBGTapped))
    loveButtonBG.addGestureRecognizer(tapGesture)
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
    
    //supportCountLabel
    let supportCountLabel = UILabel()
    supportCountLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
    supportCountLabel.textColor = ANIColor.dark
    addSubview(supportCountLabel)
    supportCountLabel.centerY(to: profileImageView)
    supportCountLabel.rightToLeft(of: loveButton, offset: -10.0)
    supportCountLabel.width(25.0)
    supportCountLabel.height(20.0)
    self.supportCountLabel = supportCountLabel
    
    //supportButton
    let supportButton = UIButton()
    supportButton.setImage(UIImage(named: "support")?.withRenderingMode(.alwaysTemplate), for: .normal)
    supportButton.tintColor = ANIColor.gray
    supportButton.addTarget(self, action: #selector(support), for: .touchUpInside)
    addSubview(supportButton)
    supportButton.centerY(to: profileImageView)
    supportButton.rightToLeft(of: supportCountLabel, offset: -10.0)
    supportButton.width(20.0)
    supportButton.height(20.0)
    self.supportButton = supportButton
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.font = UIFont.systemFont(ofSize: 13.0)
    userNameLabel.textColor = ANIColor.subTitle
    userNameLabel.numberOfLines = 2
    addSubview(userNameLabel)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToLeft(of: supportButton, offset: -10.0)
    userNameLabel.centerY(to: profileImageView)
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
          let recruitStateLabel = self.recruitStateLabel,
          let homeLabel = self.homeLabel,
          let ageLabel = self.ageLabel,
          let sexLabel = self.sexLabel,
          let titleLabel = self.titleLabel,
          let subTitleLabel = self.subTitleLabel,
          let supportButton = self.supportButton,
          let loveButtonBG = self.loveButtonBG,
          let loveButton = self.loveButton,
          let clipButton = self.clipButton,
          let recruit = self.recruit,
          let headerImageUrl = recruit.headerImageUrl else { return }
    
    recruitImageView.sd_setImage(with: URL(string: headerImageUrl), completed: nil)
    if recruit.recruitState == 0 {
      recruitStateLabel.text = "募集中"
      recruitStateLabel.backgroundColor  = ANIColor.green
    } else if recruit.recruitState == 1 {
      recruitStateLabel.text = "家族決定"
      recruitStateLabel.backgroundColor  = ANIColor.pink
    } else if recruit.recruitState == 2 {
      recruitStateLabel.text = "中止"
      recruitStateLabel.backgroundColor  = ANIColor.darkGray
    }
    homeLabel.text = recruit.home
    ageLabel.text = recruit.age
    sexLabel.text = recruit.sex
    titleLabel.text = recruit.title
    subTitleLabel.text = recruit.reason
    
    supportButton.tintColor = ANIColor.gray
    
    if ANISessionManager.shared.isAnonymous {
      loveButtonBG.isUserInteractionEnabled = true
      loveButton.isEnabled = false
    } else {
      loveButtonBG.isUserInteractionEnabled = false
      loveButton.isEnabled = true
    }
    loveButton.isSelected = false
    
    clipButton.tintColor = ANIColor.gray
  }
  
  private func reloadUserLayout(user: FirebaseUser) {
    guard let userNameLabel = self.userNameLabel,
          let profileImageView = self.profileImageView,
          let profileImageUrl = user.profileImageUrl,
          let userName = user.userName else { return }
    
    profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    userNameLabel.text = userName
  }
  
  private func observeLove() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let loveCountLabel = self.loveCountLabel else { return }

    let database = Firestore.firestore()
    DispatchQueue.global().async {
      self.loveListener = database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_LOVE_IDS).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        DispatchQueue.main.async {
          if let snapshot = snapshot {
            loveCountLabel.text = "\(snapshot.documents.count)"
          } else {
            loveCountLabel.text = "0"
          }
        }
      })
    }
  }
  
  func unobserveLove() {
    guard let loveListener = self.loveListener else { return }

    loveListener.remove()
  }
  
  private func observeSupport() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let supportCountLabel = self.supportCountLabel else { return }
    
    let database = Firestore.firestore()
    DispatchQueue.global().async {
      self.supportListener = database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_SUPPORT_IDS).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        DispatchQueue.main.async {
          if let snapshot = snapshot {
            supportCountLabel.text = "\(snapshot.documents.count)"
          } else {
            supportCountLabel.text = "0"
          }
          
          self.isSupported()
        }
      })
    }
  }

  func unobserveSupport() {
    guard let supportListener = self.supportListener else { return }
    
    supportListener.remove()
  }
  
  private func isLoved() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUserId = ANISessionManager.shared.currentUserUid else { return }

    let database = Firestore.firestore()
    DispatchQueue.global().async {
      database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_LOVE_IDS).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          if document.documentID == currentUserId {
            DispatchQueue.main.async {
              guard let loveButton = self.loveButton else { return }
              
              loveButton.isSelected = true
            }
          }
        }
      })
    }
  }
  
  private func isSupported() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUserId = ANISessionManager.shared.currentUserUid else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_SUPPORT_IDS).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          if document.documentID == currentUserId {
            DispatchQueue.main.async {
              guard let supportButton = self.supportButton else { return }
              
              supportButton.tintColor = ANIColor.moreDarkGray
            }
          }
        }
      })
    }
  }
  
  private func isClipped() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUserId = ANISessionManager.shared.currentUserUid else { return }

    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_CLIP_IDS).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          if document.documentID == currentUserId {
            DispatchQueue.main.async {
              guard let clipButton = self.clipButton else { return }
              
              clipButton.tintColor = ANIColor.moreDarkGray
            }
          }
        }
      })
    }
  }
  
  private func updateNoti() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUser = ANISessionManager.shared.currentUser,
          let currentUserName = currentUser.userName,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let user = self.user,
          let userId = user.uid else { return }

    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      do {
        let noti = "\(currentUserName)さんが「\(recruit.title)」募集を「いいね」しました。"
        let date = ANIFunction.shared.getToday()
        let notification = FirebaseNotification(userId: currentUserId, noti: noti, kind: KEY_NOTI_KIND_RECRUIT, notiId: recuritId, commentId: nil, updateDate: date)
        let data = try FirestoreEncoder().encode(notification)

        database.collection(KEY_USERS).document(userId).collection(KEY_NOTIFICATIONS).document(recuritId).setData(data)
      } catch let error {
        print(error)
      }
    }
  }
  
  //MARK: action
  @objc private func love() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let loveButton = self.loveButton else { return }

    let database = Firestore.firestore()
    
    if loveButton.isSelected == true {
      DispatchQueue.global().async {
        database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_LOVE_IDS).document(currentUserId).setData([currentUserId: true])
        
        let date = ANIFunction.shared.getToday()
        database.collection(KEY_USERS).document(currentUserId).collection(KEY_LOVE_RECRUIT_IDS).document(recuritId).setData([KEY_DATE: date])

        self.updateNoti()
      }
    } else {
      DispatchQueue.global().async {
        database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_LOVE_IDS).document(currentUserId).delete()
        database.collection(KEY_USERS).document(currentUserId).collection(KEY_LOVE_RECRUIT_IDS).document(recuritId).delete()
      }
    }
  }
  
  @objc private func support() {
    guard let supportButton = self.supportButton,
          let recruit = self.recruit,
          let user = self.user else { return }
    
    if !ANISessionManager.shared.isAnonymous {
      if supportButton.tintColor == ANIColor.gray {
        self.delegate?.supportButtonTapped(supportRecruit: recruit, user: user)
      }
    } else {
      self.delegate?.reject()
    }
  }
  
  @objc private func clip() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let clipButton = self.clipButton else { return }
    
    if !ANISessionManager.shared.isAnonymous {
      let database = Firestore.firestore()

      if clipButton.tintColor == ANIColor.gray {
        UIView.animate(withDuration: 0.15) {
          clipButton.tintColor = ANIColor.moreDarkGray
        }
        
        DispatchQueue.global().async {
        database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_CLIP_IDS).document(currentUserId).setData([currentUserId: true])
          let date = ANIFunction.shared.getToday()
          database.collection(KEY_USERS).document(currentUserId).collection(KEY_CLIP_RECRUIT_IDS).document(recuritId).setData([KEY_DATE: date])
        }
      } else {
        UIView.animate(withDuration: 0.15) {
          clipButton.tintColor = ANIColor.gray
        }
        
        DispatchQueue.global().async {
          database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_CLIP_IDS).document(currentUserId).delete()
          database.collection(KEY_USERS).document(currentUserId).collection(KEY_CLIP_RECRUIT_IDS).document(recuritId).delete()
        }
      }
    } else {
      self.delegate?.reject()
    }
  }
  
  @objc private func loveButtonBGTapped() {
    self.delegate?.reject()
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

//MARK: data
extension ANIRecruitViewCell {
  private func loadUser() {
    guard let recruit = self.recruit else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_USERS).document(recruit.userId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")

          return
        }
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          let user = try FirebaseDecoder().decode(FirebaseUser.self, from: data)
          self.user = user
          
          DispatchQueue.main.async {
            self.reloadUserLayout(user: user)
          }
        } catch let error {
          print(error)
        }
      })
    }
  }
}
