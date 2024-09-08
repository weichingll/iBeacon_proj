//
//  CheckIndata.swift
//  iBeacon_proj
//
//  Created by 呂長霖 on 2024/9/7.
//

import Foundation

struct CheckInAirtableResponse: Codable{
    let records: [CheckInRecord]
}

struct CheckInRecord: Codable {
    let id: String
    let createdTime: String
    let fields: CheckInFields
}

struct CheckInFields: Codable {
    let user: String
    let location: String
    let point: Int
    let uuid: String
}

class CheckInAirtableService{
    let apiKey = airtable().apiKey
    let apiurl = airtable().apiurl
    let tableName = airtable.table.checkIn.rawValue //beacon表(shop)
    
    func fetchCheckIn(user: String, completion: @escaping ([CheckInRecord]?) -> Void) {
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
                let response = try decoder.decode(CheckInAirtableResponse.self, from: data)
                let matchingUser = response.records
                completion(matchingUser)
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func addCheckIn(user: CheckInFields, completion: @escaping (Bool) -> Void) {
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
