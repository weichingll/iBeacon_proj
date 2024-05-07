//
//  homePage.swift
//  test
//
//  Created by 林京緯 on 2024/4/15.
//

import SwiftUI

struct homePage: View {
    @EnvironmentObject var isLog : IsLog
    @EnvironmentObject var data : data_link
    @EnvironmentObject var User : UserData
    @EnvironmentObject var beacon : RangeBeacon
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
                    
                    Text("|")
                    NavigationLink("點數"){
                        pointView()
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
                beacon.search_beacon()
            }
            .onReceive(timer){ _ in
                //beacon.update_Pcount()
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
}
