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
  func loadedRecruitIsLoved(indexPath: Int, isLoved: Bool)
  func loadedRecruitIsCliped(indexPath: Int, isCliped: Bool)
  func loadedRecruitIsSupported(indexPath: Int, isSupported: Bool)
  func loadedRecruitUser(user: FirebaseUser)
}

class ANIRecruitViewCell: UITableViewCell {
  
  private weak var base: UIView?
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
  
  var recruit: FirebaseRecruit? {
    didSet {
      guard let recruit = self.recruit else { return }
      
      if user == nil {
        loadUser()
      }
      if recruit.isLoved == nil {
        isLoved()
      }
      if recruit.isSupported == nil {
        isSupported()
      }
      if recruit.isCliped == nil {
        isClipped()
      }
      reloadLayout()
      observeLove()
      observeSupport()
    }
  }
  
  var indexPath: Int?
  
  var user: FirebaseUser? {
    didSet {
      self.reloadUserLayout()
    }
  }
  
  private var supportCount: Int = 0 {
    didSet {
      guard let supportCountLabel = self.supportCountLabel else { return }
      
      DispatchQueue.main.async {
        supportCountLabel.text = "\(self.supportCount)"
      }
    }
  }
  
  private var loveCount: Int = 0 {
    didSet {
      guard let loveCountLabel = self.loveCountLabel else { return }
      
      DispatchQueue.main.async {
        loveCountLabel.text = "\(self.loveCount)"
      }
    }
  }
  
  private var loveListener: ListenerRegistration?
  private var supportListener: ListenerRegistration?
  
  var delegate: ANIRecruitViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    self.backgroundColor = ANIColor.bg
    
    //base
    let base = UIView()
    base.backgroundColor = .white
    base.layer.cornerRadius = 10.0
    base.layer.masksToBounds = true
    addSubview(base)
    base.topToSuperview(offset: 0)
    base.leftToSuperview(offset: 10)
    base.rightToSuperview(offset: -10)
    base.bottomToSuperview(offset: -10)
    self.base = base
    
    //tapArea
    let tapArea = UIView()
    let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
    tapArea.addGestureRecognizer(cellTapGesture)
    base.addSubview(tapArea)
    tapArea.edgesToSuperview(excluding: .bottom)
    self.tapArea = tapArea
    
    //recruitImageView
    let recruitImageView = UIImageView()
    recruitImageView.backgroundColor = ANIColor.gray
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
    basicInfoStackView.spacing = 5.0
    tapArea.addSubview(basicInfoStackView)
    basicInfoStackView.topToBottom(of: recruitImageView, offset: 10.0)
    basicInfoStackView.leftToSuperview(offset: 10.0)
    basicInfoStackView.rightToSuperview(offset: -10.0)
    self.basicInfoStackView = basicInfoStackView
    
    //recruitStateLabel
    let recruitStateLabel = UILabel()
    recruitStateLabel.textColor = .white
    recruitStateLabel.textAlignment = .center
    recruitStateLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
    recruitStateLabel.layer.cornerRadius = 5.0
    recruitStateLabel.layer.masksToBounds = true
    recruitStateLabel.backgroundColor = ANIColor.emerald
    basicInfoStackView.addArrangedSubview(recruitStateLabel)
    recruitStateLabel.height(26.0)
    self.recruitStateLabel = recruitStateLabel
    
    //homeLabel
    let homeLabel = UILabel()
    homeLabel.textColor = ANIColor.darkGray
    homeLabel.textAlignment = .center
    homeLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
    homeLabel.adjustsFontSizeToFitWidth = true
    homeLabel.layer.cornerRadius = 5.0
    homeLabel.layer.masksToBounds = true
    homeLabel.layer.borderColor = ANIColor.darkGray.cgColor
    homeLabel.layer.borderWidth = 1.2
    basicInfoStackView.addArrangedSubview(homeLabel)
    homeLabel.height(26.0)
    self.homeLabel = homeLabel
    
    //ageLabel
    let ageLabel = UILabel()
    ageLabel.textColor = ANIColor.darkGray
    ageLabel.textAlignment = .center
    ageLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
    ageLabel.adjustsFontSizeToFitWidth = true
    ageLabel.layer.cornerRadius = 5.0
    ageLabel.layer.masksToBounds = true
    ageLabel.layer.borderColor = ANIColor.darkGray.cgColor
    ageLabel.layer.borderWidth = 1.2
    basicInfoStackView.addArrangedSubview(ageLabel)
    ageLabel.height(26.0)
    self.ageLabel = ageLabel
    
    //sexLabel
    let sexLabel = UILabel()
    sexLabel.textColor = ANIColor.darkGray
    sexLabel.textAlignment = .center
    sexLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
    sexLabel.adjustsFontSizeToFitWidth = true
    sexLabel.layer.cornerRadius = 5.0
    sexLabel.layer.masksToBounds = true
    sexLabel.layer.borderColor = ANIColor.darkGray.cgColor
    sexLabel.layer.borderWidth = 1.2
    basicInfoStackView.addArrangedSubview(sexLabel)
    sexLabel.height(26.0)
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
    titleLabel.rightToSuperview(offset: -10.0)
    self.titleLabel = titleLabel
    
    //subTitleLabel
    let subTitleLabel = UILabel()
    subTitleLabel.numberOfLines = 3
    subTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
    subTitleLabel.textColor = ANIColor.subTitle
    tapArea.addSubview(subTitleLabel)
    subTitleLabel.topToBottom(of: titleLabel, offset: 10.0)
    subTitleLabel.leftToSuperview(offset: 10.0)
    subTitleLabel.rightToSuperview(offset: -10.0)
    subTitleLabel.bottomToSuperview()
    self.subTitleLabel = subTitleLabel
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.isUserInteractionEnabled = true
    let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
    profileImageView.addGestureRecognizer(profileImageTapGesture)
    profileImageView.backgroundColor = ANIColor.gray
    base.addSubview(profileImageView)
    profileImageView.topToBottom(of: tapArea, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.bottomToSuperview(offset: -10.0)
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
    base.addSubview(clipButton)
    clipButton.centerY(to: profileImageView)
    clipButton.rightToSuperview(offset: -10.0)
    clipButton.width(20.0)
    clipButton.height(20.0)
    self.clipButton = clipButton
    
    //loveCountLabel
    let loveCountLabel = UILabel()
    loveCountLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
    loveCountLabel.textColor = ANIColor.dark
    base.addSubview(loveCountLabel)
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
    base.addSubview(loveButtonBG)
    loveButtonBG.centerY(to: profileImageView)
    loveButtonBG.rightToLeft(of: loveCountLabel, offset: -10.0)
    loveButtonBG.width(20.0)
    loveButtonBG.height(20.0)
    self.loveButtonBG = loveButtonBG
    
    //loveButton
    var param = WCLShineParams()
    param.bigShineColor = ANIColor.pink
    param.smallShineColor = ANIColor.lightPink
    let loveButton = WCLShineButton(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0), params: param)
    loveButton.fillColor = ANIColor.pink
    loveButton.color = ANIColor.gray
    loveButton.image = .heart
    loveButton.isEnabled = false
    loveButton.addTarget(self, action: #selector(love), for: .valueChanged)
    base.addSubview(loveButton)
    loveButton.centerY(to: profileImageView)
    loveButton.rightToLeft(of: loveCountLabel, offset: -10.0)
    loveButton.width(20.0)
    loveButton.height(20.0)
    self.loveButton = loveButton
    
    //supportCountLabel
    let supportCountLabel = UILabel()
    supportCountLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
    supportCountLabel.textColor = ANIColor.dark
    base.addSubview(supportCountLabel)
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
    base.addSubview(supportButton)
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
    base.addSubview(userNameLabel)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToLeft(of: supportButton, offset: -10.0)
    userNameLabel.centerY(to: profileImageView)
    self.userNameLabel = userNameLabel
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
      recruitStateLabel.backgroundColor  = ANIColor.emerald
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
    if let isSupported = recruit.isSupported {
      if isSupported {
        supportButton.tintColor = ANIColor.moreDarkGray
      } else {
        supportButton.tintColor = ANIColor.gray
      }
    }
    
    if ANISessionManager.shared.isAnonymous {
      loveButtonBG.isUserInteractionEnabled = true
      loveButton.isEnabled = false
    } else {
      loveButtonBG.isUserInteractionEnabled = false
      loveButton.isEnabled = true
    }
    loveButton.isSelected = false
    if let isLoved = recruit.isLoved {
      if isLoved {
        loveButton.isSelected = true
      } else {
        loveButton.isSelected = false
      }
    }
    
    clipButton.tintColor = ANIColor.gray
    if let isCliped = recruit.isCliped {
      if isCliped {
        clipButton.tintColor = ANIColor.moreDarkGray
      } else {
        clipButton.tintColor = ANIColor.gray
      }
    }
  }
  
  private func reloadUserLayout() {
    guard let userNameLabel = self.userNameLabel,
          let profileImageView = self.profileImageView else { return }
    
    if let user = self.user, let profileImageUrl = user.profileImageUrl {
      profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    } else {
      profileImageView.image = UIImage()
    }
    
    if let user = self.user, let userName = user.userName {
      userNameLabel.text = userName
    } else {
      userNameLabel.text = ""
    }
  }
  
  private func observeLove() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id else { return }
    
    self.loveCount = 0

    let database = Firestore.firestore()
    DispatchQueue.global().async {
      self.loveListener = database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_LOVE_IDS).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        if let snapshot = snapshot {
          self.loveCount = snapshot.documents.count
        } else {
          self.loveCount = 0
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
          let recuritId = recruit.id else { return }
    
    self.supportCount = 0
    
    let database = Firestore.firestore()
    DispatchQueue.global().async {
      self.supportListener = database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_SUPPORT_IDS).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        DispatchQueue.main.async {
          if let snapshot = snapshot {
            self.supportCount = snapshot.documents.count
          } else {
            self.supportCount = 0
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
          let loveButton = self.loveButton else { return }

    if let currentUserId = ANISessionManager.shared.currentUserUid {
      let database = Firestore.firestore()
      
      DispatchQueue.global().async {
        database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_LOVE_IDS).getDocuments(completion: { (snapshot, error) in
          if let error = error {
            DLog("Error get document: \(error)")
            
            return
          }
          
          guard let snapshot = snapshot else { return }
          
          var isLoved = false
          
          DispatchQueue.main.async {
            for document in snapshot.documents {
              if document.documentID == currentUserId {
                loveButton.isSelected = true
                isLoved = true
                break
              } else {
                isLoved = false
              }
            }
            
            if let indexPath = self.indexPath {
              self.delegate?.loadedRecruitIsLoved(indexPath: indexPath, isLoved: isLoved)
            }
          }
        })
      }
    } else {
      loveButton.isSelected = false
    }
  }
  
  private func isSupported() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let supportButton = self.supportButton else { return }

    if let currentUserId = ANISessionManager.shared.currentUserUid {
      let database = Firestore.firestore()
      
      DispatchQueue.global().async {
        database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_SUPPORT_IDS).getDocuments(completion: { (snapshot, error) in
          if let error = error {
            DLog("Error get document: \(error)")
            
            return
          }
          
          guard let snapshot = snapshot else { return }
          
          var isSuport = false
          
          DispatchQueue.main.async {
            for document in snapshot.documents {
              if document.documentID == currentUserId {
                supportButton.tintColor = ANIColor.moreDarkGray
                isSuport = true
                break
              } else {
                isSuport = false
              }
            }
            
            if let indexPath = self.indexPath {
              self.delegate?.loadedRecruitIsSupported(indexPath: indexPath, isSupported: isSuport)
            }
          }
        })
      }
    } else {
      supportButton.tintColor = ANIColor.gray
    }
  }
  
  private func isClipped() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let clipButton = self.clipButton else { return }

    if let currentUserId = ANISessionManager.shared.currentUserUid {
      let database = Firestore.firestore()
      
      DispatchQueue.global().async {
        database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_CLIP_IDS).getDocuments(completion: { (snapshot, error) in
          if let error = error {
            DLog("Error get document: \(error)")
            
            return
          }
          
          guard let snapshot = snapshot else { return }
          
          var isCliped = false
          
          DispatchQueue.main.async {
            for document in snapshot.documents {
              if document.documentID == currentUserId {
                clipButton.tintColor = ANIColor.moreDarkGray
                isCliped = true
                break
              } else {
                isCliped = false
              }
            }
            
            if let indexPath = self.indexPath {
              self.delegate?.loadedRecruitIsCliped(indexPath: indexPath, isCliped: isCliped)
            }
          }
        })
      }
    } else {
      clipButton.tintColor = ANIColor.gray
    }
  }
  
  private func updateNoti() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUser = ANISessionManager.shared.currentUser,
          let currentUserName = currentUser.userName,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let user = self.user,
          let userId = user.uid,
          currentUserId != userId else { return }

    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_LOVE_IDS).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        var noti = ""
        
        if let snapshot = snapshot, snapshot.documents.count > 1 {
          noti = "\(currentUserName)さん、他\(snapshot.documents.count - 1)人が「\(recruit.title)」募集を「いいね」しました。"
        } else {
          noti = "\(currentUserName)さんが「\(recruit.title)」募集を「いいね」しました。"
        }
        
        do {
          let date = ANIFunction.shared.getToday()
          let notification = FirebaseNotification(userId: currentUserId, userName: currentUserName, noti: noti, contributionKind: KEY_CONTRIBUTION_KIND_RECRUIT, notiKind: KEY_NOTI_KIND_LOVE, notiId: recuritId, commentId: nil, updateDate: date)
          let data = try FirestoreEncoder().encode(notification)
          
          database.collection(KEY_USERS).document(userId).collection(KEY_NOTIFICATIONS).document(recuritId).setData(data)
          database.collection(KEY_USERS).document(userId).updateData([KEY_IS_HAVE_UNREAD_NOTI: true])
        } catch let error {
          DLog(error)
        }
      })
    }
  }
  
  //MARK: action
  @objc private func love() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let loveButton = self.loveButton,
          let indexPath = self.indexPath else { return }

    let database = Firestore.firestore()
    
    if loveButton.isSelected == true {
      DispatchQueue.global().async {
        let date = ANIFunction.shared.getToday()
 
        DispatchQueue.global().async {
          database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_LOVE_IDS).document(currentUserId).setData([currentUserId: true, KEY_DATE: date])
        }
        
        DispatchQueue.global().async {
          database.collection(KEY_USERS).document(currentUserId).collection(KEY_LOVE_RECRUIT_IDS).document(recuritId).setData([KEY_DATE: date])
        }

        self.updateNoti()
        
        self.delegate?.loadedRecruitIsLoved(indexPath: indexPath, isLoved: true)
      }
    } else {
      DispatchQueue.global().async {
        database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_LOVE_IDS).document(currentUserId).delete()
      }
      
      DispatchQueue.global().async {
        database.collection(KEY_USERS).document(currentUserId).collection(KEY_LOVE_RECRUIT_IDS).document(recuritId).delete()
      }
      
      self.delegate?.loadedRecruitIsLoved(indexPath: indexPath, isLoved: false)
    }
  }
  
  @objc private func support() {
    guard let supportButton = self.supportButton,
          let recruit = self.recruit,
          let user = self.user,
          let indexPath = self.indexPath else { return }
    
    if !ANISessionManager.shared.isAnonymous {
      if supportButton.tintColor == ANIColor.gray {
        self.delegate?.supportButtonTapped(supportRecruit: recruit, user: user)
        self.delegate?.loadedRecruitIsSupported(indexPath: indexPath, isSupported: true)
      }
    } else {
      self.delegate?.reject()
      self.delegate?.loadedRecruitIsSupported(indexPath: indexPath, isSupported: false)
    }
  }
  
  @objc private func clip() {
    guard let recruit = self.recruit,
          let recuritId = recruit.id,
          let clipButton = self.clipButton,
          let indexPath = self.indexPath else { return }
    
    if !ANISessionManager.shared.isAnonymous, let currentUserId = ANISessionManager.shared.currentUserUid {
      let database = Firestore.firestore()

      if clipButton.tintColor == ANIColor.gray {
        UIView.animate(withDuration: 0.15) {
          clipButton.tintColor = ANIColor.moreDarkGray
        }
        
        DispatchQueue.global().async {
        database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_CLIP_IDS).document(currentUserId).setData([currentUserId: true])
        }
        
        DispatchQueue.global().async {
          let date = ANIFunction.shared.getToday()
          database.collection(KEY_USERS).document(currentUserId).collection(KEY_CLIP_RECRUIT_IDS).document(recuritId).setData([KEY_DATE: date])
        }
        
        self.delegate?.loadedRecruitIsCliped(indexPath: indexPath, isCliped: true)
      } else {
        UIView.animate(withDuration: 0.15) {
          clipButton.tintColor = ANIColor.gray
        }
        
        DispatchQueue.global().async {
          database.collection(KEY_RECRUITS).document(recuritId).collection(KEY_CLIP_IDS).document(currentUserId).delete()
          database.collection(KEY_USERS).document(currentUserId).collection(KEY_CLIP_RECRUIT_IDS).document(recuritId).delete()
          
          self.delegate?.loadedRecruitIsCliped(indexPath: indexPath, isCliped: false)
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
          DLog("Error get document: \(error)")

          return
        }
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          let user = try FirebaseDecoder().decode(FirebaseUser.self, from: data)
          self.user = user
          self.delegate?.loadedRecruitUser(user: user)
        } catch let error {
          DLog(error)
        }
      })
    }
  }
}
