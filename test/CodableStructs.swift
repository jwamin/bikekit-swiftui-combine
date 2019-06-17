//
//  NYCBikeCodableData.swift
//  BikeKit
//
//  Created by Joss Manger on 5/15/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SwiftUI
import CoreLocation

//TODO: update structures to reflect optional attributes on https://github.com/NABSA/gbfs/blob/master/gbfs.md

protocol GBFS : Codable { }

extension GBFS {
    public init(_ any: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: any, options: .prettyPrinted)
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}

struct NYCStationInfoWrapper : GBFS {
    let last_updated:Date
    let data:[String:[NYCBikeStationInfo]]
}

struct NYCStationStatusWrapper : GBFS{
    let last_updated:Date
    let data:[String:[NYCBikeStationStatus]]
}


public struct NYCFullBikeInfo : GBFS, Identifiable{
    
    
    
    
    static func initWithInfo(info:NYCBikeStationInfo, status:NYCBikeStationStatus) -> Self{
        
        return NYCFullBikeInfo(station_id: info.station_id, external_id: info.external_id, name: info.name, short_name: info.short_name, lat: info.lat, lon: info.lon, region_id: info.region_id, rental_methods: info.rental_methods, capacity: info.capacity, rental_url: info.rental_url, electric_bike_surcharge_waiver: info.electric_bike_surcharge_waiver, eightd_has_key_dispenser: info.eightd_has_key_dispenser, status: status)
        
    }
    
    public var id:String {
        return name
    }
    
    public let station_id:String
    public let external_id:String
    public let name:String
    public let short_name:String?
    public let lat:Double
    public let lon:Double
    public let region_id:Int?
    public let rental_methods:[RentalMethods]
    public let capacity:Int?
    public let rental_url:URL
    public let electric_bike_surcharge_waiver:Bool
    public let eightd_has_key_dispenser:Bool
    public var status:NYCBikeStationStatus
    
    public var coordinate:CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
}

public struct NYCBikeStationInfo:GBFS, Identifiable {
    
    public var id:String {
        return name
    }
    
    public let station_id:String
    public let external_id:String
    public let name:String
    public let short_name:String?
    public let lat:Double
    public let lon:Double
    public let region_id:Int?
    public let rental_methods:[RentalMethods]
    public let capacity:Int?
    public let rental_url:URL
    public let electric_bike_surcharge_waiver:Bool
    public let eightd_has_key_dispenser:Bool
    public var status:NYCBikeStationStatus?
    
    public var coordinate:CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    public func statusString()->String{
        guard let status = self.status else {
            return ""
        }
        return "bikes available: \(status.num_bikes_available), docks: \(status.num_docks_available), disabled: \(status.num_bikes_disabled!), electric bikes avalable: \(status.num_ebikes_available), electric bike waiver: \(self.electric_bike_surcharge_waiver)"
    }
    
}

public enum RentalMethods : String, GBFS {
    case key = "KEY"
    case creditCard = "CREDITCARD"
    case paypass = "PAYPASS"
    case applePay = "APPLEPAY"
    case androidPay = "ANDROIDPAY"
    case transitCard = "TRANSITCARD"
    case accountNumber = "ACCOUNTNUMBER"
    case phone = "PHONE"
}

//{"station_id":"304","num_bikes_available":6,"num_ebikes_available":0,"num_bikes_disabled":1,"num_docks_available":26,"num_docks_disabled":0,"is_installed":1,"is_renting":1,"is_returning":0,"last_reported":1557248000,"eightd_has_available_keys":true,"eightd_active_station_services":[{"id":"a58d9e34-2f28-40eb-b4a6-c8c01375657a"}]},

public struct NYCBikeStationStatus : GBFS{
    
    public let station_id:String
    public let num_bikes_available:Int
    public let num_ebikes_available:Int
    public let num_bikes_disabled:Int?
    public let num_docks_disabled:Int?
    public let num_docks_available:Int
    public let is_installed:Int
    public let is_renting:Int
    public let is_returning:Int
    public let last_reported:Date
    
}

public struct NYCStationWatchStruct : GBFS {
    
    public init(stationId:String,name:String,bikes:String,docks:String,lat:Double,lng:Double) {
        self.name = name
        self.stationId = stationId
        self.bikes = bikes
        self.docks = docks
        self.lat = lat
        self.lng = lng
    }
    
    public mutating func setExtraData(electric:String,disabled:String){
        self.electric = electric
        self.disabled = disabled
    }
    
    public let stationId:String
    public let name:String
    public let bikes:String
    public let docks:String
    public let lat:Double
    public let lng:Double
    public private(set) var electric:String?
    public private(set) var disabled:String?
    
    public init(_ any: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: any, options: .prettyPrinted)
        print(data)
        let decoder = JSONDecoder()
        self = try decoder.decode(NYCStationWatchStruct.self, from: data)
    }
    
}

public struct NYCStationWatchEncodingModel : GBFS {
    
    public init(stationId:String,name:String,bikes:Int,docks:Int,lat:Double,lng:Double,electric:Int,disabled:Int) {
        self.name = name
        self.stationId = stationId
        self.bikes = bikes
        self.docks = docks
        self.lat = lat
        self.lng = lng
        self.electric = electric
        self.disabled = disabled
    }
    
    public let stationId:String
    public let name:String
    public let bikes:Int
    public let docks:Int
    public let lat:Double
    public let lng:Double
    public private(set) var electric:Int
    public private(set) var disabled:Int
    
}


