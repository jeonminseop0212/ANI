//
//  URL.swift
//  Ani
//
//  Created by jeonminseop on 2018/12/18.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

extension URL {
  func appendingUniquePathComponent(pathExtension: String? = nil) -> URL {
    var pathComponent = UUID().uuidString
    if let pathExtension = pathExtension {
      pathComponent += ".\(pathExtension)"
    }
    return appendingPathComponent(pathComponent)
  }
  
  func queryValue(for key: String) -> String? {
      let queryItems = URLComponents(string: absoluteString)?.queryItems
      return queryItems?.filter { $0.name == key }.compactMap { $0.value }.first
  }
}
