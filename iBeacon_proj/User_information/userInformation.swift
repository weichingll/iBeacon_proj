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
    @EnvironmentObject var User : UserData
    let checkIndata = CheckInAirtableService()
    @State var checkIn: [CheckInRecord] = []
    var body: some View {
        
        NavigationStack {
            VStack{
                Text("個人資訊")
                Spacer().frame(height: 30)
                Image("profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)
                    .shadow(color: .primary.opacity(0.7), radius: 20)
                Text("您好，\(User.User_Name)       ")
                    
                ZStack(alignment:.center){
                    Image("pointBK")
                        .resizable()
                        .frame(width: 270, height: 225)
                    Text("剩餘點數:\(User.User_Point) 點")//需抓point
                        .fontWeight(.medium)
                }
            }
            List{

                NavigationLink(destination: checkInRecordView()) {
                    Text("打卡紀錄")
                }
                /*
                NavigationLink(destination: giftView()) {
                    Text("點數商城")
                }*/
                NavigationLink(destination: giftRecordView()) {
                    Text("兌換紀錄")
                }
                NavigationLink(destination: pointView()) {
                    Text("商店總覽")
                }
                
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
    func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC") // 设置时区为 UTC
        guard let date = dateFormatter.date(from: dateString) else {
            return "Invalid Date"
        }
        // 加8小时
        let calendar = Calendar.current
        let modifiedDate = calendar.date(byAdding: .hour, value: 8, to: date) ?? date
        // 重新格式化输出
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current // 设置时区为当前时区
        return dateFormatter.string(from: modifiedDate)
    }
}

#Preview {
    userInformation()
        .environmentObject(UserData())
}
