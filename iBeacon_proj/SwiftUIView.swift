//
//  SwiftUIView.swift
//  iBeacon_proj
//
//  Created by 林京緯 on 2024/6/30.
//
/*
 let apiKey = "patUj5oLB517zr16T.24c0a004222f170f7d7642dd83bc9022d28a67dc6d4da0487153e22fe48656e1"
let baseId = "app5fKBa04lBdINdG"
let tableName = "homepage"
 */
import SwiftUI
import Foundation
/*
struct homeAirtableResponse: Codable {
    let records: [homeRecord]
}

struct homeRecord: Codable {
    let id: String
    let createdTime: String
    let fields: homeFields
}

struct homeFields: Codable {
    let image: [homeImageInfo]?
    let name: String?
}

struct homeImageInfo: Codable {
    let id: String
    let width: Int
    let height: Int
    let url: String
    let filename: String
    let size: Int
    let type: String
    let thumbnails: homeThumbnails
}

struct homeThumbnails: Codable {
    let small: Thumbnail
    let large: Thumbnail
    let full: Thumbnail
}
*/
/*
class homeAirtableService {
    let apiKey = "patUj5oLB517zr16T.24c0a004222f170f7d7642dd83bc9022d28a67dc6d4da0487153e22fe48656e1"
    let baseId = "app5fKBa04lBdINdG"
    let tableName = "homepage"

    func fetchImages(completion: @escaping ([homeImageInfo]?) -> Void) {
        let urlString = "https://api.airtable.com/v0/\(baseId)/\(tableName)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(homeAirtableResponse.self, from: data)
                let images = response.records.compactMap { $0.fields.image?.first }
                completion(images)
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
*/
struct ContentView: View {
    @State private var images: [homeImageInfo] = []
    @State private var currentIndex: Int = 0
    let airtableService = homeAirtableService()
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()  // 定义一个每3秒触发的计时器

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(images.indices, id: \.self) { index in
                            AsyncImage(url: URL(string: images[index].url)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }
                            .id(index)  // 给每个图片视图一个唯一的ID
                        }
                    }
                    .padding()
                }
                .navigationBarTitle("Homepage Images")
                .onAppear {
                    airtableService.fetchImages { fetchedImages in
                        if let fetchedImages = fetchedImages {
                            DispatchQueue.main.async {
                                self.images = fetchedImages
                            }
                        }
                    }
                }
                .onReceive(timer) { _ in
                    if !images.isEmpty {
                        withAnimation {
                            currentIndex = (currentIndex + 1) % images.count  // 更新当前索引
                            proxy.scrollTo(currentIndex, anchor: .center)  // 滚动到新的索引
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
