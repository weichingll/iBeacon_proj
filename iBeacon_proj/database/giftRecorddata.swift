//
//  giftRecorddata.swift
//  iBeacon_proj
//
//  Created by 林京緯 on 2024/9/11.
//

import Foundation

struct GRAirtableResponse: Codable {
    let records: [GRRecord]
}

struct GRRecord: Codable {
    let id: String
    let createdTime: String
    let fields: GRFields
}

struct GRFields: Codable {
    let user: String
    let giftName: String
    let cost: Int
}

class GRAirtableService {
    let apiKey = airtable().apiKey
    let apiurl = airtable().apiurl
    let tableName = airtable.table.gr.rawValue //禮物兌換表
    
    //取得user資料
    func fetchGR(user: String, completion: @escaping ([GRRecord]?) -> Void) {
        
        let urlString = "\(apiurl)/\(tableName)?filterByFormula=({user} = '\(user)')"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(GRAirtableResponse.self, from: data)
                let matchingUser = response.records
                completion(matchingUser)
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    //新增user資料
    func addGR(user: GRFields, completion: @escaping (Bool) -> Void) {
        let urlString = "\(apiurl)/\(tableName)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let record = ["fields": user]
        guard let jsonData = try? encoder.encode(record) else {
            completion(false)
            return
        }
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error adding user: \(error)")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }
}

