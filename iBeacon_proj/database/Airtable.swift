//
//  Airtable.swift
//  iBeacon_proj
//
//  Created by 呂長霖 on 2024/7/16.
//

import Foundation

class airtable{
    let apiKey = "patUj5oLB517zr16T.24c0a004222f170f7d7642dd83bc9022d28a67dc6d4da0487153e22fe48656e1"
    //let baseId = "app5fKBa04lBdINdG"
    
    let apiurl = "https://api.airtable.com/v0/app5fKBa04lBdINdG"
    //ex: https://api.airtable.com/v0/app5fKBa04lBdINdG/table_name
    
    enum table: String{                         //ex : airtable.table.user.rawValue
        case user = "User"                      //使用者表
        case homepage = "homepage"              //主畫面圖片表
        case checkIn = "checkInRecord"    //獲得點數記錄表
        case point = "point"                    //點數兌換表
        case giftRecord = "giftRecord"          //兌換記錄表
        case beacon = "beacon"                  //beacon表
        case tp = "Total_People"                //人流表
    }
}
