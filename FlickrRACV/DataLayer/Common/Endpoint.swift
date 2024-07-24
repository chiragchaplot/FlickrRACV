//
//  Endpoint.swift
//  FlickrRACV
//
//  Created by Chirag Chaplot on 24/7/2024.
//

import Foundation

let apiKey = "c61b99b69046e37211dd95aa85e7b5c5"

enum Endpoint {
  case search(text: String, page: Int)
}

extension Endpoint {
  enum MethodType {
    case GET
    case POST
  }
}

extension Endpoint {
  
  var host: String { "flickr.com" }
  var path: String { "/services/rest" }
  
  var methodType: MethodType {
    switch self {
    case .search:
      return .GET
    }
  }
  
  var queryItems: [String: String]? {
    switch self {
    case .search(let text, let page):
      return ["method": "flickr.photos.search",
              "text": "\(text)",
              "content_types": "0",
              "per_page":"8",
              "page": "\(page)"]
    }
  }
}

extension Endpoint {
  
  var url: URL? {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = host
    urlComponents.path = path
    
    var requestQueryItems = [URLQueryItem]()
    
    queryItems?.forEach { item in
      requestQueryItems.append(URLQueryItem(name: item.key, value: item.value))
    }
    
    requestQueryItems.append(URLQueryItem(name: "api_key", value: apiKey))
    requestQueryItems.append(URLQueryItem(name: "format", value: "json"))
    requestQueryItems.append(URLQueryItem(name: "nojsoncallback", value: "1"))
    
    urlComponents.queryItems = requestQueryItems
    
    return urlComponents.url
  }
}
