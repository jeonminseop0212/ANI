//
//  ANIActivityItemSorce.swift
//  Ani
//
//  Created by jeonminseop on 2019/12/16.
//  Copyright © 2019 JeonMinseop. All rights reserved.
//

import UIKit

class ANIActivityItemSorce: NSObject, UIActivityItemSource {
  var shareContent: String?
  var image: UIImage?

  init(shareContent: String?, image: UIImage? = nil) {
      self.shareContent = shareContent
      self.image = image
  }

  // デフォルトのアイテム
  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    return self.shareContent as Any
  }

  // アプリ選択時に呼ばれる
  func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
      switch activityType {
      case UIActivity.ActivityType.postToFacebook:
          return self.shareContent
      case UIActivity.ActivityType.postToTwitter:
        return self.shareContent
      default:
        switch activityType?.rawValue {
        case "com.burbn.instagram.shareextension":
          return self.image
        case "jp.naver.line.Share":
          return self.shareContent
        default:
            return shareContent
        }
      }
    }
}
