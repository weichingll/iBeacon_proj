//
//  userInformation.swift
//  test
//
//  Created by 林京緯 on 2024/5/4.
//

import SwiftUI

struct userInformation: View {
    @EnvironmentObject var isLog : IsLog
    @State private var islogout = false
    @State private var isshowgift = false
    var body: some View {
        NavigationStack {
            List{

                NavigationLink(destination: pointView()) {
                    Text("一般")
                }
                NavigationLink(destination: checkInRecordView()) {
                    Text("打卡紀錄")
                }
                NavigationLink(destination: giftView()) {
                    Text("禮物清單")
                }
                NavigationLink(destination: ContentView()) {
                    Text("兌換紀錄")
                }
                NavigationLink(destination: pointView()) {
                    Text("商店總覽")
                }
                .navigationBarTitle("資訊")
                Button{
                    //isLog.isLogin = false
                    islogout.toggle()
                } label : {
                    Text("登出")
                }
            }
            
            .alert("確定要登出？",isPresented: $islogout) {
                Button("確定"){
                    isLog.isLogin = false
                }
                Button("取消"){
                    
                }
        }
        }
    }
}

#Preview {
    userInformation()
}
