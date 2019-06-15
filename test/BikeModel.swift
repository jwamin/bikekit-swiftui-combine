//
//  BikeModel.swift
//  BikeKitSwiftCombine
//
//  Created by Joss Manger on 6/12/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SwiftUI
import Combine

class Favourites : BindableObject, Subscriber {
    
    func receive(_ input: ([NYCBikeStationInfo]?, [NYCBikeStationStatus]?)) -> Subscribers.Demand {
        let tuple = input
        let info = tuple.0!
        let status = tuple.1!
        
        var newInfo = [NYCFullBikeInfo]()
        
        for station in info {
            if let statusForStation = status.first(where: { (status) -> Bool in
                status.station_id == station.station_id
            }) {
                var copy = NYCFullBikeInfo.initWithInfo(info: station, status: statusForStation)
                newInfo.append(copy)
            }
            
        }
        
        self.stationsWithData = newInfo
        
        return Subscribers.Demand.none
    }
    
    func receive(completion: Subscribers.Completion<Error>) {
        print(completion)
    }
    
    
    func receive(subscription: Subscription) {
        subscription.request(Subscribers.Demand.max(1))
    }
    
    
    typealias Input = ([NYCBikeStationInfo]?,[NYCBikeStationStatus]?)
    
    typealias Failure = Error
    
    
    var didChange = PassthroughSubject<Bool,Never>()
    
    var stationsWithData:[NYCFullBikeInfo] = []{
        didSet{
            print(stationsWithData.count)
            self.didChange.send(true)
        }
    }
    
    init(){

        refresh()
        
    }
    
    func refresh(){
        print("refresh called")
        let infoRequest = URLRequest(url: Urls.STATION_INFO_URL)
        let statusRequest = URLRequest(url: Urls.STATION_STATUS_URL)
        
        let infoStream = URLSession.shared.send(request:infoRequest).eraseToAnyPublisher().decode(type: NYCStationInfoWrapper.self, decoder: JSONDecoder())
            .map{ data in
                data.data["stations"]
            }
            //.eraseToAnyPublisher()
        
        let statusStream = URLSession.shared.send(request:statusRequest)
            .decode(type: NYCStationStatusWrapper.self, decoder: JSONDecoder())
            .map{ data in
                data.data["stations"]
            }
            //.eraseToAnyPublisher()
        
            var zipped = Publishers.Zip(infoStream, statusStream)
                
                zipped.eraseToAnyPublisher().subscribe(self)
        
        
    }
    
    
}

class DummyData : Favourites {
    
    override func refresh(){
        stationsWithData = testData
    }
    
}


    

        
        

