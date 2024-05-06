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
        NavigationStack {
            NavigationLink(isActive:$isLinkNB){
                newbalance()
            }label: {
            }
            
            NavigationLink(isActive:$isLinkCH){
                chanel()
            }label: {
                
            }
            VStack{
                Text("推播畫面")
                ForEach(Array(beacon.beaconData.keys), id: \.self) { key in
                    let value = beacon.beaconData[key, default: []]
                    ForEach(value.indices, id: \.self) { index in
                        let (uuid, _, _, distance) = value[index]
                        switch uuid{
                            case UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE11"):
                                if distance == "Immediately" || distance == "Near"{
                                    Button("NewBalence", action:{
                                        isNB = true
                                    })
                                }
                            default:
                                do{}
                        }
                    }
                }
                .alert("靠近Chanel囉",isPresented: $isCH){
                    Button("取消"){}
                    Button("去看看"){isLinkCH.toggle()}
                }
                .alert("靠近NewBalence囉",isPresented: $isNB){
                    Button("取消"){}
                    Button("去看看"){isLinkNB.toggle()}
                }
            }
            
            
            /*Button("變ＮＢ"){
                isNB.toggle()
            }
            Button("變CH"){
                isCH.toggle()
            }
            
            .alert("靠近Chanel囉",isPresented: $isCH){
                Button("取消"){
                    
                }
                Button("去看看"){
                    isLinkCH.toggle()
                }
                
                
            }
            .alert("靠近NewBalence囉",isPresented: $isNB){
                Button("取消"){
                    
                }
                Button("去看看"){
                    isLinkNB.toggle()
                }
                

            }*/
            
            
        }.onAppear{
            beacon.search_beacon()
        }
    }
}

#Preview {
    push().environmentObject(RangeBeacon())
}
