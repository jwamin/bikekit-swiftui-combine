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
  
  @UserDefault("favourites", defaultValue: ["281"])
  var favourites:[String]
  
  //tracker
  var processes:Processes? = Processes()
  
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
  var infoStream:AnyPublisher<[GBFSBikeStationInfo]?, Error>?
  var statusStream:AnyPublisher<[GBFSBikeStationStatus]?, Error>!
  
  //Subject for SwiftUI notification
  var didChange = PassthroughSubject<Void,Never>()
  
  //Actual Model data with property observer
  var stationData:[GBFSFullBikeInfo] = []{
    didSet{
      
      print(stationData.count)
      self.didChange.send()
    }
  }
  
  init(){
    
    processes?.delegate = self
    
    //Setup Streams
    setupRefreshAndInfoStreams()
    setupStatusStream()
    setupCombineLatest()
    
    //Call initial refresh
    refresh()
    
  }
  
  func setupStatusStream(){
    
    //TODO: process the result of status request
//    let statusStream = NotificationCenter.default.publisher(for: statusNotification, object: self)
//      .compactMap{ note in
//        note.userInfo?["data"] as? Data
//    }
//      .decode(type: GBFSStationStatusWrapper.self, decoder: decoder)
//      .map{ decoded in
//        decoded.data["stations"]
//    }
//      .eraseToAnyPublisher()
//    
//    self.statusStream = statusStream


  }

  
  
  private func setupCombineLatest(){
    
    //Combine publishers with combine latest
    _ = Publishers.CombineLatest(infoStream,statusStream){
      ($0,$1)
      }
      .assertNoFailure()
      .map { info,status in
        self.processes?.increment(type: .combineLatest)
        var newInfo = [GBFSFullBikeInfo]()
        
        for station in info! {
          
          if let statusForStation = status!.first(where: { (status) -> Bool in
            status.station_id == station.station_id
          }) {
            var copy = GBFSFullBikeInfo.initWithInfo(info: station, status: statusForStation)
            copy.isFavourite = {
              self.favourites.contains(copy.station_id)
            }()
            newInfo.append(copy)
          }
        }
        
        return newInfo
      }.receive(on: RunLoop.main).assign(to: \.stationData, on: self)
  }
  
  
  
  
  /// Sets up Combine Streams, Station info stream, station status stream and refresh button pressed stream
  private func setupRefreshAndInfoStreams(){
    
    //Main information stream, will complete once
    infoStream = URLSession.shared.dataTaskPublisher(for: infoRequest)
      .map{
        self.processes?.increment(type: .response)
        return $0.data
      }
      .decode(type: GBFSStationInfoWrapper.self, decoder: decoder)
      .map{ decoded in
        decoded.data["stations"]
      }
      .eraseToAnyPublisher()
    
    //listens for push on refresh button and debounces
    refreshStream = NotificationCenter.default.publisher(for: refreshNotification, object: self)
      .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
      .sink { (notification) in
        self.processes?.increment(type: .refresh)
        _ = URLSession.shared.dataTaskPublisher(for: self.statusRequest)
          .sink{ info in
            self.processes?.increment(type: .response)
            let userinfo = ["data":info.data]
            NotificationCenter.default.post(name: self.statusNotification, object: self, userInfo: userinfo)
        }
      }.eraseToAnySubscriber()
    
    
  }
  
  /// Publishes refresh notification on button press
  func refresh(){
    
    NotificationCenter.default.post(name: refreshNotification, object: self)
  }
  
  func localFavourites(index:String){
    
    var copyFavourites = favourites
    
    if(copyFavourites.contains(index)){
      copyFavourites.removeAll(where: { str in
        str == index
      })
    } else {
      copyFavourites.append(index)
    }
    
    favourites = copyFavourites
    
  }
  
  
}

extension StationDataModel : ProcessDelegate{
  
  func updated() {
    didChange.send()
  }
  
}

class DummyData : StationDataModel {
  
  override func refresh(){
    stationData = testData
  }
  
}
