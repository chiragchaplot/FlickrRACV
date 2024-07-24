//
//  ImageSearchViewModel.swift
//  FlickrRACV
//
//  Created by Chirag Chaplot on 24/7/2024.
//

import Foundation
import Combine

@Observable
final class ImageSearchViewModel {
    
    private(set) var allPhotos: [Photo] = []
    private(set) var photoIds = [String]()
    private(set) var error: NetworkingManager.NetworkingError?
    private(set) var viewState: ViewState?
    private let networkingManager: NetworkingManagerImpl
    
    private(set) var page = 1
    private(set) var totalPages: Int?
    var searchHistory = [String]()
    var showSearchSuggetions = false
    var hasError = false
    private var searchTextPublisher = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var searchText = "" {
        didSet {
            if oldValue != searchText {
                searchTextPublisher.send(searchText)
            }
        }
    }
    
    var isLoading: Bool {
        viewState == .loading
    }
    
    var isFetching: Bool {
        viewState == .fetching
    }
    
    init(networkingManager: NetworkingManagerImpl = NetworkingManager.shared) {
        self.networkingManager = networkingManager
        self.addSubscribers()
    }
    
    func addSubscribers() {
        searchTextPublisher
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                if newValue.isEmpty {
                    reset()
                    showSearchSuggetions = true
                } else {
                    addToSearchHistsory(query: newValue)
                    Task {
                        await self.fetchPhotos(query: newValue)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func addToSearchHistsory(query: String) {
        if !self.searchHistory.contains(query) && query.count > 2 {
            self.searchHistory.insert(query, at: 0)
            showSearchSuggetions = false
        }
    }
    
    func getSearchSuggetions() -> [String] {
        let filteredSearchHistory = searchHistory.filter { item in
            item.contains(searchText)
        }
        
        if searchText.isEmpty {
            return searchHistory
        } else if showSearchSuggetions == false {
            return [String]()
        } else {
            return filteredSearchHistory
        }
    }

    func fetchPhotos(query: String) async {
        reset()
        viewState = .loading
        defer { viewState = .finished }
        
        do {
            let response = try await networkingManager.request(session: .shared, .search(text: query, page: page), type: ImageSearchResponse.self)
            self.totalPages = response.photos.pages
            appendUniquePhotos(photos: response.photos.photo)
        } catch {
            self.hasError = true
            if let networkingError = error as? NetworkingManager.NetworkingError {
                self.error = networkingError
            } else {
                self.error = .custom(error: error)
            }
        }
    }
    
    func fetchNextSetOfPhotos() async {
        guard page != totalPages else {
            return
        }
        
        viewState = .fetching
        defer {
            viewState = .finished
        }
        
        page += 1
    
        do {
            let response = try await networkingManager.request(session: .shared, .search(text: searchText, page: page), type: ImageSearchResponse.self)
            self.totalPages = response.photos.pages
            appendUniquePhotos(photos: response.photos.photo)
        } catch {
            self.hasError = true
            if let networkingError = error as? NetworkingManager.NetworkingError {
                self.error = networkingError
            } else {
                self.error = .custom(error: error)
            }
        }
    }
    
    func hasReachedEnd(photo: Photo) -> Bool {
        return photoIds.suffix(4).contains(photo.id)
    }
    
    ///
    ///  Flickr service response is returning photos with duplicate id's, because of this SwiftUI - LazyVGrid - cells are getting from visisble range.
    ///  So appending only photos with unique id's ...to keep the list elements unique...
    func appendUniquePhotos(photos: [Photo]) {
        for photo in photos {
            if !photoIds.contains(photo.id) {
                photoIds.append(photo.id)
                allPhotos.append(photo)
            }
        }
    }
}

extension ImageSearchViewModel {
    enum ViewState {
        case loading
        case fetching
        case finished
    }
}

extension ImageSearchViewModel {
    func reset() {
        if viewState == .finished {
            allPhotos.removeAll()
            photoIds.removeAll()
            page = 1
            totalPages = nil
            viewState = nil
        }
    }
}
