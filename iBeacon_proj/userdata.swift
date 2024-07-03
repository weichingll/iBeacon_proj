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
    let apiKey = "patUj5oLB517zr16T.24c0a004222f170f7d7642dd83bc9022d28a67dc6d4da0487153e22fe48656e1"
    let baseId = "app5fKBa04lBdINdG"
    let tableName = "User"
    let userName = "s001"

    func fetchRecords(completion: @escaping ([Record]?) -> Void) {
        let urlString = "https://api.airtable.com/v0/\(baseId)/\(tableName)?filterByFormula=({user}='\(userName)')"
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
