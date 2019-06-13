//
//  StationDetailView.swift
//  test
//
//  Created by Joss Manger on 6/12/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SwiftUI

struct StationDetailView : View {
    
    let station:NYCBikeStationInfo
    
    @State var viewDidAppear:Bool = false
    
    let mybasic = Animation.spring().delay(0.3)
    
    var body: some View {
        
    
            VStack(alignment:.center) {
                
                SymbolView(color: .yellow, number: station.status!.num_bikes_available, didAppear: $viewDidAppear)
                
                VStack{
                    Text(station.name).font(.title).color(.white)
                    Text("\(station.capacity!)").font(.subheadline).color(.white)
                    }.padding()
                
                    SymbolView(color: .red, label: "Docks", number: station.status!.num_docks_available, didAppear: $viewDidAppear)
                
                }.background(Color.blue)
                .onAppear(perform: {
                    withAnimation(self.mybasic){
                        self.viewDidAppear = true
                    }
                })
        
        
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
                .foregroundColor(.white)
                .padding()
                .aspectRatio(contentMode: .fit)
                .rotation3DEffect(( didAppear ? end : start ), axis: (0,1,0))
                .opacity(didAppear ? 1.0 : 0)
            
            Text(label).font(.subheadline)
            }.background(color).padding()
        
        
    }
    
    
}


#if DEBUG
struct StationDetailView_Previews : PreviewProvider {
    static var previews: some View {
        StationDetailView(station: testData[0])
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
