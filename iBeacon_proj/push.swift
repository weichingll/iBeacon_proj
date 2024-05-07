//
//  push.swift
//  iBeacon_proj
//
//  Created by 呂長霖 on 2024/5/5.
//

import SwiftUI

struct push: View {
    @EnvironmentObject var beacon : RangeBeacon
    @State private var isNB = false
    @State private var isCH = false
    @State private var isLinkNB = false
    @State private var isLinkCH = false
    var body: some View {
        ZStack{
            Image("oo")
                .resizable(resizingMode: .stretch)
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        
        NavigationStack {
            NavigationLink(isActive: $isLinkNB){
                newbalance()
            }label: {
                
            }.onDisappear{
                beacon.stopScanning()
            }
            NavigationLink(isActive:$isLinkCH){
                chanel()
            }label: {
                
            }.onDisappear{
                beacon.stopScanning()
            }
            HStack {
                
                Text("推播畫面")
                    .font(.largeTitle)
                
            }
            .position(x:210,y:60)
            //Spacer()
               // .frame(height: 200)
            HStack{
                ForEach(Array(beacon.beaconData.keys), id: \.self) { key in
                    let value = beacon.beaconData[key, default: []]
                    ForEach(value.indices, id: \.self) { index in
                        let (uuid, _, _, distance) = value[index]
                        switch uuid{
                        case UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE11"):
                            if distance == "Immediately" || distance == "Near"{
                                Button{
                                    isNB = true
                                }label:{
                                    Image("NB")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                }
                            }
                        case UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE22"):
                            if distance == "Immediately" || distance == "Near"{
                                Button{
                                    isCH = true
                                }label:{
                                    Image("chanel2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                    
                                }
                            }
                            
                        default:
                            do{}
                        }
                    }
                }
            }
            .position(x:200,y:100)
                .alert("靠近Chanel囉",isPresented: $isCH){
                    Button("取消"){}
                    Button("去看看"){isLinkCH.toggle()}
                }
                .alert("靠近NewBalence囉",isPresented: $isNB){
                    Button("取消"){}
                    Button("去看看"){isLinkNB.toggle()}
                    
                }
            }
            
            
        }.onAppear{
            beacon.search_beacon()
        }
    }
}

#Preview {
    push().environmentObject(RangeBeacon())
}
