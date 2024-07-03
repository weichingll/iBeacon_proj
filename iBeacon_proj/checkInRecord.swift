import SwiftUI
import Combine

struct checkInRecordView: View {
    @State private var checkInRecords: [CheckinRecord] = []
    @EnvironmentObject var User : UserData
    private let baseURL = "https://api.airtable.com/v0/app5fKBa04lBdINdG/checkInRecord?filterByFormula=({user}='s001')"

    var body: some View {
        NavigationView {
            List(checkInRecords, id: \.id) { record in
                VStack(alignment: .leading) {
                    Text("\(record.fields.location)")
                    Text("點數: \(record.fields.point)")
                    Text("時間:"+"\(formattedDate(record.createdTime))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationBarTitle("Check-In Records")
            .onAppear {
                fetchData()
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

    private func fetchData() {
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
    }
    
}

struct CheckinResponse: Codable {
    var records: [CheckinRecord]
}

struct CheckinRecord: Codable, Identifiable {
    var id: String
    var createdTime: String
    var fields: CheckinFields

    enum CodingKeys: String, CodingKey {
        case id
        case createdTime
        case fields
    }
}

struct CheckinFields: Codable {
    var point: Int
    var user: String
    var location: String

    enum CodingKeys: String, CodingKey {
        case point
        case user
        case location
    }
}
#Preview {
    checkInRecordView()
}
