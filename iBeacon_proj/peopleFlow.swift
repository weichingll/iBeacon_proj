//
//  peopleFlow.swift
//  test
//
//  Created by 林京緯 on 2024/5/3.
//

import SwiftUI

struct peopleFlow: View {
    @EnvironmentObject var data : data_link
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var people = 0
    var body: some View {
            VStack{
                Text("目前人流數")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                ZStack{
                    Image("peopleBackground")
                        .resizable()
                        .scaledToFit()
                    VStack{
                        Spacer()
                            .frame(height: 50)
                        Text("目前人數:")
                            .foregroundStyle(.white)
                            .font(.largeTitle)
                        Spacer()
                            .frame(height: 40)
                        Text("\(people)")
                            .foregroundStyle(.white)
                            .font(.largeTitle)
                        Spacer()
                            .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        
                    }
                    
                }
                
            }.onReceive(timer){ _ in
                data.loadData_Beacon_people{ item in
                    people = Int(item[1])!
                }
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
}
