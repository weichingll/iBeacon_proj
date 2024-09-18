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
    let picture: [homeImageInfo]?
    let Name: String?
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
    let apiurl = airtable().apiurl
    let tableName = airtable.table.homepage.rawValue //主畫面圖片表

    func fetchImages(completion: @escaping ([homeImageInfo]?) -> Void) {
        let urlString = "\(apiurl)/\(tableName)"
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
                let images = response.records.compactMap { $0.fields.picture?.first }
                completion(images)
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
