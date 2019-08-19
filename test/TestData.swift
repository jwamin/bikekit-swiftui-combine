//
//  TestData.swift
//  test
//
//  Created by Joss Manger on 6/12/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SwiftUI
import Combine

var testData:[GBFSFullBikeInfo] = {
    
    var newInfo = [GBFSFullBikeInfo]()
    
    let infoStream = load(file: "data/stations.json").decode(type: GBFSStationInfoWrapper.self, decoder: JSONDecoder())
        .map{ data in
            data.data["stations"]
        }.assertNoFailure()
        .eraseToAnyPublisher()
    
    let statusStream = load(file:"data/status.json").decode(type: GBFSStationStatusWrapper.self, decoder: JSONDecoder())
        .map{ data in
            data.data["stations"]
      }.assertNoFailure()
        .eraseToAnyPublisher()
    
  _ = Publishers.Zip(infoStream, statusStream).sink { tuple in
        let info = tuple.0!
        let status = tuple.1!
        
        for station in info {
            if let updateStation = status.first(where: { (status) -> Bool in
                status.station_id == station.station_id
            }) {
                var copy = GBFSFullBikeInfo.initWithInfo(info: station, status: updateStation)
                newInfo.append(copy)
            }
            
        }
        
    }
    
    return newInfo
    
}()



func load(file:String)->AnyPublisher<Data,Never>{
    
    let file = Bundle.main.url(forResource: file, withExtension: nil)!
    
    let data = try! Data(contentsOf: file)
    
    return Just(data).eraseToAnyPublisher()
    
}
