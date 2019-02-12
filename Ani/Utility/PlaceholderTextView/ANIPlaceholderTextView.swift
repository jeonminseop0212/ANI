//
//  PlaceholderTextView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/14.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

public class ANIPlaceHolderTextView: UITextView {
  
  lazy var placeHolderLabel: UILabel = UILabel()
  var placeHolderColor: UIColor = .lightGray
  var placeHolder: NSString = ""
  
  public override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    
    setupNotifications()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupNotifications() {
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
    
    self.sendSubviewToBack(placeHolderLabel)
    
    if self.text.utf16.count == 0 && self.placeHolder.length > 0 {
      self.viewWithTag(1)?.alpha = 1
    }
  }
  
  @objc public func textChanged(notification:NSNotification?) -> (Void) {
    if self.placeHolder.length == 0 {
      return
    }
    
    if self.text.utf16.count == 0 {
      self.viewWithTag(1)?.alpha = 1
    } else {
      self.viewWithTag(1)?.alpha = 0
    }
  }
  
  func showPlaceHolder() {
    self.viewWithTag(1)?.alpha = 1
  }
  
  func resolveHashTags(text: String, hashtagArray: [String]) {
    var nsText: NSString = text as NSString

    var ranges = [NSRange]()
    for (index, var word) in hashtagArray.enumerated() {
      if index == 0 {
        word = "#" + word
        if word.hasPrefix("#") {
          var range = nsText.range(of: word as String)
          if !ranges.isEmpty, let lastRage = ranges.last {
            range = NSRange(location: lastRage.upperBound + range.lowerBound, length: word.count)
          }
          
          ranges.append(range)
          
          nsText = text[text.index(text.startIndex, offsetBy: range.upperBound)...] as NSString
        }
      } else {
        word = " #" + word
        if word.hasPrefix(" #") {
          var range = nsText.range(of: word as String)
          if !ranges.isEmpty, let lastRage = ranges.last {
            range = NSRange(location: lastRage.upperBound + range.lowerBound, length: word.count)
          }
          
          ranges.append(range)
          
          nsText = text[text.index(text.startIndex, offsetBy: range.upperBound)...] as NSString
        }
      }
    }
    
    let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0), NSAttributedString.Key.foregroundColor: ANIColor.dark]

    let attrString = NSMutableAttributedString(string: text, attributes: attrs)

    if(ranges.count != 0) {
      var i = 0
      for range in ranges {
        attrString.addAttribute(NSAttributedString.Key.link, value: "\(i):", range: range)
        i += 1
      }
    }
    
    let cursorPoint = getCursorPosition()

    self.attributedText = attrString
    
    updateCursorPoint(cursorPoint: cursorPoint)
  }
  
  private func getCursorPosition() -> Int {
    if let selectedRange = self.selectedTextRange {
      let cursorPosition = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
      
      return cursorPosition
    }
    
    return 0
  }
  
  private func updateCursorPoint(cursorPoint: Int) {
    if let newPosition = self.position(from: self.beginningOfDocument, offset: cursorPoint) {
      self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
    }
  }
}
