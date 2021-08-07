//
//  ContentView.swift
//  Async
//
//  Created by Srinivas Prabhu on 07/08/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    let imageURL = "https://i.picsum.photos/id/101/2621/1747.jpg?hmac=cu15YGotS0gIYdBbR1he5NtBLZAAY6aIY5AbORRAngs"
  
    var body: some View {
      VStack{
        Image(uiImage: viewModel.image)
          .aspectRatio( contentMode: .fill)
        
        Button("Fetch Image In Swift 5.2") {
          viewModel.fetchWithSwift5(thumbnail: imageURL)
        }
        Button("Fetch Image In Swift 5.5 with Async/Await and bridged to be used in Synchronus function") { //
          Task.init(priority: .high) {
            try? await viewModel.fetch(thumbnail:imageURL)
          }
        }
        
        Button("Fetch Image With a Swift 5.2 approach using continuation") { //
          Task.init(priority: .high) {
            try? await viewModel.fetchWithOutAsyncAwaitConvertedToAsyncAwait(thumbnail: imageURL)
          }
        }
       
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
