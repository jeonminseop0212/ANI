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

class ANIStoryViewCell: UITableViewCell {
  private weak var storyImagesView: ANIStoryImagesView?
  private weak var storyLabel: UILabel?
  private weak var line: UIImageView?
  private weak var profileImageView: UIImageView?
  private weak var userNameLabel: UILabel?
  private weak var loveButton: WCLShineButton?
  private weak var loveCountLabel: UILabel?
  private weak var commentButton: UIButton?
  private weak var commentCountLabel: UILabel?
  
  var story: FirebaseStory? {
    didSet {
      reloadLayout()
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none

    //storyImagesView
    let storyImagesView = ANIStoryImagesView()
    addSubview(storyImagesView)
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
    addSubview(storyLabel)
    storyLabel.topToBottom(of: storyImagesView, offset: 5.0)
    storyLabel.leftToSuperview(offset: 10.0)
    storyLabel.rightToSuperview(offset: 10.0)
    self.storyLabel = storyLabel

    //profileImageView
    let profileImageView = UIImageView()
    addSubview(profileImageView)
    profileImageView.topToBottom(of: storyLabel, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(32.0)
    profileImageView.height(32.0)
    profileImageView.layer.cornerRadius = profileImageView.constraints[0].constant / 2
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

    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.font = UIFont.systemFont(ofSize: 13.0)
    userNameLabel.textColor = ANIColor.subTitle
    addSubview(userNameLabel)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToLeft(of: loveButton, offset: 10.0)
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
  
  func observeStory() {
    guard let story = self.story,
          let storyId = story.id else { return }
    
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      databaseRef.child(KEY_STORIES).child(storyId).observe(.value) { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
          let story = try FirebaseDecoder().decode(FirebaseStory.self, from: value)
          
          self.story = story
        } catch let error {
          print(error)
        }
      }
    }
  }
  
  private func reloadLayout() {
    guard let storyImagesView = self.storyImagesView,
          let storyLabel = self.storyLabel,
          let profileImageView = self.profileImageView,
          let userNameLabel = self.userNameLabel,
          let loveCountLabel = self.loveCountLabel,
          let commentCountLabel = self.commentCountLabel,
          let story = self.story else { return }
    
    storyImagesView.imageUrls = story.storyImageUrls
    storyImagesView.pageControl?.numberOfPages = story.storyImageUrls.count
    storyLabel.text = story.story
    profileImageView.sd_setImage(with: URL(string: story.profileImageUrl), completed: nil)
    userNameLabel.text = story.userName
    loveCountLabel.text = "\(story.loveCount)"
    if let commentIds = story.commentIds {
      commentCountLabel.text = "\(commentIds.count)"
    } else {
      commentCountLabel.text = "0"
    }
  }
  
  //MARK: action
  @objc private func love() {
    print("love")
  }
}

