//
//  UserDefaultWrapper.swift
//  Bags Tracker
//
//  Created by Mixaill on 28.01.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

/**
 Example of use
 @UserDefault(key: .firstStart, defaultValue: true) var theFlag
 @UserDefaultOptionl<String>(key: .aString, defaultValue: nil) var someString
 @UserDefaultOptionl<Bool>(key: .aBool, defaultValue: nil) var aFlag
 @UserDefaultOptionl(key: .theString, defaultValue: "r") var theString
 */

import Foundation

@propertyWrapper
struct UserDefault<T> {
  enum Key: String {
    case firstStart = "kFirstStart"
    case testDF = "kTestDF"
  }
  
  let userDefaults: UserDefaults
  let key: Key
  let defaultValue: T
  
    init(userDefaults: UserDefaults = Foundation.UserDefaults.standard,
       key: Key,
       defaultValue: T) {
    self.userDefaults = userDefaults
    self.key = key
    self.defaultValue = defaultValue
  }
  
  var wrappedValue: T {
    get { return userDefaults.object(forKey: key.rawValue) as? T ?? defaultValue }
    set { userDefaults.set(newValue, forKey: key.rawValue) }
  }
}

@propertyWrapper
struct UserDefaultOptionl<T> {
  enum Key: String {
    case deviceId = "kDeviceId"
  }
  
  let userDefaults: UserDefaults
  let key: Key
  let defaultValue: T?
  
    init(userDefaults: UserDefaults = Foundation.UserDefaults.standard,
       key: Key,
       defaultValue: T?) {
    self.userDefaults = userDefaults
    self.key = key
    self.defaultValue = defaultValue
  }
  
  var wrappedValue: T? {
    get { return userDefaults.object(forKey: key.rawValue) as? T ?? defaultValue }
    set { userDefaults.set(newValue, forKey: key.rawValue) }
  }
}
