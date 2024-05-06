//
//  BeaconView.swift
//  iBeacon_proj
//
//  Created by 呂長霖 on 2024/5/5.
//

import SwiftUI
import CoreLocation

struct RangeBeaconView: View {
    @EnvironmentObject var data : data_link
    @EnvironmentObject var beacon : RangeBeacon
    //@ObservedObject var beacons = BeaconManager()
    @State private var enteredUUIDs: [UUID] = []
    @State private var EnterUUID = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack{
            Text("BEACON")
                .font(.title)
            Text("人數: \(beacon.people_count)")
            List{
                ForEach(Array(beacon.beaconData.keys), id: \.self) { key in
                    let value = beacon.beaconData[key, default: []]
                    ForEach(value.indices, id: \.self) { index in
                        let (uuid, major, minor, distance) = value[index]
                        Text("\(uuid)").fixedSize()
                        Text("Major: \(major), Minor: \(minor), 距離: \(distance)")
                        if uuid == UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE33"){
                            Text("人數: \(beacon.people_count)")
                        }
                    }
                }
            }
            .frame(width: 400, height: 500)
        }
        .onAppear{
            beacon.search_beacon()
        }
        .onReceive(timer){ _ in
            beacon.update_Pcount()
        }
    }
}


    
#Preview {
    RangeBeaconView().environmentObject(data_link())
}
