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
  
  @State var showFavourites:Bool = false
  @State var searchString:String = ""
  
  
  func getColor(station:GBFSFullBikeInfo)->Color{
    (station.status.is_renting==1) ? Color.blue : Color.red
  }
  
  func filter(station:GBFSFullBikeInfo)->Bool{
    if searchString == "" {
      return true
    } else {
      return station.name.contains(searchString)
    }
  }
  
  var body: some View {
    NavigationView{
      List{
        
        Section{
            Text(model.processes?.getString() ?? "")
                .lineLimit(0)
        }
        if(model.stationData.count==0){
          Section{
            HStack(alignment:.center){
              Spacer()
              ActivityView()
              Text("loading...")
              Spacer()
            }
          }
        } else {
          Section{
            TextField($searchString, placeholder: Text("Search"))
          }
        }
        Section{
          ForEach(model.stationData) { station in
            if !self.showFavourites || station.isFavourite { //Both cases, this is important!
              if self.filter(station: station) {
              NavigationButton(destination:StationDetailView(station:station).environmentObject(self.model)){
                StationCell(model: station)
                }.padding()
                .background(self.getColor(station: station))
                .cornerRadius(25)
                .foregroundColor(.white)
              }
            }
          }
        }
        }.navigationBarTitle(Text("Bike Stations"))
        .listStyle(.grouped)
        .navigationBarItems(leading:Button(action: {self.showFavourites = !self.showFavourites}, label: {
          withAnimation{
            (self.showFavourites) ? Image(systemName: "star.fill") : Image(systemName: "star")
          }
        }) ,trailing: Button(action: {self.model.refresh()}, label: {
          Image(systemName: "arrow.clockwise")
        }))
      }.accentColor(.white)
  }
}

struct StationCell : View{
  
  var model:GBFSFullBikeInfo?
  
  var body: some View{
    ZStack{
      HStack(alignment: .bottom){
        VStack(alignment:.leading){
          Text((model != nil) ? model!.name : "Station Name")
          Text((model != nil) ? "Capacity: \(model!.capacity!)" : "Station Capacity").font(.subheadline)
        }
        Spacer()
        HStack(alignment:.center){
          NumberSymbolProvider(number: model!.status.num_bikes_available, unit: "Bikes")
          NumberSymbolProvider(number: model!.status.num_docks_available, unit: "Docks")
        }
      }
      if(model!.isFavourite){
        VStack(alignment:.leading){
          HStack(alignment: .top){
            Spacer()
            Image(systemName: "star.fill").foregroundColor(.yellow).offset(x:15,y:-5)
            
          }
          Spacer()
        }
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
