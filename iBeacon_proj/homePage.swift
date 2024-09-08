//
//  homePage.swift
//  test
//
//  Created by 林京緯 on 2024/4/15.
//
import SwiftUI
import UserNotifications
import CoreLocation

/*class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Notification permissions granted.")
            } else {
                print("Notification permissions denied.")
            }
        }
        
        // Initialize and configure CLLocationManager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.startMonitoringSignificantLocationChanges()
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}*/

func setnoti(){
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    {(granted, rror) in
        if granted{
            print("allowed")
        }else{
            print("failed allowed")
        }
    }
}

func noti(_ shop : String){
    let content = UNMutableNotificationContent()
    content.title = shop
    content.subtitle = "Wang"
    content.body = "\(shop) is near"
    content.sound = UNNotificationSound.default
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: "testNo", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

struct homePage: View {
    @EnvironmentObject var isLog : IsLog
    @EnvironmentObject var data : data_link
    @EnvironmentObject var User : UserData
    @EnvironmentObject var beacon : RangeBeacon
    @EnvironmentObject var shop_data: Isshow
    @State private var isLogout = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack(content: {
                    Spacer()
                    Text("嗨，\(User.User_Name)       ")
                })
                Spacer()
                    .frame(height:80)
                Text("開始你的冒險吧")
                
                Spacer()
                HStack{
                    NavigationLink(destination: push()){
                        Text("推播")
                    }
                    .onDisappear{
                        beacon.stopScanning()
                    }
                    .task{
                        setnoti()
                    }
                    
                    Text("|")
                    NavigationLink("點數商城"){
                        giftView()
                    }
                    .onDisappear{
                        beacon.stopScanning()
                    }
                    
                    Text("|")
                    NavigationLink(destination: BreakthroughView()){
                        Text("闖關")
                    }
                    .onDisappear{
                        beacon.stopScanning()
                        print("STOP BEACON")
                    }
                    Text("|")
                    NavigationLink("人流"){
                        peopleFlow().environmentObject(RangeBeacon()).environmentObject(data_link())
                    }
                    .onDisappear{
                        beacon.stopScanning()
                    }
                    Text("|")
                    NavigationLink("個人資訊"){
                        userInformation()
                    }
                    .onDisappear{
                        beacon.stopScanning()
                    }
                    .alert("確定登出？", isPresented: $isLogout, actions: {
                        Button("確定"){
                            isLog.isLogin.toggle()
                        }
                        Button("取消"){
                            
                        }
                    })
                }
            }
            .onAppear{
                beacon.search_beacon(userObject: User)
            }
            .onReceive(timer){ _ in
                //beacon.update_Pcount()
                let uuid = UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE11")!//NB
                if shop_data.search_shop(uuid, beacon.beaconData){
                    noti("NB")
                }
            }
            .background(
                Image("homePageBackground")
                    .resizable(resizingMode: .stretch)
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                            
        )
        }
    }
}

#Preview {
    homePage()
        .environmentObject(IsLog())
        .environmentObject(data_link())
        .environmentObject(UserData())
        .environmentObject(RangeBeacon())
        .environmentObject(Isshow())
}
