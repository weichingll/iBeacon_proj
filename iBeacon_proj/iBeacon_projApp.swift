//
//  iBeacon_projApp.swift
//  iBeacon_proj
//
//  Created by 呂長霖 on 2024/5/5.
//

import SwiftUI

@main
struct iBeacon_projApp: App {
    var body: some Scene {
        WindowGroup {
            mainView()
                .environmentObject(data_link())
                .environmentObject(IsLog())
                .environmentObject(RangeBeacon())
                .environmentObject(UserData())
                .environmentObject(Isshow())
        }
    }
}
