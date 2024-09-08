//
//  Login&Register.swift
//  iBeacon_proj
//
//  Created by 呂長霖 on 2024/9/2.
//

import Foundation

struct UserAirtableResponse: Codable {
    let records: [UserRecord]
}

struct UserRecord: Codable {
    let id: String
    let createdTime: String
    let fields: UserFields
}

struct UserFields: Codable {
    let user: String
    let password: String
    let name: String
    let date: Date
    let email: String
    var point: String
    var entry: Int
}

class UserAirtableService {
    let apiKey = airtable().apiKey
    let apiurl = airtable().apiurl
    let tableName = airtable.table.user.rawValue //User表
    
    //取得user資料
    func fetchUsers(user: String, completion: @escaping (UserRecord?) -> Void) {
        
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
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    let response = try decoder.decode(UserAirtableResponse.self, from: data)
                    let matchingUser = response.records.first(where: { $0.fields.user == user })
                    completion(matchingUser)
                } catch {
                    print("Error decoding data: \(error)")
                    completion(nil)
                }
            }
            task.resume()
    }
    
    //新增user資料
    func addUser(user: UserFields, completion: @escaping (Bool) -> Void) {
        let urlString = "\(apiurl)/\(tableName)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        encoder.dateEncodingStrategy = .formatted(formatter)
        
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
    
    /*func updateUser(user: UserAirtableResponse){
        print("Enter")
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
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            encoder.dateEncodingStrategy = .formatted(formatter)
            request.httpBody = try encoder.encode(user)
        } catch {
            print("Error creating JSON body: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                //completion(true)
            } else {
                //completion(false)
            }
        }
        task.resume()
    }*/
    func updateUser(user: UserAirtableResponse, completion: @escaping (Bool) -> Void) {
            guard let record = user.records.first else {
                completion(false)
                return
            }
            
            let urlString = "\(apiurl)/\(tableName)/\(record.id)"
            guard let url = URL(string: urlString) else {
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // 只更新 entry 字段
        let updatedFields: [String: Any] = ["point": record.fields.point, "entry": record.fields.entry]
            let body: [String: Any] = ["fields": updatedFields]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                print("Error creating JSON body: \(error)")
                completion(false)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
            task.resume()
        }

}
