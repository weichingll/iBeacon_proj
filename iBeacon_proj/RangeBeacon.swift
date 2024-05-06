//
//  RangeBeacon.swift
//  test
//
//  Created by 林京緯 on 2024/4/14.
//

import SwiftUI
import CoreLocation
import Foundation

class RangeBeacon : NSObject, ObservableObject, CLLocationManagerDelegate{
    private var locationManager: CLLocationManager?
    @Published var beaconData: [UUID: [(UUID, NSNumber, NSNumber, String)]] = [:]
    @Published var detectedBeacons: [CLBeacon] = []
    @Published var enteredUUIDs : [UUID] = []
    @Published var people_count = 0
    @Published var isEnter = false
    private var beaconRegions: [CLBeaconRegion] = []
    var data : data_link
    //@ObservedObject var beacons = BeaconManager()
    //@State private var enteredUUIDs: [UUID] = []
    
    override init() {
        self.data = data_link()
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }
        
    func search_beacon(){
        data.loadData_Beacon_people{ [self] item in
            if let uuids = UUID(uuidString : item[0]){
                if !enteredUUIDs.contains(uuids){
                    enteredUUIDs.append(uuids)
                }
            }
            people_count = Int(item[1])!
            data.loadData_Beacon{ [self] beacon_uuid in
                for uuid in beacon_uuid{
                    if let uuids = UUID(uuidString : uuid){
                        if !enteredUUIDs.contains(uuids){
                            enteredUUIDs.append(uuids)
                        }
                    }
                }
                print(enteredUUIDs)
                uuidArray(uuids: enteredUUIDs)
                startScanning()
            }
        }

    }
    
    func update_Pcount(){
        data.uploadData_Pcount(database_people_beacon(records: [database_people_beacon.Record(id: data.beacon_Pcount_ID, fields: database_people_beacon.Fields(uuid: "12345678-1234-1234-1234-AABBCCDDEE33", count: String(people_count)))]))
        data.loadData_Beacon_people{ [self] item in
            people_count = Int(item[1])!
        }

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

/*class BeaconManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    @Published var beaconData: [UUID: [(UUID, NSNumber, NSNumber, String)]] = [:]
    @Published var detectedBeacons: [CLBeacon] = []
    @Published var enteredUUIDs : [UUID] = []
    @Published var people_count = 0
    @Published var isEnter = false
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
}*/
    
