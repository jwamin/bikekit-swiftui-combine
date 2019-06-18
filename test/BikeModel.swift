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
    
    let infoRequest = URLRequest(url: Urls.STATION_INFO_URL)
    let statusRequest = URLRequest(url: Urls.STATION_STATUS_URL)
    let decoder = JSONDecoder()
    
    let infoStream:AnyPublisher<[NYCBikeStationInfo]?, Error>
    
    var didChange = PassthroughSubject<Bool,Never>()
    
    var stationData:[NYCFullBikeInfo] = []{
        didSet{
            print(stationData.count)
            self.didChange.send(true)
        }
    }
    
    init(){
        infoStream = URLSession.shared.send(request:infoRequest)
            .decode(type: NYCStationInfoWrapper.self, decoder: decoder)
            .map{ decoded in
                decoded.data["stations"]
            }
            .eraseToAnyPublisher()
        
        refresh()
        
    }
    
    
    /// Perform two URLRequests, process with combine and publish to subscriber (self)
    func refresh(){
        
        let statusStream = URLSession.shared.send(request:statusRequest)
            .decode(type: NYCStationStatusWrapper.self, decoder: decoder)
            .map{ decoded in
                decoded.data["stations"]
            }
            .eraseToAnyPublisher()
        
        
        let zipped = Publishers.Zip(infoStream,statusStream)
        
        zipped.eraseToAnyPublisher().subscribe(self)
    }
    
    
}

extension JSONDecoder: TopLevelDecoder {  }



extension StationDataModel : Subscriber{
    
    typealias Input = ([NYCBikeStationInfo]?,[NYCBikeStationStatus]?)
    
    typealias Failure = Error
    
    func receive(_ input: ([NYCBikeStationInfo]?, [NYCBikeStationStatus]?)) -> Subscribers.Demand {
        
        let tuple = input
        let info = tuple.0!
        let status = tuple.1!
        
        var newInfo = [NYCFullBikeInfo]()
        
        for station in info {
            if let statusForStation = status.first(where: { (status) -> Bool in
                status.station_id == station.station_id
            }) {
                let copy = NYCFullBikeInfo.initWithInfo(info: station, status: statusForStation)
                newInfo.append(copy)
            }
            
        }
        
        self.stationData = newInfo
        return Subscribers.Demand.none
    }
    
    func receive(completion: Subscribers.Completion<Error>) {
        
        print(completion)
    }
    
    
    func receive(subscription: Subscription) {
        
        subscription.request(Subscribers.Demand.max(1))
    }
    
}


class DummyData : StationDataModel {
    
    override func refresh(){
        stationData = testData
    }
    
}







