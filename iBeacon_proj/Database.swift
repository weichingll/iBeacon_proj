//
//  Database.swift
//  test
//
//  Created by 呂長霖 on 2024/5/2.
//

import Foundation

class data_link : ObservableObject{
    let user_url = URL(string: "https://api.airtable.com/v0/app5fKBa04lBdINdG/User")!
    let beacon_url = URL(string: "https://api.airtable.com/v0/app5fKBa04lBdINdG/beacon")!
    let beacon_people_url = URL(string: "https://api.airtable.com/v0/app5fKBa04lBdINdG/people")!
    let token = "patUj5oLB517zr16T.24c0a004222f170f7d7642dd83bc9022d28a67dc6d4da0487153e22fe48656e1"
    var beacon_Pcount_ID : String = ""
    
    //新增User資料庫資料
    func uploadData(_ userdata: database_user){
        var request = URLRequest(url: user_url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        encoder.dateEncodingStrategy = .formatted(formatter)
        request.httpBody = try? encoder.encode(userdata)
        
        URLSession.shared.dataTask(with: request){ data, response, error in
           /* if let data,
              let content = String(data: data, encoding:  .utf8){
                    
                }*/
        }.resume()
    }
    
    //更新人流
    func uploadData_Pcount(_ Pcount_data: database_people_beacon){
        var request = URLRequest(url: beacon_people_url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(Pcount_data)
            URLSession.shared.dataTask(with: request){ data, response, error in
               if let data = data,
                  let content = String(data:data, encoding: .utf8){
                   print(content)
               }else if let resError = error{
                   print(resError)
               }
            }.resume()
        }catch{
            print(error)
        }
    }
    
    //抓取
    func loadData_Account(completion: @escaping([String: [(String, String, Date, String)]]) -> Void){
        var Account_data : [String: [(String, String, Date, String)]] = [:]
        var request = URLRequest(url: user_url)
        var user_Array: [(String, String, Date, String)] = []
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                decoder.dateDecodingStrategy = .formatted(formatter)
                let data_source = try decoder.decode(database_user.self, from: data)
                for record in data_source.records{
                    let account = record.fields.user
                    let password = record.fields.password
                    let name = record.fields.name
                    let date = record.fields.date
                    let email = record.fields.email
                    user_Array.append((password, name, date, email))
                    Account_data[account] = user_Array
                }
                completion(Account_data)
                
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    
    func loadData_Beacon(completion: @escaping([String]) -> Void){
        var Beacon_uuid_data = [String]()
        var request = URLRequest(url: beacon_url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let data_source = try decoder.decode(database_beacon.self, from: data)
                
                for record in data_source.records{
                    let uuid = record.fields.uuid
                    Beacon_uuid_data.append(uuid)
                }
                completion(Beacon_uuid_data)
                
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    func loadData_Beacon_people(completion: @escaping([String]) -> Void){
        var Beacon_people_data = [String]()
        var request = URLRequest(url: beacon_people_url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let data_source = try decoder.decode(database_people_beacon.self, from: data)
                
                for record in data_source.records{
                    let uuid = record.fields.uuid
                    let count = record.fields.count
                    Beacon_people_data.append(uuid)
                    Beacon_people_data.append(count)
                    self.beacon_Pcount_ID = record.id
                }
                completion(Beacon_people_data)
                
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}

struct database_user: Codable{
    let records: [Record]
    
    struct Record: Codable{
        let fields: Fields
    }
    
    struct Fields: Codable{
        let user: String
        let password: String
        let name: String
        let date: Date
        let email: String
    }
}

struct database_beacon: Codable{
    let records: [Record]
    
    struct Record: Codable{
        let fields: Fields
    }
    
    struct Fields: Codable{
        let uuid: String
    }
}

struct database_people_beacon: Codable{
    let records: [Record]
    
    struct Record: Codable{
        let id: String
        let fields: Fields
    }
    
    struct Fields: Codable{
        let uuid: String
        let count: String
    }
}

