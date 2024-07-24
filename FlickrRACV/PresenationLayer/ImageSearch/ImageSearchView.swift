//
//  ImageSearchView.swift
//  FlickrRACV
//
//  Created by Chirag Chaplot on 24/7/2024.
//

import SwiftUI

struct ImageSearchView: View {
  
  private let columns = Array(repeating: GridItem(.flexible()), count: 3)
  
  @State private var vm = ImageSearchViewModel()
  
  var body: some View {
    NavigationStack {
      GeometryReader { proxy in
        ZStack {
          
          background
          if vm.searchText.isEmpty && vm.allPhotos.isEmpty {
            contentUnavaialble
          } else if vm.isLoading {
            ProgressView()
          } else {
            ScrollView {
              LazyVGrid(columns: columns, spacing: 16) {
                ForEach(vm.allPhotos) { photo in
                  ImageCellView(proxy: proxy, photo: photo)
                    .task {
                      if vm.hasReachedEnd(photo: photo) && !vm.isFetching {
                        await vm.fetchNextSetOfPhotos()
                      }
                    }
                }
              }
              .padding([.leading, .trailing])
            }
            .overlay(alignment: .bottom) {
              if vm.isFetching {
                ProgressView()
              }
            }
          }
        }
        .navigationTitle("Image Search")
        .searchable(text: $vm.searchText)
        .searchSuggestions {
          ForEach(vm.getSearchSuggetions(), id: \.self) { item in
            Button {
              vm.searchText = item
              vm.showSearchSuggetions = false
            } label: {
              Label(item, systemImage: "bookmark")
            }
          }
        }
        .alert(isPresented: $vm.hasError, error: vm.error) {
          Button("Retry") {
            vm.searchText = ""
          }
        }
      }
    }
  }
}

#Preview {
  ImageSearchView()
}

private extension ImageSearchView {
  
  var background: some View {
    Theme.background
      .ignoresSafeArea()
  }
  
  var contentUnavaialble: some View {
    ContentUnavailableView("Please enter your search string above", systemImage: "magnifyingglass.circle.fill")
  }
  
}
