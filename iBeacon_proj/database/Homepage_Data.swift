//
//  Homepage_Data.swift
//  iBeacon_proj
//
//  Created by 呂長霖 on 2024/7/16.
//

import Foundation

struct homeAirtableResponse: Codable {
    let records: [homeRecord]
}

struct homeRecord: Codable {
    let id: String
    let createdTime: String
    let fields: homeFields
}

struct homeFields: Codable {
    let image: [homeImageInfo]?
    let name: String?
}

struct homeImageInfo: Codable {
    let id: String
    let width: Int
    let height: Int
    let url: String
    let filename: String
    let size: Int
    let type: String
    let thumbnails: homeThumbnails
}

struct homeThumbnails: Codable {
    let small: Thumbnail
    let large: Thumbnail
    let full: Thumbnail
}
class homeAirtableService {
    let apiKey = airtable().apiKey
    let baseId = airtable().baseId
    let tableName = airtable.table.homepage.rawValue

    func fetchImages(completion: @escaping ([homeImageInfo]?) -> Void) {
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
                let response = try JSONDecoder().decode(homeAirtableResponse.self, from: data)
                let images = response.records.compactMap { $0.fields.image?.first }
                completion(images)
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
