//
//  StationDetailView.swift
//  test
//
//  Created by Joss Manger on 6/12/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SwiftUI

struct StationDetailView : View {
    
    let station:NYCFullBikeInfo
    
    @State var viewDidAppear:Bool = false
    
    let mybasic = Animation.spring().delay(0.3)
    
    func fixNumber(num:Int)->Int{
        (num>50) ? 50 : num
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
                    Text(station.name).font(.title).color(.white)
                    Text("Capacity: \(station.capacity!)").font(.subheadline).color(.white)
                    }
                Spacer()
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
                .font(.subheadline).color(.white)
            }.padding()
            .background(color).cornerRadius(25).accentColor(.yellow)
        
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
