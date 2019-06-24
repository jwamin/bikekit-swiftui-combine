//
//  Wrapper.swift
//  BikeTestSwiftUICombine
//
//  Created by Joss Manger on 6/20/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import SwiftUI

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

struct ActivityView : UIViewRepresentable{
  
  let style:UIActivityIndicatorView.Style = .medium
  
  public func makeUIView(context: UIViewRepresentableContext<ActivityView>) -> UIActivityIndicatorView {
    return UIActivityIndicatorView(style: style)
  }
  
  public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityView>) {
    uiView.startAnimating()
  }
  
}
