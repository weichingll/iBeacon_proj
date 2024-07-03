//
//  giftView.swift
//  iBeacon_proj
//
//  Created by 林京緯 on 2024/6/28.
//
import Foundation
import SwiftUI

import SwiftUI

struct giftView: View {
    @State private var records: [giftRecord] = []

    var body: some View {
        NavigationView {
            List(records, id: \.id) { record in
                Button(action: {
                    
                    print("Button tapped for record \(record.id)")
                    
                }) {
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
            .navigationBarTitle("禮物清單")
            .onAppear {
                giftAirtableService().fetchRecords { records in
                    if let records = records {
                        DispatchQueue.main.async {
                            self.records = records
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    giftView()
}
