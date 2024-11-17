//
//  BreakthroughView.swift
//  test
//
//  Created by 林京緯 on 2024/5/4.
//

import SwiftUI
import Combine

class Isshow : ObservableObject {
    public var isShowSearch = false//雷達圖是出現
    public var showgift = false
    
    func search_shop(_ uuid:UUID, _ beaconData:[UUID: [(UUID, NSNumber, NSNumber, String)]]) -> Bool{
        var success = false
        //print("Enter")
        if let shop_beacon = beaconData[uuid]{
            //print(shop_beacon)
            for(_, _, _, distance) in shop_beacon{
                if distance == "Immediately" || distance == "Near" {
                    success = true
                }
            }
        }
        return success
    }
}

struct BreakthroughView: View {
    @EnvironmentObject var isshow : Isshow
    @EnvironmentObject var beacon : RangeBeacon
    @EnvironmentObject var User : UserData
    @State private var NBscuess = false
    @State private var CHscuess = false
    @State private var OHscuess = false
    @State private var isshowalert = false
    @State private var isshowalert2 = false //double check
    @State private var finish = false //是否兌換過禮物
    @State private var showGift = false //顯示兌換按鈕
    @State private var successNb = false //如果沒偵測到
    @State private var successCH = false
    @State private var successOH = false
    @State var buttonNb = false
    @State var buttonCh = false
    @State var buttonOh = false
    @State var success_detect = false
    @State private var fail = false
    let userdata = UserAirtableService()
    let checkIndata = CheckInAirtableService()
    func getpoint(shop_uuid: UUID, shop_name: String){
        print("\(User.User_Account) : \(User.User_Point)")
        if let sp = beacon.shop_beacon[shop_uuid]{
            let currentP = Int(User.User_Point)!
            let updataP = currentP + sp
            User.User_Point = String(updataP)
        }
        print("\(User.User_Account) : \(User.User_Point)")
        userdata.fetchUsers(user: User.User_Account){data in
            DispatchQueue.main.async{
                if let data = data{
                    var upFields = data.fields
                    upFields.point = self.User.User_Point
                    let userResponse = UserAirtableResponse(records: [UserRecord(
                        id: data.id,
                        createdTime: data.createdTime,
                        fields: upFields
                    )])
                    userdata.updateUser(user: userResponse) { success in
                        if success {
                            let uuid = shop_uuid.uuidString
                            print("Field updated successfully")
                            let newRecord = CheckInFields(user: User.User_Account, location: shop_name, point: beacon.shop_beacon[shop_uuid]!, uuid: uuid)
                            checkIndata.addCheckIn(user: newRecord) { success in
                                if success {
                                    print("success")
                                } else {
                                    print("fail")
                                }
                            }
                        } else {
                            print("Failed to update field")
                        }
                    }
                }
            }
        }
    }//取得點數
    
    let images = ["NB","chanel", "oldcheers"]
    
    var body: some View {
        ZStack {
            Image("breakBackground")
                .resizable(resizingMode: .stretch)
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                            
            VStack {
                Text("闖關囉！")
                    .font(.largeTitle)
                    .position(x: 250,y:80)
                 
                HStack{
                    Spacer().frame(width: 80)
                    ForEach(0..<images.count, id: \.self){index in
                        if(images[index] == "oldcheers"){
                            Image(images[index])
                                .resizable()
                                .scaledToFit()
                                .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                                .scaledToFill()
                                .clipShape(Circle())
                                .position(x:35,y:60)
                        }else{
                            Image(images[index])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .position(x:35,y:60)
                        }
                    }
                    /*Image("NB")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .position(x:35,y:60)
                    Image("chanel")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .position(x:35,y:60)
                    Image("oldcheers")
                        .resizable()
                        .scaledToFit()
                        .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        .scaledToFill()
                        .clipShape(Circle())
                        .position(x:35,y:60)*/
                    Spacer()
                            
                }
                HStack{
                   Spacer()
                        //.frame(width: 150)
                    Button{
                        let uuid = UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE11")!//NB
                        if beacon.beaconData.keys.contains(uuid){
                            successNb = isshow.search_shop(uuid, beacon.beaconData)
                            if successNb == true{
                                NBscuess = true
                                buttonNb = true
                                getpoint(shop_uuid: uuid, shop_name: "NB")
                                success_detect = true
                            }else{
                                fail = true
                                return
                            }
                        }else{
                            fail = true
                            return
                        }
                    }label: {
                        if (NBscuess == false){
                            Text("我要打卡！")
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(100)
                                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                                //.position(x:-25,y:20)
                        }else{
                            Text("成功！")
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(100)
                                //.position(x:-25,y:20)
                        }
                        
                    }
                    .disabled(buttonNb)
                    Spacer().frame(width: 45)
                    Button{
                        let uuid = UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE22")!//CH
                        if beacon.beaconData.keys.contains(uuid){
                            successCH = isshow.search_shop(uuid, beacon.beaconData)
                            if successCH == true{
                                CHscuess = true
                                buttonCh = true
                                getpoint(shop_uuid: uuid, shop_name: "CH")
                                success_detect = true
                            }else{
                                fail = true
                                return
                            }
                        }else{
                            fail = true
                            return
                        }
                    }label: {
                        if (CHscuess == false){
                            Text("我要打卡！")
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(100)
                                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                                //.position(x:-25,y:20)
                        }else{
                            Text("成功！")
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(100)
                                //.position(x:-25,y:20)
                        }
                    }
                    .disabled(buttonCh)
                    Spacer().frame(width: 30)
                    Button{
                        let uuid = UUID(uuidString: "12345678-1234-1234-1234-AABBCCDDEE33")!//OH
                        if beacon.beaconData.keys.contains(uuid){
                            successOH = isshow.search_shop(uuid, beacon.beaconData)
                            if successOH == true{
                                OHscuess = true
                                buttonOh = true
                                getpoint(shop_uuid: uuid, shop_name: "OH")
                                success_detect = true
                            }else{
                                fail = true
                                return
                            }
                        }else{
                            fail = true
                            return
                        }
                    }label: {
                        if (OHscuess == false){
                            Text("我要打卡！")
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(100)
                                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                                //.position(x:-25,y:20)
                        }else{
                            Text("成功！")
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(100)
                                //.position(x:-25,y:20)
                        }
                    }
                    .disabled(buttonOh)
                    Spacer()
                }
                .padding(.top,-200)
                if(NBscuess && CHscuess && OHscuess && !finish){
                    Button("兌換禮物"){
                        isshowalert.toggle()
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(100)
                }
                if(finish){
                    Text("已兌換完成！")
                        .foregroundStyle(.white)
                }
            }
        }
        .alert("偵測失敗，請再靠近櫃位!",isPresented:$fail ){
            Button("好的"){
                fail = false
            }
        }
        .alert("成功，獲得20點!",isPresented:$success_detect ){
            Button("好的"){
                success_detect = false
            }
        }message: {
            Text("總共有\(User.User_Point)點")
        }
        
        .alert("可以兌換禮物囉!", isPresented: $isshowalert){
            Button("兌換"){
                isshowalert2.toggle()
            }
            Button("ok!"){
                //isshowalert.toggle()
            }
        }message: {
            Text("櫃檯在1F出口旁")
                .foregroundStyle(.red)
        }
        
        .alert("此按鈕限工作人員使用",isPresented: $isshowalert2){
            Button("我不是工作人員"){
                //isshowalert2.toggle()
            }
            Button("確定，已要兌換禮物"){
                finish = true
            }
        }
        .onAppear{
            beacon.search_beacon(userObject: User)
            checkIndata.fetchCheckIn(user: "\(User.User_Account)"){data in
                if let data = data{
                    for record in data{
                        if let recordUUID = UUID(uuidString: record.fields.uuid){
                            if(beacon.enteredUUIDs.contains(recordUUID)){
                                switch record.fields.location{
                                case "NB":
                                    NBscuess = true
                                    buttonNb = true
                                case "CH":
                                    CHscuess = true
                                    buttonCh = true
                                case "OH":
                                    OHscuess = true
                                    buttonOh = true
                                default:
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}

#Preview {
    BreakthroughView()
        .environmentObject(UserData())
        .environmentObject(RangeBeacon())
}
