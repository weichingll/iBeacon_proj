//
//  RangeBeacon.swift
//  test
//
//  Created by 林京緯 on 2024/4/14.
//

import SwiftUI
import CoreLocation
import Foundation
import Combine

class RangeBeacon : NSObject, ObservableObject, CLLocationManagerDelegate{
    @Published var locationManager: CLLocationManager?
    @Published var beaconData: [UUID: [(UUID, NSNumber, NSNumber, String)]] = [:]
    @Published var detectedBeacons: [CLBeacon] = []
    @Published var enteredUUIDs : [UUID] = []
    @Published var people_count = 0
    @Published var isEnter = false
    @Published var beaconRegions: [CLBeaconRegion] = []
    static let shared = RangeBeacon()
    let TPdata = TPAirtableService()
    let BNData = BeaconAirtableService()
    var shop_beacon: [UUID: Int] = [:]
    var shop_name: [UUID: String] = [:]
    var data : data_link
    var user_entry = 0
    var upentry = 0
    var user_account = ""
    var isTP = false

    override init() {
        self.data = data_link()
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }
    
    func search_beacon(userObject: UserData){
        user_account = userObject.User_Account
        user_entry = userObject.User_Entry
        TPdata.fetchTP{ [self] item in
            DispatchQueue.main.async{[self] in
                if let uuids = UUID(uuidString : item!.fields.uuid){
                    if !enteredUUIDs.contains(uuids){                   //if "enteredUUIDs" 沒包含 "人數之beacon" then 新增
                        enteredUUIDs.append(uuids)
                    }
                }
                people_count = item!.fields.count
                /*data.loadData_Beacon{ [self] beacon_uuid in
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
                    if isTP == true{
                        userObject.User_Entry = 1
                    }
                }*/
                 BNData.fetchBeacon{ [self] data in
                     if let data = data{
                         for beacon_data in data{
                             if let uuid = UUID(uuidString : beacon_data.fields.uuid){
                                 if !enteredUUIDs.contains(uuid){
                                     enteredUUIDs.append(uuid)
                                     shop_beacon[uuid] = beacon_data.fields.point
                                     shop_name[uuid] = beacon_data.fields.shop
                                 }
                             }
                         }
                         print(enteredUUIDs)
                         print(shop_beacon)
                         uuidArray(uuids: enteredUUIDs)
                         startScanning()
                         if isTP == true{
                             userObject.User_Entry = 1
                         }
                     }
                 }
                 
            }
        }
    }
    
    func update_TPcount(){
        TPdata.fetchTP{tp in
            DispatchQueue.main.async{
                if let tp = tp{
                    self.TPdata.updateTP(count: TPAirtableResponse(records: [TPRecord(id: tp.id, fields: TPFields(uuid: "12345678-1234-1234-1234-AABBCCDDEE99", count: self.people_count))]))
                    self.people_count = tp.fields.count
                }
            }
        }
    }
    
    func uuidArray(uuids : [UUID]){
        for uuid in uuids {
            let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: uuid.uuidString)
            self.beaconRegions.append(beaconRegion)
        }
    }
    
    func startScanning() {
        guard let locationManager = self.locationManager else { return }
        for beaconRegion in self.beaconRegions {
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
    }
    
    func stopScanning() {
        guard let locationManager = self.locationManager else { return }
        for beaconRegion in self.beaconRegions {
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
            if let people = beaconData[UUID(uuidString:"12345678-1234-1234-1234-AABBCCDDEE99")!], people.count >= 1{
                let userdata = UserAirtableService()
                if user_entry == 1{
                    isTP = true
                }
                //print(beaconData)
                let status = people[0].3
                if status == "Immediately" && isTP == false{
                    user_entry = 1
                    userdata.fetchUsers(user: user_account){data in
                        DispatchQueue.main.async{
                            if let data = data{
                                var upFields = data.fields
                                upFields.entry = self.user_entry
                                let userResponse = UserAirtableResponse(records: [UserRecord(
                                    id: data.id,
                                    createdTime: data.createdTime,
                                    fields: upFields
                                )])
                                userdata.updateUser(user: userResponse) { success in
                                    if success {
                                        print("Field updated successfully")
                                    } else {
                                        print("Failed to update field")
                                    }
                                }
                            }
                        }
                    }
                    people_count += 1
                    update_TPcount()
                    //print(people_count)
                }
            }
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
    
