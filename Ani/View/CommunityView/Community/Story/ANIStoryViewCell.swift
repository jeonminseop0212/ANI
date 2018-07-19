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

protocol ANIStoryViewCellDelegate {
  func storyCellTapped(story: FirebaseStory, user: FirebaseUser)
  func reject()
}

class ANIStoryViewCell: UITableViewCell {
  private weak var tapArea: UIView?
  private weak var storyImagesView: ANIStoryImagesView?
  private weak var storyLabel: UILabel?
  private weak var line: UIImageView?
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 32.0
  private weak var profileImageView: UIImageView?
  private weak var userNameLabel: UILabel?
  private weak var loveButtonBG: UIView?
  private weak var loveButton: WCLShineButton?
  private weak var loveCountLabel: UILabel?
  private weak var commentButton: UIButton?
  private weak var commentCountLabel: UILabel?
  
  var story: FirebaseStory? {
    didSet {
      reloadLayout()
      loadUser()
      isLoved()
      observeLove()
    }
  }
  
  private var user: FirebaseUser?
  
  private var loveListener: ListenerRegistration?
  
  var delegate: ANIStoryViewCellDelegate?
  
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
    
    //storyImagesView
    let storyImagesView = ANIStoryImagesView()
    tapArea.addSubview(storyImagesView)
    storyImagesView.topToSuperview()
    storyImagesView.leftToSuperview()
    storyImagesView.rightToSuperview()
    self.storyImagesView = storyImagesView

    //storyLabel
    let storyLabel = UILabel()
    storyLabel.font = UIFont.systemFont(ofSize: 14.0)
    storyLabel.textAlignment = .left
    storyLabel.textColor = ANIColor.subTitle
    storyLabel.numberOfLines = 0
    tapArea.addSubview(storyLabel)
    storyLabel.topToBottom(of: storyImagesView, offset: 5.0)
    storyLabel.leftToSuperview(offset: 10.0)
    storyLabel.rightToSuperview(offset: 10.0)
    storyLabel.bottomToSuperview()
    self.storyLabel = storyLabel
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.backgroundColor = ANIColor.bg
    profileImageView.isUserInteractionEnabled = true
    let profileIamgetapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
    profileImageView.addGestureRecognizer(profileIamgetapGesture)
    addSubview(profileImageView)
    profileImageView.topToBottom(of: tapArea, offset: 10.0)
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
    guard let storyImagesView = self.storyImagesView,
          let storyLabel = self.storyLabel,
          let loveButtonBG = self.loveButtonBG,
          let loveButton = self.loveButton,
          let loveCountLabel = self.loveCountLabel,
          let commentCountLabel = self.commentCountLabel,
          let story = self.story else { return }
    
    if let storyImageUrls = story.storyImageUrls {
      storyImagesView.imageUrls = storyImageUrls
      storyImagesView.pageControl?.numberOfPages = storyImageUrls.count
    }
    storyLabel.text = story.story
    
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
  
  private func observeLove() {
    guard let story = self.story,
          let storyId = story.id,
          let loveCountLabel = self.loveCountLabel else { return }
    
    let database = Firestore.firestore()
    DispatchQueue.global().async {
      self.loveListener = database.collection(KEY_STORIES).document(storyId).collection(KEY_LOVE_IDS).addSnapshotListener({ (snapshot, error) in
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
  
  private func isLoved() {
    guard let story = self.story,
          let storyId = story.id,
          let currentUserId = ANISessionManager.shared.currentUserUid else { return }
    
    let database = Firestore.firestore()
    DispatchQueue.global().async {
      database.collection(KEY_STORIES).document(storyId).collection(KEY_LOVE_IDS).getDocuments(completion: { (snapshot, error) in
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
  
  private func updateNoti() {
    guard let story = self.story,
          let storyId = story.id,
          let currentUser = ANISessionManager.shared.currentUser,
          let currentUserName = currentUser.userName,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let user = self.user,
          let userId = user.uid else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      do {
        let noti = "\(currentUserName)さんが「\(story.story)」ストーリーを「いいね」しました。"
        let date = ANIFunction.shared.getToday()
        let notification = FirebaseNotification(userId: currentUserId, noti: noti, kind: KEY_NOTI_KIND_STROY, notiId: storyId, commentId: nil, updateDate: date)
        if let data = try FirebaseEncoder().encode(notification) as? [String: AnyObject] {
          
          database.collection(KEY_NOTIFICATIONS).document(userId).setData([storyId : data], options: .merge())
        }
      } catch let error {
        print(error)
      }
    }
  }
  
  //MARK: action
  @objc private func love() {
    guard let story = self.story,
          let storyId = story.id,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let loveButton = self.loveButton else { return }
    
    let database = Firestore.firestore()
    
    if loveButton.isSelected == true {
      DispatchQueue.global().async {
        database.collection(KEY_STORIES).document(storyId).collection(KEY_LOVE_IDS).document(currentUserId).setData([currentUserId: true])
        let date = ANIFunction.shared.getToday()
        database.collection(KEY_LOVE_STORY_IDS).document(currentUserId).setData([storyId: date], options: .merge())
        
        self.updateNoti()
      }
    } else {
      DispatchQueue.global().async {
        database.collection(KEY_STORIES).document(storyId).collection(KEY_LOVE_IDS).document(currentUserId).delete()
        database.collection(KEY_LOVE_STORY_IDS).document(currentUserId).updateData([storyId: FieldValue.delete()])
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
      self.delegate?.storyCellTapped(story: story, user: user)
    } else {
      self.delegate?.reject()
    }
  }
}

//MARK: data
extension ANIStoryViewCell {
  private func loadUser() {
    guard let story = self.story else { return }
    
    DispatchQueue.global().async {
      let database = Firestore.firestore()
      database.collection(KEY_USERS).document(story.userId).getDocument(completion: { (snapshot, error) in
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

