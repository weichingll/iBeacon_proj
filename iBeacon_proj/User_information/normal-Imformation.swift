//
//  normal-Imformation.swift
//  iBeacon_proj
//
//  Created by 林京緯 on 2024/9/10.
//

import SwiftUI

struct normal_Imformation: View {
    @EnvironmentObject var User : UserData
    let checkIndata = CheckInAirtableService()
    @State var checkIn: [CheckInRecord] = []
    var body: some View {
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
                
            Divider()
                .frame(height: 10)
                .overlay(.divider)
            ZStack(alignment:.center){
                Image("pointBK")
                    .resizable()
                    .frame(width: 300, height: 250)
                Text("剩餘點數:500 點")//需抓point
                    .fontWeight(.medium)
            }
            
            Divider()
                .frame(height: 10)
                .overlay(.divider)
            
            Text("打卡紀錄")
            List(checkIn, id: \.id) { record in
                VStack(alignment: .leading) {
                    Text("\(record.fields.location)")
                    Text("點數: \(record.fields.point)")
                    Text("時間:"+"\(formattedDate(record.createdTime))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            //.navigationBarTitle("打卡紀錄")
            .onAppear {
                checkIndata.fetchCheckIn(user: User.User_Account){data in
                    if let data = data{
                        checkIn = data
                    }
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
    normal_Imformation().environmentObject(UserData())
}
