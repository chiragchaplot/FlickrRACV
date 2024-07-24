//
//  ImageSearchResponse.swift
//  FlickrRACV
//
//  Created by Chirag Chaplot on 24/7/2024.
//

import Foundation

struct ImageSearchResponse: Codable, Equatable {
  let photos: SearchResult
  
}

struct SearchResult: Codable, Equatable {
  let page: Int
  let pages: Int
  let perpage: Int
  let total: Int
  let photo: [Photo]
}
