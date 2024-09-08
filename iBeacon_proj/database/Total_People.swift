//
//  Total_People.swift
//  iBeacon_proj
//
//  Created by 呂長霖 on 2024/9/4.
//

import Foundation

struct TPAirtableResponse: Codable {
    let records: [TPRecord]
}

struct TPRecord: Codable {
    let id: String
    //let createdTime: String
    let fields: TPFields
}

struct TPFields: Codable {
    let uuid: String
    let count: Int
}

class TPAirtableService {
    let apiKey = airtable().apiKey
    let apiurl = airtable().apiurl
    let tableName = airtable.table.tp.rawValue
    
    func updateTP(count: TPAirtableResponse) {
            let urlString = "\(apiurl)/\(tableName)"
            
            guard let url = URL(string: urlString) else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(count)
            } catch {
                print("Error creating JSON body: \(error)")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                /*if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }*/
                
                /*if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }*/
            }
            task.resume()
    }
    
    func fetchTP(completion: @escaping (TPRecord?) -> Void) {
        let urlString = "\(apiurl)/\(tableName)"
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
                let response = try decoder.decode(TPAirtableResponse.self, from: data)
                let Fresponse = response.records.first
                completion(Fresponse)
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
