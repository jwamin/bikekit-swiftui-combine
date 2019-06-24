//
//  CombineDemoEventTracker.swift
//  BikeTestSwiftUICombine
//
//  Created by Joss Manger on 6/24/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation


protocol ProcessDelegate{
  func updated()
}

class Processes {
  
  var delegate:ProcessDelegate?
  private var processHits = [ProcessType:Int](){
    didSet{
      print(self.getString())
      DispatchQueue.main.async {
        self.delegate?.updated()
      }
    }
  }
  
  init(){
    
    processHits[.refresh] = 0
    processHits[.combineLatest] = 0
    processHits[.response] = 0
    print(processHits)
  }
  
  public func increment(type:ProcessType){
    guard let currentValue = processHits[type] else {
      return
    }
    processHits[type] = currentValue + 1
  }
  
  public func getString()->String{
    guard let refreshes = processHits[.refresh], let combineLatestCalls = processHits[.combineLatest], let responses = processHits[.response] else {
      return ""
    }
    
    return "Responses: \(responses)\nCalls to CombineLatest: \(combineLatestCalls)\nRefreshed: \(refreshes)"
    
  }
  
}

public enum ProcessType{
  case combineLatest
  case response
  case refresh
}


