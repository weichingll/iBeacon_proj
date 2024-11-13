//
//  peopleFlow.swift
//  test
//
//  Created by 林京緯 on 2024/5/3.
//

import SwiftUI

struct peopleFlow: View {
    @EnvironmentObject var data : data_link
    @EnvironmentObject var beacon : RangeBeacon
    @EnvironmentObject var User : UserData
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var people = 0
    let TPdata = TPAirtableService()
    @State var num = 0
    var body: some View {
            VStack{
                Text("今日已入場人數")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                ZStack{
                    Image("peopleBackground")
                        .resizable()
                        .scaledToFit()
                    VStack{
                        Spacer()
                            .frame(height: 50)
                        Text("目前人數:")
                            .foregroundStyle(.black)
                            .font(.largeTitle)
                        Spacer()
                            .frame(height: 40)
                        Text("\(people)")
                            .foregroundStyle(.black)
                            .font(.largeTitle)
                        Spacer()
                            .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
    
                    }
                    
                }
                
            }
            .onReceive(timer){ _ in
                TPdata.fetchTP{item in
                    if let item = item{
                        people = item.fields.count
                    }
                }
            }
            .onAppear{
                beacon.search_beacon(userObject: User)
            }
            .background(
                Image("peopleFlowBackgroung")
                    .resizable(resizingMode: .stretch)
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                            
        )
            .navigationTitle("人流")
    }
}

#Preview {
    peopleFlow()
        .environmentObject(data_link())
        .environmentObject(RangeBeacon())
}
