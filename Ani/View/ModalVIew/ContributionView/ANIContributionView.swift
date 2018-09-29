//
//  ANIContributionView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIContributionViewDelegate {
  func imagesPickCellTapped()
  func imageDeleteButtonTapped(index: Int)
  func contributionButtonOn(on: Bool)
}

class ANIContributionView: UIView {
  
  private weak var scrollView: ANIScrollView?
  private weak var contentView: UIView?
  
  private weak var contentTextView: ANIPlaceHolderTextView?
  private let CONTENT_IMAGES_VIEW_RATIO: CGFloat = 0.5
  private weak var contentImagesView: ANIContributionImagesView?
  
  var contentImages = [UIImage?]() {
    didSet {
      guard let contentImagesView = self.contentImagesView else { return }
      
      contentImagesView.contentImages = contentImages
      
      if isContributable() {
        self.delegate?.contributionButtonOn(on: true)
      } else {
        self.delegate?.contributionButtonOn(on: false)
      }
    }
  }
  
  var selectedContributionMode: ContributionMode? {
    didSet {
      guard let selectedContributionMode = self.selectedContributionMode,
            let contentTextView = self.contentTextView else { return }
      
      if selectedContributionMode == .story {
        contentTextView.placeHolder = "どんな話でも大丈夫です*^_^*"
      } else if selectedContributionMode == .qna {
        contentTextView.placeHolder = "どんな質問でも大丈夫です*^_^*"
      }
    }
  }
  
  private let KEYBOARD_HIDE_TOOL_BAR_HEIGHT: CGFloat = 40.0
  
  var delegate: ANIContributionViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //scrollView
    let scrollView = ANIScrollView()
    addSubview(scrollView)
    scrollView.edgesToSuperview()
    self.scrollView = scrollView
    
    //contentView
    let contentView = UIView()
    scrollView.addSubview(contentView)
    contentView.edgesToSuperview()
    contentView.width(to: scrollView)
    self.contentView = contentView
    
    //contentTextView
    let contentTextView = ANIPlaceHolderTextView()
    contentTextView.textColor = ANIColor.dark
    contentTextView.font = UIFont.systemFont(ofSize: 17.0)
    contentTextView.isScrollEnabled = false
    contentTextView.delegate = self
    contentView.addSubview(contentTextView)
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: -10.0, right: 10.0)
    contentTextView.edgesToSuperview(excluding: .bottom, insets: insets)
    self.contentTextView = contentTextView
    setHideButtonOnKeyboard(textView: contentTextView)
    
    //contentImagesView
    let contentImagesView = ANIContributionImagesView()
    contentImagesView.delegate = self
    contentView.addSubview(contentImagesView)
    contentImagesView.topToBottom(of: contentTextView, offset: 20.0)
    contentImagesView.leftToSuperview()
    contentImagesView.rightToSuperview()
    contentImagesView.height(UIScreen.main.bounds.width * CONTENT_IMAGES_VIEW_RATIO)
    contentImagesView.bottomToSuperview(offset: -10.0)
    self.contentImagesView = contentImagesView
  }
  
  func getContent() -> String {
    guard let contentTextView = self.contentTextView,
          let text = contentTextView.text else { return "" }
    
    return text
  }
  
  private func isContributable() -> Bool {
    guard let selectedContributionMode = self.selectedContributionMode,
          let contentTextView = self.contentTextView else { return false }
    
    switch selectedContributionMode {
    case .story:
      if contentTextView.text.count > 0 && !contentImages.isEmpty {
        return true
      } else {
        return false
      }
    case .qna:
      if contentTextView.text.count > 0 {
        return true
      } else {
        return false
      }
    }
  }
  
  private func setHideButtonOnKeyboard(textView: UITextView){
    let tools = UIToolbar()
    tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: KEYBOARD_HIDE_TOOL_BAR_HEIGHT)
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(keyboardHideButtonTapped))
    tools.items = [spacer, closeButton]
    textView.inputAccessoryView = tools
  }
  
  //MARK: action
  @objc func keyboardHideButtonTapped(){
    self.endEditing(true)
    self.resignFirstResponder()
  }
}

//MARK: ANIContributionImagesViewDelegate
extension ANIContributionView: ANIContributionImagesViewDelegate {
  func imagesPickCellTapped() {
    self.delegate?.imagesPickCellTapped()
  }
  
  func imageDelete(index: Int) {
    contentImages.remove(at: index)
    self.delegate?.imageDeleteButtonTapped(index: index)
  }
}

extension ANIContributionView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    if isContributable() {
      self.delegate?.contributionButtonOn(on: true)
    } else {
      self.delegate?.contributionButtonOn(on: false)
    }
  }
}
