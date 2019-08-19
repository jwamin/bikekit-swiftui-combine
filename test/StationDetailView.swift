//
//  StationDetailView.swift
//  test
//
//  Created by Joss Manger on 6/12/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SwiftUI

struct StationDetailView : View {
  
  @EnvironmentObject var model:StationDataModel
  
  var station:GBFSFullBikeInfo
  
  @State var viewDidAppear:Bool = false
  
  
  var stationIndex: Int {
    model.stationData.firstIndex(where: { $0.id == station.id })!
  }
  
  let mybasic = Animation.spring().delay(0.3)
  
  func fixNumber(num:Int)->Int{
    (num>50) ? 50 : num
  }
  
  var adjustedDate:String{
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm dd/MM/YYYY"
    return formatter.string(from: Date(timeIntervalSince1970: station.status.last_reported.timeIntervalSinceReferenceDate))
  }
  
  var body: some View {
    
    
    VStack{
      
      MapView(coordinate: station.coordinate)
        .frame(height:300)
      
      HStack(alignment: .center, spacing: 50){
        
        SymbolView(color: .yellow, number: fixNumber(num: station.status.num_bikes_available), didAppear: $viewDidAppear)
        SymbolView(color: .red, label: "Docks", number: fixNumber(num: station.status.num_docks_available), didAppear: $viewDidAppear)
        
        }.offset(y:-78)
        .padding(.bottom, -78)
      
      VStack{
        Text(station.name).font(.title).foregroundColor(.white).lineLimit(2).padding()
        Text("Capacity: \(station.capacity!)").font(.subheadline).foregroundColor(.white)
      }
      
      VStack(alignment:.leading){
        Group{
          Reporting(num: station.status.is_installed, symbol: "heart",str: "installed")
          Reporting(num: station.status.is_renting, symbol: "flag",str:"renting")
          Reporting(num: station.status.is_returning, symbol: "star",str:"returning")
          Text("Station ID: \(station.station_id)")
          Button(action: {
            
            self.model.localFavourites(index: self.station.station_id,id:self.stationIndex)
            print(self.station.isFavourite)
            
          }, label: {
            Text(model.stationData[stationIndex].isFavourite ? "Remove Favorite" : "Make Favourite")
          })
        }
        Text("Updated: \(adjustedDate)")
        Spacer()
        
        }.foregroundColor(.white)
      }.background(Color.blue)
      
      .onAppear(perform: delayAnimation).edgesIgnoringSafeArea(.all)
    
    
    
  }
  
  func delayAnimation(){
    let timer = Timer(fire: Date().addingTimeInterval(0.3), interval: 0, repeats: false) { (timer) in
      withAnimation(self.mybasic){
        self.viewDidAppear = true
      }
    }
    RunLoop.main.add(timer, forMode: .default)
  }
  
}


struct Reporting : View {
  
  let num:Int
  let symbol:String
  let str:String
  
  var slash:Bool{
    num<1
  }
  
  var symbolString:String{
    symbol+"\((slash) ? ".slash" : "" )"
  }
  
  var body: some View{
    HStack(alignment:.center){
      Image(systemName: symbolString).resizable().frame(width: 50, height: 50).padding().background( (slash) ? Color.gray : Color.blue).cornerRadius(25)
      Text("\((slash) ? "Not " : "" )"+str)
    }
  }
  
}


struct SymbolView : View {
  
  let color:Color
  
  var label:String = "Bikes"
  
  var number:Int
  
  @Binding var didAppear:Bool
  
  let start:Angle = Angle.degrees(90)
  let end:Angle = Angle.degrees(0)
  
  var body : some View {
    VStack{
      
      Image(systemName:"\(number).circle")
        .resizable()
        .frame(height:75)
        .foregroundColor(.white)
        .padding()
        .aspectRatio(1,contentMode: .fit)
        .rotation3DEffect(( didAppear ? end : start ), axis: (0,1,0))
        .opacity(didAppear ? 1.0 : 0)
      
      Text(label)
        .font(.subheadline).foregroundColor(.white)
      }.padding()
      .background(color).cornerRadius(25).accentColor(.yellow)
    
  }
  
  
}


#if DEBUG
struct StationDetailView_Previews : PreviewProvider {
  static var previews: some View {
    return StationDetailView(station: testData[0])
      .environmentObject(DummyData())
  }
}
#endif


//@propertyWrapper
//struct SFSymbolsMaxInt<N:BinaryInteger>{
//
//    let max:N = 50
//
//    init(){
//
//    }
//
//    var value:N{
//        get{
//            (self.value > max) ? max : self.value
//        }
//        set{
//            self.value = newValue
//        }
//    }
//}
