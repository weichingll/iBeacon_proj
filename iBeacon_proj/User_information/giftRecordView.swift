//
//  giftRecordView.swift
//  iBeacon_proj
//
//  Created by 林京緯 on 2024/9/11.
//

import SwiftUI
import Combine

struct GRAirtableResponse1: Codable {
    let records: [GRRecord]
}

struct GRRecord1: Codable {
    let id: String
    let createdTime: String
    let fields: GRFields1
}

struct GRFields1: Codable {
    let user: String
    let giftName: String
    let cost: String
}

struct giftRecordView: View {
    @EnvironmentObject var User : UserData
    let grdata = GRAirtableService()
    @State var GR: [GRRecord] = []
    
    var body: some View {
        NavigationView {
            List(GR, id: \.id) { record in
                VStack(alignment: .leading) {
                    Text("\(record.fields.giftName)")
                    Text("點數: \(record.fields.cost)")
                    Text("時間:"+"\(formattedDate(record.createdTime))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationBarTitle("兌換紀錄")
            .onAppear {
                grdata.fetchGR(user: "s001"){data in
                    if let data = data{
                        GR = data.sorted(using: [SortDescriptor(\.createdTime, order: .reverse)])
                    }
                }
            }
        }
    }
    
    func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC+8")
        guard let date = dateFormatter.date(from: dateString) else {
            return "Invalid Date"
        }
        // 加8小时
        let calendar = Calendar.current
        let modifiedDate = calendar.date(byAdding: .hour, value: 8, to: date) ?? date
        // 重新格式化输出
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: modifiedDate)
    }
}



#Preview {
    giftRecordView()
        .environmentObject(UserData())
}
