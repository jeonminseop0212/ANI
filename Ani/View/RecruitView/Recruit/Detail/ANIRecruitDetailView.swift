//
//  ANIRecruitDetailView.swift
//  Ani
//
//  Created by jeonminseop on 2018/04/26.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

protocol ANIRecruitDetailViewDelegate {
  func recruitDetailViewDidScroll(offset: CGFloat)
}

class ANIRecruitDetailView: UIView {
  
  private weak var headerImageView: UIImageView?
  private var headerImageViewTopConstraint: Constraint?
  var headerMinHeight: CGFloat?

  private weak var scrollView: UIScrollView?
  
  private let CONTENT_SPACE: CGFloat = 25.0
  private weak var contentView: UIView?
  
  private weak var titleLabel: UILabel?
  
  private let PROFILE_IMAGE_HEIGHT: CGFloat = 32.0
  private weak var profileImageView: UIImageView?
  
  private weak var userNameLabel: UILabel?
  
  private weak var basicInfoTitleLabel: UILabel?
  private weak var basicInfoBG: UIView?
  private weak var basicInfoLine: UIImageView?
  private weak var basicInfoKindLabel: UILabel?
  private weak var basicInfoAgeLabel: UILabel?
  private weak var basicInfoSexLabel: UILabel?
  private weak var basicInfoHomeLabel: UILabel?
  private weak var basicInfoVaccineLabel: UILabel?
  private weak var basicInfoCastrationLabel: UILabel?
  
  private weak var reasonTitleLabel: UILabel?
  private weak var reasonBG: UIView?
  private weak var reasonLabel: UILabel?
  
  private weak var introduceTitleLabel: UILabel?
  private weak var introduceBG: UIView?
  private weak var introduceLabel: UILabel?
  private let INTRODUCE_IMAGES_VIEW_RATIO: CGFloat = 0.5
  private weak var introduceImagesView: ANIRecruitDetailImagesView?
  
  private weak var passingTitleLabel: UILabel?
  private weak var passingBG: UIView?
  private weak var passingLabel: UILabel?
  
  private var testBasicInfo = [String: String]()
  private var testIntroduceImages = [UIImage]()
  
  var delegate: ANIRecruitDetailViewDelegate?
  
  var testRecruit: Recruit? {
    didSet {
      reloadLayout()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setTestIntroduceImages()
    setTestBasicInfo()
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = .white
    
    //headerImageView
    let headerImageView = UIImageView()
    addSubview(headerImageView)
    headerImageViewTopConstraint = headerImageView.topToSuperview()
    let headerImageViewHeight: CGFloat = UIScreen.main.bounds.width * UIViewController.HEADER_IMAGE_VIEW_RATIO
    headerImageView.leftToSuperview()
    headerImageView.rightToSuperview()
    headerImageView.height(headerImageViewHeight)
    self.headerImageView = headerImageView
    
    //scrollView
    let scrollView = UIScrollView()
    scrollView.delegate = self
    let topInset = headerImageViewHeight
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    scrollView.scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    addSubview(scrollView)
    scrollView.edgesToSuperview()
    self.scrollView = scrollView
    
    //contentView
    let contentView = UIView()
    scrollView.addSubview(contentView)
    contentView.topToSuperview()
    contentView.leftToSuperview()
    contentView.rightToSuperview()
    contentView.bottomToSuperview()
    contentView.width(to: scrollView)
    self.contentView = contentView
    
    //titleLabel
    let titleLabel = UILabel()
    titleLabel.numberOfLines = 0
    titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    titleLabel.textColor = ANIColor.dark
    contentView.addSubview(titleLabel)
    titleLabel.topToSuperview(offset: 10.0)
    titleLabel.leftToSuperview(offset: 10.0)
    titleLabel.rightToSuperview(offset: 10.0)
    self.titleLabel = titleLabel
    
    //profileImageView
    let profileImageView = UIImageView()
    contentView.addSubview(profileImageView)
    profileImageView.width(PROFILE_IMAGE_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_HEIGHT)
    profileImageView.topToBottom(of: titleLabel, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    self.profileImageView = profileImageView
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.numberOfLines = 1
    userNameLabel.font = UIFont.systemFont(ofSize: 13.0)
    userNameLabel.textColor = ANIColor.subTitle
    contentView.addSubview(userNameLabel)
    userNameLabel.centerY(to: profileImageView)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToSuperview(offset: 10.0)
    self.userNameLabel = userNameLabel
    
    //basicInfoTitleLabel
    let basicInfoTitleLabel = UILabel()
    basicInfoTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    basicInfoTitleLabel.textColor = ANIColor.dark
    basicInfoTitleLabel.text = "猫ちゃんの情報"
    contentView.addSubview(basicInfoTitleLabel)
    basicInfoTitleLabel.topToBottom(of: profileImageView, offset: CONTENT_SPACE)
    basicInfoTitleLabel.leftToSuperview(offset: 10.0)
    basicInfoTitleLabel.rightToSuperview(offset: 10.0)
    self.basicInfoTitleLabel = basicInfoTitleLabel
    
    //basicInfoBG
    let basicInfoBG = UIView()
    basicInfoBG.backgroundColor = ANIColor.lightGray
    basicInfoBG.layer.cornerRadius = 10.0
    basicInfoBG.layer.masksToBounds = true
    contentView.addSubview(basicInfoBG)
    basicInfoBG.topToBottom(of: basicInfoTitleLabel, offset: 10.0)
    basicInfoBG.leftToSuperview(offset: 10.0)
    basicInfoBG.rightToSuperview(offset: 10.0)
    self.basicInfoBG = basicInfoBG
    
    //basicInfoLine
    let basicInfoLine = UIImageView()
    basicInfoLine.image = UIImage(named: "basicInfoLine")
    basicInfoBG.addSubview(basicInfoLine)
    basicInfoLine.topToSuperview(offset: 10.0)
    basicInfoLine.width(1)
    basicInfoLine.centerXToSuperview()
    basicInfoLine.bottomToSuperview(offset: -10.0)
    self.basicInfoLine = basicInfoLine
    
    //basicInfoKindLabel
    let basicInfoKindLabel = UILabel()
    basicInfoKindLabel.font = UIFont.systemFont(ofSize: 15.0)
    basicInfoKindLabel.textColor = ANIColor.dark
    basicInfoKindLabel.numberOfLines = 0
    basicInfoBG.addSubview(basicInfoKindLabel)
    basicInfoKindLabel.topToSuperview(offset: 10.0)
    basicInfoKindLabel.leftToSuperview(offset: 10.0)
    basicInfoKindLabel.rightToLeft(of: basicInfoLine, offset: 10.0)
    self.basicInfoKindLabel = basicInfoKindLabel
    
    //basicInfoAgeLabel
    let basicInfoAgeLabel = UILabel()
    basicInfoAgeLabel.font = UIFont.systemFont(ofSize: 15.0)
    basicInfoAgeLabel.textColor = ANIColor.dark
    basicInfoAgeLabel.numberOfLines = 0
    basicInfoBG.addSubview(basicInfoAgeLabel)
    basicInfoAgeLabel.topToSuperview(offset: 10.0)
    basicInfoAgeLabel.leftToRight(of: basicInfoLine, offset: 10.0)
    basicInfoAgeLabel.rightToSuperview(offset: 10.0)
    self.basicInfoAgeLabel = basicInfoAgeLabel
    
    //basicInfoSexLabel
    let basicInfoSexLabel = UILabel()
    basicInfoSexLabel.font = UIFont.systemFont(ofSize: 15.0)
    basicInfoSexLabel.textColor = ANIColor.dark
    basicInfoSexLabel.numberOfLines = 0
    basicInfoBG.addSubview(basicInfoSexLabel)
    basicInfoSexLabel.topToBottom(of: basicInfoKindLabel, offset: 10.0)
    basicInfoSexLabel.leftToSuperview(offset: 10.0)
    basicInfoSexLabel.rightToLeft(of: basicInfoLine, offset: 10.0)
    self.basicInfoSexLabel = basicInfoSexLabel

    //basicInfoHomeLabel
    let basicInfoHomeLabel = UILabel()
    basicInfoHomeLabel.font = UIFont.systemFont(ofSize: 15.0)
    basicInfoHomeLabel.textColor = ANIColor.dark
    basicInfoHomeLabel.numberOfLines = 0
    basicInfoBG.addSubview(basicInfoHomeLabel)
    basicInfoHomeLabel.topToBottom(of: basicInfoAgeLabel, offset: 10.0)
    basicInfoHomeLabel.leftToRight(of: basicInfoLine, offset: 10.0)
    basicInfoHomeLabel.rightToSuperview(offset: 10.0)
    self.basicInfoHomeLabel = basicInfoHomeLabel
    
    //basicInfoVaccineLabel
    let basicInfoVaccineLabel = UILabel()
    basicInfoVaccineLabel.font = UIFont.systemFont(ofSize: 15.0)
    basicInfoVaccineLabel.textColor = ANIColor.dark
    basicInfoVaccineLabel.numberOfLines = 0
    basicInfoBG.addSubview(basicInfoVaccineLabel)
    basicInfoVaccineLabel.topToBottom(of: basicInfoSexLabel, offset: 10.0)
    basicInfoVaccineLabel.leftToSuperview(offset: 10.0)
    basicInfoVaccineLabel.rightToLeft(of: basicInfoLine, offset: 10.0)
    basicInfoVaccineLabel.bottomToSuperview(offset: -10)
    self.basicInfoVaccineLabel = basicInfoVaccineLabel
    
    //basicInfoCastrationLabel
    let basicInfoCastrationLabel = UILabel()
    basicInfoCastrationLabel.font = UIFont.systemFont(ofSize: 15.0)
    basicInfoCastrationLabel.textColor = ANIColor.dark
    basicInfoCastrationLabel.numberOfLines = 0
    basicInfoBG.addSubview(basicInfoCastrationLabel)
    basicInfoCastrationLabel.topToBottom(of: basicInfoHomeLabel, offset: 10.0)
    basicInfoCastrationLabel.leftToRight(of: basicInfoLine, offset: 10.0)
    basicInfoCastrationLabel.rightToSuperview(offset: 10.0)
    self.basicInfoCastrationLabel = basicInfoCastrationLabel
    
    //reasonTitleLabel
    let reasonTitleLabel = UILabel()
    reasonTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    reasonTitleLabel.textColor = ANIColor.dark
    reasonTitleLabel.text = "募集する理由"
    contentView.addSubview(reasonTitleLabel)
    reasonTitleLabel.topToBottom(of: basicInfoBG, offset: CONTENT_SPACE)
    reasonTitleLabel.leftToSuperview(offset: 10.0)
    reasonTitleLabel.rightToSuperview(offset: 10.0)
    self.reasonTitleLabel = reasonTitleLabel
    
    //reasonBG
    let reasonBG = UIView()
    reasonBG.backgroundColor = ANIColor.lightGray
    reasonBG.layer.cornerRadius = 10.0
    reasonBG.layer.masksToBounds = true
    contentView.addSubview(reasonBG)
    reasonBG.topToBottom(of: reasonTitleLabel, offset: 10.0)
    reasonBG.leftToSuperview(offset: 10.0)
    reasonBG.rightToSuperview(offset: 10.0)
    self.reasonBG = reasonBG
    
    //reasonLabel
    let reasonLabel = UILabel()
    reasonLabel.font = UIFont.systemFont(ofSize: 15.0)
    reasonLabel.textColor = ANIColor.dark
    reasonLabel.numberOfLines = 0
    reasonBG.addSubview(reasonLabel)
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
    reasonLabel.edgesToSuperview(insets: insets)
    self.reasonLabel = reasonLabel
    
    //introduceTitleLabel
    let introduceTitleLabel = UILabel()
    introduceTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    introduceTitleLabel.textColor = ANIColor.dark
    introduceTitleLabel.text = "猫ちゃんの紹介"
    contentView.addSubview(introduceTitleLabel)
    introduceTitleLabel.topToBottom(of: reasonBG, offset: CONTENT_SPACE)
    introduceTitleLabel.leftToSuperview(offset: 10.0)
    introduceTitleLabel.rightToSuperview(offset: 10.0)
    self.introduceTitleLabel = introduceTitleLabel
    
    //introduceBG
    let introduceBG = UIView()
    introduceBG.backgroundColor = ANIColor.lightGray
    introduceBG.layer.cornerRadius = 10.0
    introduceBG.layer.masksToBounds = true
    contentView.addSubview(introduceBG)
    introduceBG.topToBottom(of: introduceTitleLabel, offset: 10.0)
    introduceBG.leftToSuperview(offset: 10.0)
    introduceBG.rightToSuperview(offset: 10.0)
    self.introduceBG = introduceBG
    
    //introduceLabel
    let introduceLabel = UILabel()
    introduceLabel.font = UIFont.systemFont(ofSize: 15.0)
    introduceLabel.textColor = ANIColor.dark
    introduceLabel.numberOfLines = 0
    introduceBG.addSubview(introduceLabel)
    introduceLabel.edgesToSuperview(insets: insets)
    self.introduceLabel = introduceLabel
    
    //introduceImagesView
    let introduceImagesView = ANIRecruitDetailImagesView()
    introduceImagesView.testIntroduceImages = testIntroduceImages
    contentView.addSubview(introduceImagesView)
    introduceImagesView.topToBottom(of: introduceBG, offset: 10.0)
    introduceImagesView.leftToSuperview()
    introduceImagesView.rightToSuperview()
    introduceImagesView.height(UIScreen.main.bounds.width * INTRODUCE_IMAGES_VIEW_RATIO)
    self.introduceImagesView = introduceImagesView
    
    //passingTitleLabel
    let passingTitleLabel = UILabel()
    passingTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    passingTitleLabel.textColor = ANIColor.dark
    passingTitleLabel.text = "引渡し方法"
    contentView.addSubview(passingTitleLabel)
    passingTitleLabel.topToBottom(of: introduceImagesView, offset: CONTENT_SPACE)
    passingTitleLabel.leftToSuperview(offset: 10.0)
    passingTitleLabel.rightToSuperview(offset: 10.0)
    self.passingTitleLabel = passingTitleLabel
    
    //passingBG
    let passingBG = UIView()
    passingBG.backgroundColor = ANIColor.lightGray
    passingBG.layer.cornerRadius = 10.0
    passingBG.layer.masksToBounds = true
    contentView.addSubview(passingBG)
    passingBG.topToBottom(of: passingTitleLabel, offset: 10.0)
    passingBG.leftToSuperview(offset: 10.0)
    passingBG.rightToSuperview(offset: 10.0)
    passingBG.bottomToSuperview(offset: -10.0 - 10.0 - ANIRecruitDetailViewController.APPLY_BUTTON_HEIGHT)
    self.passingBG = passingBG
    
    //passingLabel
    let passingLabel = UILabel()
    passingLabel.font = UIFont.systemFont(ofSize: 15.0)
    passingLabel.textColor = ANIColor.dark
    passingLabel.numberOfLines = 0
    passingBG.addSubview(passingLabel)
    passingLabel.edgesToSuperview(insets: insets)
    self.passingLabel = passingLabel
  }
  
  private func reloadLayout() {
    guard let testRecruit = self.testRecruit,
          let headerImageView = self.headerImageView,
          let titleLabel = self.titleLabel,
          let profileImageView = self.profileImageView,
          let basicInfoKindLabel = self.basicInfoKindLabel,
          let basicInfoAgeLabel = self.basicInfoAgeLabel,
          let basicInfoSexLabel = self.basicInfoSexLabel,
          let basicInfoHomeLabel = self.basicInfoHomeLabel,
          let basicInfoVaccineLabel = self.basicInfoVaccineLabel,
          let basicInfoCastrationLabel = self.basicInfoCastrationLabel,
          let reasonLabel = self.reasonLabel,
          let introduceLabel = self.introduceLabel,
          let passingLabel = self.passingLabel else { return }
    
    headerImageView.image = testRecruit.recruitImage
    
    titleLabel.text = testRecruit.title
    
    profileImageView.image = testRecruit.user.profileImage
    
    userNameLabel?.text = testRecruit.user.name
    
    basicInfoKindLabel.text = "種類：\(testBasicInfo["kind"] ?? "")"
    basicInfoAgeLabel.text = "年齢：\(testBasicInfo["age"] ?? "")"
    basicInfoSexLabel.text = "性別：\(testBasicInfo["sex"] ?? "")"
    basicInfoHomeLabel.text = "お家：\(testBasicInfo["home"] ?? "")"
    basicInfoVaccineLabel.text = "ワクチン：\(testBasicInfo["vaccine"] ?? "")"
    basicInfoCastrationLabel.text = "去勢生：\(testBasicInfo["castration"] ?? "")"
    
    reasonLabel.text = testRecruit.subTitle
    introduceLabel.text = "人懐こくて甘えん坊の可愛い子猫です。\n元気よくご飯もいっぱいたべます😍\n遊ぶのが大好きであっちこっち走り回る姿がたまらなく可愛いです。"
    
    passingLabel.text = "ご自宅までお届けします。"
  }
  
  private func setTestBasicInfo() {
    let kind = "ミックス"
    let age = "6ヶ月"
    let sex = "男の子"
    let home = "東京都"
    let vaccine = "済み"
    let castration = "済み"
    
    testBasicInfo = ["kind":kind, "age":age, "sex":sex, "home":home, "vaccine":vaccine, "castration":castration]
  }
  
  private func setTestIntroduceImages() {
    let image1 = UIImage(named: "detailCat1")!
    let image2 = UIImage(named: "detailCat2")!
    let image3 = UIImage(named: "detailCat3")!
    let image4 = UIImage(named: "detailCat4")!

    testIntroduceImages = [image1, image2, image3, image4]
  }
}

extension ANIRecruitDetailView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let imageView = self.headerImageView,
          let imageViewTopConstraint = self.headerImageViewTopConstraint,
          let headerMinHeight = self.headerMinHeight
          else { return }
    
    let headerImageViewHeight: CGFloat = UIScreen.main.bounds.width * UIViewController.HEADER_IMAGE_VIEW_RATIO

    let scrollY = scrollView.contentOffset.y
    let newScrollY = scrollY + headerImageViewHeight
    
    //imageView animation
    if newScrollY < 0 {
      let scaleRatio = 1 - newScrollY / headerImageViewHeight
      imageView.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
      imageViewTopConstraint.constant = 0
    }
    else {
      imageView.transform = CGAffineTransform.identity
      if headerImageViewHeight - newScrollY > headerMinHeight {
        imageViewTopConstraint.constant = -newScrollY
        self.layoutIfNeeded()
      } else {
        imageViewTopConstraint.constant = -(headerImageViewHeight - headerMinHeight)
        self.layoutIfNeeded()
      }
    }
    
    //navigation bar animation
    let offset = newScrollY / (headerImageViewHeight - headerMinHeight)
    self.delegate?.recruitDetailViewDidScroll(offset: offset)
  }
}
