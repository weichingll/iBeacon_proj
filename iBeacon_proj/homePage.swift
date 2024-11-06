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
    content.subtitle = " "
    content.body = "接近\(shop)專櫃囉！"
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
    
    @State private var images: [homeImageInfo] = []
    @State private var currentIndex: Int = 0
    let airtableService = homeAirtableService()
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack(content: {
                    Spacer()
                    Text("嗨，\(User.User_Name)       ")
                })
                Spacer()
                    .frame(height:80)
                Text("歡迎來到Beacon百貨，開始你的冒險吧！")
                Spacer()
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(images.indices, id: \.self) { index in
                                AsyncImage(url: URL(string: images[index].url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                } placeholder: {
                                    ProgressView()
                                }
                                .id(index)  // 给每个图片视图一个唯一的ID
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        airtableService.fetchImages { fetchedImages in
                            if let fetchedImages = fetchedImages {
                                DispatchQueue.main.async {
                                    self.images = fetchedImages
                                }
                            }
                        }
                    }
                    .onReceive(timer) { _ in
                        if !images.isEmpty {
                            withAnimation {
                                currentIndex = (currentIndex + 1) % images.count  // 更新当前索引
                                proxy.scrollTo(currentIndex, anchor: .center)  // 滚动到新的索引
                            }
                        }
                    }
                }
                Spacer()
                ZStack(alignment:.center){
                    /*
                    Rectangle()
                        .stroke(Color.white)
                        .fill(Color.white)
                        .frame(width: 1000,height: 20)
                        .background(Color.white)
                        .ignoresSafeArea()*/
                    HStack{
                        Spacer()
                        NavigationLink(destination: push()){
                            Text("推播")
                                
                        }
                        Spacer()
                        .onDisappear{
                            beacon.stopScanning()
                        }
                        .task{
                            setnoti()
                        }
                        
                        //Text("|")
                        
                        NavigationLink("點數商城"){
                            giftView()
                        }
                        Spacer()
                        .onDisappear{
                            beacon.stopScanning()
                        }
                        
                        //Text("|")
                        NavigationLink(destination: BreakthroughView()){
                            Text("闖關")
                        }
                        Spacer()
                        .onDisappear{
                            beacon.stopScanning()
                            print("STOP BEACON")
                        }
                        //Text("|")
                        NavigationLink("人流"){
                            peopleFlow().environmentObject(RangeBeacon()).environmentObject(data_link())
                        }
                        Spacer()
                        .onDisappear{
                            beacon.stopScanning()
                        }
                        //Text("|")
                        NavigationLink("個人資訊"){
                            userInformation()
                        }
                        Spacer()
                        .onDisappear{
                            beacon.stopScanning()
                        }
                        
                    }}
            }
            .onAppear{
                beacon.search_beacon(userObject: User)
            }
            .onReceive(timer){ _ in
                //beacon.update_Pcount()
                for (uuid, _) in beacon.beaconData {
                    if(uuid != UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE99")){
                        if shop_data.search_shop(uuid, beacon.beaconData) {
                            noti("\(beacon.shop_name[uuid]!)")
                        }
                    }
                }
                /*let uuid = UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE11")!//NB
                if shop_data.search_shop(uuid, beacon.beaconData){
                    noti("NB")
                }*/
            }
            
            .background(
                Image("homePageBackground")
                    .resizable(resizingMode: .stretch)
                    .scaledToFill()
                    .ignoresSafeArea()
                            
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
