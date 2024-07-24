//
//  Photo.swift
//  FlickrRACV
//
//  Created by Chirag Chaplot on 24/7/2024.
//

import Foundation
struct Photo: Codable, Identifiable, Equatable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    var url: String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
    
#if DEBUG
    static var previewProduct: Photo {
        let results = try! StaticJSONMapper.decode(file: "ImagesStaticData", type: ImageSearchResponse.self)
        return results.photos.photo.first!
    }
#endif
}
