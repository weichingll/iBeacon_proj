//
//  profile.swift
//  iBeacon_proj
//
//  Created by 林京緯 on 2024/9/10.
//

//
//  profilePicture.swift
//  iBeacon_proj
//
//  Created by 林京緯 on 2024/9/10.
//
/*
import Foundation


struct pAirtableResponse: Codable {
    let records: [pRecord]
}

struct pRecord: Codable {
    let fields: pFields
}

struct pFields: Codable {
    let puserName: String
    let pphoto: [Photo]?
}

struct Photo: Codable {
    let purl: String
}

import SwiftUI

struct pContentView: View {
    @State private var imageURL: URL? = nil
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("正在加載...")
            } else if let url = imageURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else if phase.error != nil {
                        Text("加載圖片失敗")
                    } else {
                        ProgressView()
                    }
                }
            } else {
                Text("無法找到圖片")
            }
        }
        .onAppear {
            fetchPhoto(forUserName: "s001")
        }
    }

    func fetchPhoto(forUserName userName: String) {
        let apiKey = "YOUR_API_KEY"
        let baseID = "YOUR_BASE_ID"
        let tableName = "YOUR_TABLE_NAME"
        let urlString = "https://api.airtable.com/v0/\(baseID)/\(tableName)?filterByFormula=%7BuserName%7D%3D%22\(userName)%22"

        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let airtableResponse = try JSONDecoder().decode(AirtableResponse.self, from: data)
                    if let firstRecord = airtableResponse.records.first,
                       let photo = firstRecord.fields.photo?.first {
                        DispatchQueue.main.async {
                            self.imageURL = URL(string: photo.url)
                            self.isLoading = false
                        }
                    }
                } catch {
                    print("解析失敗: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
}
*/
