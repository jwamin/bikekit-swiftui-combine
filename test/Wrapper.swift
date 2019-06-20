//
//  Wrapper.swift
//  BikeTestSwiftUICombine
//
//  Created by Joss Manger on 6/20/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
  let key: String
  let defaultValue: T
  
  init(_ key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
  
  var value: T {
    get {
      return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
    }
    set {
      UserDefaults.standard.set(newValue, forKey: key)
    }
  }
}
