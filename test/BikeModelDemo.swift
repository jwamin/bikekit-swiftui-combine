//
//  BikeModel.swift
//  BikeKitSwiftCombine
//
//  Created by Joss Manger on 6/12/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SwiftUI
import Combine

class StationDataModel : BindableObject {
  
  //Requests
  let infoRequest = URLRequest(url: Urls.STATION_INFO_URL)
  let statusRequest = URLRequest(url: Urls.STATION_STATUS_URL)
  
  //Notifications
  let statusNotification:Notification.Name = Notification.Name("statusUpdated")
  let infoNotification:Notification.Name = Notification.Name("infoUpdated")
  let refreshNotification:Notification.Name = Notification.Name("refreshCalled")
  
  //Shared Decoder
  let decoder = JSONDecoder()
  
  //Streams
  var refreshStream: AnySubscriber<NotificationCenter.Publisher.Output, NotificationCenter.Publisher.Failure>?
  var infoStream:AnyPublisher<[NYCBikeStationInfo]?, Error>?
  var statusStream:AnyPublisher<[NYCBikeStationStatus]?, Error>?
  
  //Subject for SwiftUI notification
  var didChange = PassthroughSubject<Bool,Never>()
  
  //Actual Model data with property observer
  var stationData:[NYCFullBikeInfo] = []{
    didSet{
      
      print(stationData.count)
      self.didChange.send(true)
    }
  }
  
  init(){
    
    setupStreams()
    refresh()
  }
  
  /// Sets up Combine Streams, Station info stream, station status stream and refresh button pressed stream
  func setupStreams(){
    
    //Main information stream, will complete once
    infoStream = URLSession.shared.dataTaskPublisher(for: infoRequest)
      .map{
        $0.data
      }
      .decode(type: NYCStationInfoWrapper.self, decoder: decoder)
      .map{ decoded in
        decoded.data["stations"]
      }
      .eraseToAnyPublisher()
    
    //listens for push on refresh button and debounces
    refreshStream = NotificationCenter.default.publisher(for: refreshNotification, object: self)
      .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
      .sink { (notification) in
        _ = URLSession.shared.dataTaskPublisher(for: self.statusRequest)
          .sink{ info in
            let userinfo = ["data":info.data]
            NotificationCenter.default.post(name: self.statusNotification, object: self, userInfo: userinfo)
        }
      }.eraseToAnySubscriber()
    
    //processes the result of status update // THIS IS WHAT I WAS PERHAPS PLANNING TO DO IN THE DEMO
    statusStream = NotificationCenter.default.publisher(for: statusNotification, object: self)
      .compactMap{ note in
        note.userInfo?["data"] as? Data
      }
      .decode(type: NYCStationStatusWrapper.self, decoder: decoder)
      .map{ decoded in
        decoded.data["stations"]
      }
      .eraseToAnyPublisher()
    
    //Combine publishers with combine latest
    _ = Publishers.CombineLatest(infoStream,statusStream){
      ($0,$1)
      }
      .assertNoFailure()
      .map { info,status in
        
        var newInfo = [NYCFullBikeInfo]()
        
        for station in info! {
          
          if let statusForStation = status!.first(where: { (status) -> Bool in
            status.station_id == station.station_id
          }) {
            let copy = NYCFullBikeInfo.initWithInfo(info: station, status: statusForStation)
            newInfo.append(copy)
          }
        }
        
        return newInfo
      }.receive(on: RunLoop.main).assign(to: \.stationData, on: self)
    
  }
  
  /// Publishes refresh notification on button press
  func refresh(){
    
    NotificationCenter.default.post(name: refreshNotification, object: self)
  }
  
}

class DummyData : StationDataModel {
  
  override func refresh(){
    stationData = testData
  }
  
}







