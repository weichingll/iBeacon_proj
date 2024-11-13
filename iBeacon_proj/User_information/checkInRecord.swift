import SwiftUI
import Combine

struct CheckInAirtableResponse1: Codable{
    let records: [CheckInRecord]
}

struct CheckInRecord1: Codable {
    let id: String
    let createdTime: String
    let fields: CheckInFields1
}

struct CheckInFields1: Codable {
    let user: String
    let location: String
    let point: Int
    let uuid: String
}

struct checkInRecordView: View {
    @EnvironmentObject var User : UserData
    let checkIndata = CheckInAirtableService()
    @State var checkIn: [CheckInRecord] = []
    
    var body: some View {
        NavigationView {
            List(checkIn, id: \.id) { record in
                VStack(alignment: .leading) {
                    Text("\(record.fields.location)")
                    Text("點數: \(record.fields.point)")
                    Text("時間:"+"\(formattedDate(record.createdTime))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationBarTitle("打卡紀錄")
            .onAppear {
                checkIndata.fetchCheckIn(user: User.User_Account){data in
                    if let data = data{
                        checkIn = data.sorted(using: [SortDescriptor(\.createdTime, order: .reverse)])
                    }
                }
            }
        }
    }
    
    func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC+8") // 设置时区为 UTC
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

    /*private func fetchData() {
        let baseURL = "https://api.airtable.com/v0/app5fKBa04lBdINdG/checkInRecord?filterByFormula=({user} = '\(User.User_Account)')"
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer patUj5oLB517zr16T.24c0a004222f170f7d7642dd83bc9022d28a67dc6d4da0487153e22fe48656e1", forHTTPHeaderField: "Authorization") // 替换为你的 Airtable API Key

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let result = try decoder.decode(CheckinResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.checkInRecords = result.records
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }*/
}




#Preview {
    checkInRecordView()
        .environmentObject(UserData())
}
