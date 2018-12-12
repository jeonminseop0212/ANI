//
//  ANIActivityIndicator.swift
//  Ani
//
//  Created by jeonminseop on 2018/12/11.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIActivityIndicator: UIView {
  
  private let imageNames: [String] = ["splashFoot1", "splashFoot2", "splashFoot3", "splashFoot4", "splashFoot5"]
  private var imageViews: [UIImageView]?
  
  var isAnimatedOneCycle: Bool = false {
    didSet {
      ANINotificationManager.postDismissSplash()
    }
  }
  var isSplash: Bool = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    for imageName in imageNames {
      let imageView = UIImageView()
      imageView.contentMode = .scaleAspectFit
      imageView.alpha = 0.0
      imageView.image = UIImage(named: imageName)
      if self.imageViews != nil {
        self.imageViews?.append(imageView)
      } else {
        self.imageViews = [imageView]
      }
      self.addSubview(imageView)
      imageView.edgesToSuperview()
    }
  }
  
  func startAnimating() {
    self.roofAnimation()
  }
  
  func stopAnimaing() {
    self.subviews.forEach({
      $0.layer.removeAllAnimations()
      $0.layoutIfNeeded()
    })
  }
  
  private func animation(index: Int, completion:(()->())?) {
    guard let imageViews = self.imageViews else { return }

    UIView.animate(withDuration: 0.3, animations: {
      if imageViews.count > index {
        imageViews[index].alpha = 1.0
      }
    }) { (complete) in
      completion?()
    }
  }
  
  private func roofAnimation(isFirst: Bool = true) {
    guard let imageViews = self.imageViews else { return }

    let duration = isFirst ? 0.0 : 0.3
    UIView.animate(withDuration: duration, animations: {
      for imageView in imageViews {
        imageView.alpha = 0.0
      }
    }) { (complete) in
      self.animation(index: 0, completion: {
        self.animation(index: 1, completion: {
          self.animation(index: 2, completion: {
            self.animation(index: 3, completion: {
              self.animation(index: 4, completion: {
                if self.isSplash {
                  self.isAnimatedOneCycle = true
                }
                self.roofAnimation(isFirst: false)
              })
            })
          })
        })
      })
    }
  }
}
