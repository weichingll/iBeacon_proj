//
//  userdata.swift
//  iBeacon_proj
//
//  Created by 林京緯 on 2024/6/28.
//

import Foundation

struct Record: Codable {
    let id: String
    let fields: [String: String]
}

struct AirtableResponse: Codable {
    let records: [Record]
}

class AirtableService {
    let apiKey = airtable().apiKey
    let baseId = airtable().baseId
    let tableName = airtable.table.user.rawValue
    let userName = "s001"

    func fetchRecords(completion: @escaping ([Record]?) -> Void) {
        let urlString = "https://api.airtable.com/v0/\(baseId)/\(tableName)?filterByFormula=({user}='\(tableName)')"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(AirtableResponse.self, from: data)
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
