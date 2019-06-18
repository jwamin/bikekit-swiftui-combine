//
//  ContentView.swift
//  BikeKitSwiftCombine
//
//  Created by Joss Manger on 6/12/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    
    @ObjectBinding var model:StationDataModel = StationDataModel()
    
    var body: some View {
        NavigationView{ 
            List{
                Section{
                ForEach(model.stationData) { station in
                    NavigationButton(destination:StationDetailView(station:station)){
                        StationCell(model: station)
                    }
                }
                }
            }.navigationBarTitle(Text("Bike Stations"))
                .listStyle(.grouped)
                .navigationBarItems(trailing: Button(action: {self.model.refresh()}, label: {
                    Image(systemName: "arrow.clockwise")
                }))
        }.accentColor(.white).background(Color.blue)
    }
}

struct StationCell : View{
    
    var model:NYCFullBikeInfo?
    
    var body: some View{
        HStack(alignment: .bottom){
            VStack(alignment:.leading){
                Text((model != nil) ? model!.name : "Station Name")
                Text((model != nil) ? "Capacity: \(model!.capacity!)" : "Station Capacity").font(.subheadline).color(.secondary)
            }
            Spacer()
                HStack(alignment:.center){
                    NumberSymbolProvider(number: model!.status.num_bikes_available, unit: "Bikes")
                    NumberSymbolProvider(number: model!.status.num_docks_available, unit: "Docks")
                }
        }
    }
    
}

struct NumberSymbolProvider : View {
    
    var number:Int
    var unit:String
    
    var body: some View{
        let numberString = (number>50) ? "50" : "\(number)"
        return VStack(alignment: .center){
                Image(systemName: "\(numberString).circle")
                Text("\(unit)").font(.caption)
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        Group{
            ContentView(model: DummyData())
//            ContentView(model: DummyData())
//                .environment(\.colorScheme, .dark)
//                .environment(\.sizeCategory, .extraExtraExtraLarge)
//            StationCell()
//                .previewLayout(PreviewLayout.fixed(width: 300, height: 70))
        }
    }
}
#endif
