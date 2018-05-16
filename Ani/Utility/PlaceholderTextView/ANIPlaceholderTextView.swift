//
//  PlaceholderTextView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/14.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

public class ANIPlaceHolderTextView: UITextView {
  
  lazy var placeHolderLabel:UILabel = UILabel()
  var placeHolderColor:UIColor = .lightGray
  var placeHolder:NSString = ""
  
  public override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    
    setupNotification()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(textViewTextDidChange: self, selector: #selector(textChanged))
  }
  
  deinit {
    ANINotificationManager.remove(self)
  }

  override public func draw(_ rect: CGRect) {
    super.draw(rect)

    if(self.placeHolder.length > 0) {
      self.placeHolderLabel.frame = CGRect(x: 5.0, y: 8.0, width: self.bounds.size.width  - 16.0, height: 0.0)
      self.placeHolderLabel.lineBreakMode = .byWordWrapping
      self.placeHolderLabel.numberOfLines = 0
      self.placeHolderLabel.font = self.font
      self.placeHolderLabel.backgroundColor = .clear
      self.placeHolderLabel.textColor = self.placeHolderColor
      self.placeHolderLabel.alpha = 0.0
      self.placeHolderLabel.tag = 1
      
      self.placeHolderLabel.text = self.placeHolder as String
      self.placeHolderLabel.sizeToFit()
      self.addSubview(placeHolderLabel)
    }
    
    self.sendSubview(toBack: placeHolderLabel)
    
    if(self.text.utf16.count == 0 && self.placeHolder.length > 0){
      self.viewWithTag(1)?.alpha = 1
    }
  }
  
  @objc public func textChanged(notification:NSNotification?) -> (Void) {
    if(self.placeHolder.length == 0){
      return
    }
    
    if(self.text.utf16.count == 0) {
      self.viewWithTag(1)?.alpha = 1
    }else{
      self.viewWithTag(1)?.alpha = 0
    }
  }
}
