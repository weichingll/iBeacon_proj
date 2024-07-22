//
//  giftData.swift
//  iBeacon_proj
//
//  Created by 林京緯 on 2024/6/28.
//


import Foundation

struct Thumbnail: Codable {
    let url: String
    let width: Int
    let height: Int
}

struct giftImage: Codable {
    let id: String
    let width: Int
    let height: Int
    let url: String
    let filename: String
    let size: Int
    let type: String
    let thumbnails: Thumbnails
}

struct Thumbnails: Codable {
    let small: Thumbnail
    let large: Thumbnail
    let full: Thumbnail
}

struct Fields: Codable {
    let cost: Int
    let giftName: String
    let image: [giftImage]
}

struct giftRecord: Codable {
    let id: String
    let createdTime: String
    let fields: Fields
}
struct giftAirtableResponse: Codable {
    let records: [giftRecord]
}

class giftAirtableService {
    let apiKey = airtable().apiKey
    let baseId = airtable().baseId
    let tableName = airtable.table.point.rawValue

    func fetchRecords(completion: @escaping ([giftRecord]?) -> Void) {
        let urlString = "https://api.airtable.com/v0/\(baseId)/\(tableName)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(giftAirtableResponse.self, from: data)
                completion(response.records)
                print(response)
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
