//
//  ANIFirebaseRemoteConfigManager.swift
//  Ani
//
//  Created by jeonminseop on 2018/11/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

class ANIFirebaseRemoteConfigManager: ANIFirebase {
  static let shared = ANIFirebaseRemoteConfigManager()
  
  private let dispatchGroup = DispatchGroup()
  private let dispatchQueue = DispatchQueue(label: "queue")
  
  private var config: RemoteConfig?
  
  private var expirationDuration: TimeInterval { return (self.config?.configSettings.isDeveloperModeEnabled ?? true) ? 0 : 3600}
  
  private override init() {
    super.init()
    self.config = RemoteConfig.remoteConfig()
    if IS_DEBUG, let configSetting = RemoteConfigSettings(developerModeEnabled: true){
      self.config?.configSettings = configSetting
    }
  }
  
  func fetch(){
    dispatchGroup.enter()
    dispatchQueue.async(group: dispatchGroup) { [weak self] in
      guard let remoteConfig = self else {
        DLog("async error")
        self?.dispatchGroup.leave()
        return
      }
      
      remoteConfig.config?.fetch(withExpirationDuration: remoteConfig.expirationDuration, completionHandler: { (status, error) in
        if let error = error{
          DLog(error.localizedDescription)
          remoteConfig.dispatchGroup.leave()
          return
        }
        if status != .success {
          DLog("status is \(status)")
          remoteConfig.dispatchGroup.leave()
          return
        }
        remoteConfig.config?.activateFetched()
        remoteConfig.dispatchGroup.leave()
      })
    }
  }
  
  func getSirenAlertType(completion: ((String?, Error?)->())? = nil) {
    dispatchGroup.notify(queue: .main) {
      let DEF_TYPE = "skip"
      guard let config = self.config else{
        completion?(DEF_TYPE, NSError.init(domain: "config is nill", code: -1, userInfo: nil))
        return
      }
      
      if let remoteConfigText = config[KEY_SIREN_ALERT_TYPE].stringValue, remoteConfigText.count == 0 {
        completion?(DEF_TYPE,nil)
      } else {
        completion?(config[KEY_SIREN_ALERT_TYPE].stringValue ?? DEF_TYPE, nil)
      }
    }
  }
}
