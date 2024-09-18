//
//  giftView.swift
//  iBeacon_proj
//
//  Created by 林京緯 on 2024/6/28.
//
import Foundation
import SwiftUI


struct giftView: View {
    @EnvironmentObject var User: UserData
    @State private var records: [giftRecord] = []
    @State private var showpointchang = false
    @State private var scu = false
    let grdata = GRAirtableService()
    let userdata = UserAirtableService()
    @State var grRecords: giftRecord? = nil
    @State var isfail = false
    
    var body: some View {
        NavigationView {
            List(records, id: \.id) { record in
                Button(action: {
                    grRecords = record
                    showpointchang.toggle()
                   
                }
            ) {
                HStack {
                    if let imageURL = record.fields.image.first?.url {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    Text("商品: \(record.fields.giftName)")
                    Text("花費點數: \(record.fields.cost)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle()) // Remove default button style
            }
            .alert("點數不足", isPresented : $isfail){
                Button("ok"){
                    DispatchQueue.main.async{
                        isfail = false
                    }
                }
            }
            .alert("確認兌換", isPresented: $showpointchang){
                Button("確認"){
                    if Int(User.User_Point)! >= grRecords!.fields.cost{
                        let newRecord = GRFields(user: User.User_Account, giftName: grRecords!.fields.giftName, cost: grRecords!.fields.cost)
                        grdata.addGR(user: newRecord) { success in
                            if success {
                                print("success")
                                let currentP = Int(User.User_Point)!
                                let updataP = currentP - grRecords!.fields.cost
                                User.User_Point = String(updataP)
                                
                                userdata.fetchUsers(user: User.User_Account){data in
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
                                                print("add success")
                                            }
                                            else{
                                                print("add failed")
                                            }
                                        }
                                    }
                                }
                                
                            } else {
                                print("fail")
                            }
                        }
                    }else{
                        print("point not enough!")
                        isfail.toggle()
                    }
                }
                Button("取消"){}
            }
        }
        .navigationBarTitle("點數商城")
        .onAppear {
            giftAirtableService().fetchRecords { records in
                if let records = records {
                    self.records = records
                }
            }
        }
    }
}


#Preview {
    giftView().environmentObject(UserData())
}
