//
//  ContentView.swift
//  BikeKitSwiftCombine
//
//  Created by Joss Manger on 6/12/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    
    @ObjectBinding var model:Favourites = Favourites()
    
    var body: some View {
        NavigationView{ 
            List{
                Section{
                ForEach(model.stationsWithData) { station in
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
        }.accentColor(.blue)
    }
}

struct StationCell : View{
    
    var model:NYCBikeStationInfo?
    
    var body: some View{
        HStack{
            VStack(alignment:.leading){
                Text((model != nil) ? model!.name : "Station Name")
                Text((model != nil) ? "Capacity: \(model!.capacity!)" : "Station Capacity").font(.subheadline).color(.secondary)
            }
            Spacer()
                VStack(alignment:.leading){
                    Text((model != nil) ? "\(model!.status!.num_bikes_available) bikes" : "bikes")
                    Text((model != nil) ? "\(model!.status!.num_docks_available) docks" : "docks")
                }
        }
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        Group{
            ContentView(model: DummyData())
            ContentView(model: DummyData())
                .environment(\.colorScheme, .dark)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
            StationCell()
                .previewLayout(PreviewLayout.fixed(width: 300, height: 70))
        }
    }
}
#endif
