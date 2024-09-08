//
//  BeaconData.swift
//  iBeacon_proj
//
//  Created by 呂長霖 on 2024/9/6.
//

import Foundation

struct BeaconAirtableResponse: Codable{
    let records: [BeaconRecord]
}

struct BeaconRecord: Codable {
    let id: String
    let createdTime: String
    let fields: BeaconFields
}

struct BeaconFields: Codable {
    let uuid: String
    let shop: String
    let point: Int
}

class BeaconAirtableService{
    let apiKey = airtable().apiKey
    let apiurl = airtable().apiurl
    let tableName = airtable.table.beacon.rawValue //beacon表(shop)
    
    func fetchBeacon(completion: @escaping ([BeaconRecord]?) -> Void) {
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
                let response = try decoder.decode(BeaconAirtableResponse.self, from: data)
                let matchingUser = response.records
                completion(matchingUser)
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
