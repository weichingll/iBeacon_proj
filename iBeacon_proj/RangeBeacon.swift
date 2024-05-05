//
//  RangeBeacon.swift
//  test
//
//  Created by 林京緯 on 2024/4/14.
//

import SwiftUI
import CoreLocation

struct RangeBeaconView: View {
    @EnvironmentObject var data : data_link
    @ObservedObject var beacons = BeaconManager()
    @State private var enteredUUIDs: [UUID] = []
    @State private var EnterUUID = ""
    let timer = Timer.publish(every: 100, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack{
            Text("BEACON")
                .font(.title)
            Text("人數: \(beacons.people_count)")
            List{
                ForEach(Array(beacons.beaconData.keys), id: \.self) { key in
                    let value = beacons.beaconData[key, default: []]
                    ForEach(value.indices, id: \.self) { index in
                        let (uuid, major, minor, distance) = value[index]
                        Text("\(uuid)").fixedSize()
                        Text("Major: \(major), Minor: \(minor), 距離: \(distance)")
                        if uuid == UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE33"){
                            Text("人數: \(beacons.people_count)")
                        }
                    }
                }
            }
            .frame(width: 400, height: 500)
        }
        .onAppear{
            data.loadData_Beacon_people{ item in
                if let uuids = UUID(uuidString : item[0]){
                        enteredUUIDs.append(uuids)
                }
                beacons.people_count = Int(item[1])!
                data.loadData_Beacon{ beacon_uuid in
                    for uuid in beacon_uuid{
                        if let uuids = UUID(uuidString : uuid){
                            enteredUUIDs.append(uuids)
                        }
                    }
                    print(enteredUUIDs)
                    beacons.uuidArray(uuids: enteredUUIDs)
                    beacons.startScanning()
                }
            }

        }
        .onReceive(timer){ _ in
            data.uploadData_Pcount(database_people_beacon(records: [database_people_beacon.Record(id: data.beacon_Pcount_ID, fields: database_people_beacon.Fields(uuid: "12345678-1234-1234-1234-AABBCCDDEE33", count: String(beacons.people_count)))]))
            data.loadData_Beacon_people{ item in
                beacons.people_count = Int(item[1])!
            }
        }
    }
}

class BeaconManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    @Published var beaconData: [UUID: [(UUID, NSNumber, NSNumber, String)]] = [:]
    @Published var detectedBeacons: [CLBeacon] = []
    @Published var enteredUUIDs : [UUID] = []
    @Published var people_count = 0
    @Published var isEnter = false
    @EnvironmentObject var data : data_link
    private var beaconRegions: [CLBeaconRegion] = []
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }
        
    func uuidArray(uuids : [UUID]){
        for uuid in uuids {
            let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: uuid.uuidString)
            beaconRegions.append(beaconRegion)
        }
    }
    
    func startScanning() {
        guard let locationManager = self.locationManager else { return }
        for beaconRegion in beaconRegions {
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
    }
    
    func stopScanning() {
        guard let locationManager = self.locationManager else { return }
        for beaconRegion in beaconRegions {
            locationManager.stopMonitoring(for: beaconRegion)
            locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
    }
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        DispatchQueue.main.async{ [self] in
            var beaconArray: [(UUID, NSNumber, NSNumber, String)] = []
            for beacon in beacons {
                var distance = "Unknown"
                switch beacon.proximity {
                case .immediate:
                    distance = "Immediately"
                case .near:
                    distance = "Near"
                case .far:
                    distance = "Far"
                default:
                    distance = "Unknown"
                }
                beaconArray.append((beacon.uuid, beacon.major, beacon.minor, distance))
                beaconData[beacon.uuid] = beaconArray
            }
            if let people = beaconData[UUID(uuidString:"12345678-1234-1234-1234-AABBCCDDEE33")!], people.count >= 1{
                print("distanc = \(people[0].3)")
                let status = people[0].3
                if status == "Immediately" && isEnter == false{
                    isEnter = true
                    people_count += 1
                    print(people_count)
                }else if status != "Immediately" && isEnter == true{
                    isEnter = false
                    people_count -= 1
                    print(people_count)
                }
            }
            //print(beaconData)
        }
    }
}
    
#Preview {
    RangeBeaconView().environmentObject(data_link())
}
