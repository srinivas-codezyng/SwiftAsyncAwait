//
//  ImageLoader.swift
//  ImageLoader
//
//  Created by Srinivas Prabhu on 07/08/21.
//

import Foundation
import UIKit

enum FetchError:Error{
  case badID
}

class ViewModel:ObservableObject{
  @Published var image:UIImage = UIImage()
  
  func fetch(thumbnail:String) async throws {
    self.image = try await fetchAsync(thumbnail: thumbnail)
  }
  
  func fetchWithSwift5(thumbnail:String) {
    fetchWithOutAsyncAwait(thumbnail: thumbnail) { image in
      if  case let .success(loadedImage) = image {
        DispatchQueue.main.async { [weak self] in
          self?.image = loadedImage
        }
      }
    }
  }
  
  func fetchWithOutAsyncAwaitConvertedToAsyncAwait(thumbnail:String) async throws -> UIImage  {
    typealias ImageFetch = CheckedContinuation<UIImage,Error>
    
    return try await withCheckedThrowingContinuation { (continuation:ImageFetch) in
      fetchWithOutAsyncAwait(thumbnail: thumbnail) { [weak self] result in
        switch result {
          case .success(let image) :
          DispatchQueue.main.async { [weak self] in
            self?.image = image
            continuation.resume(returning: image)
          }
          case .failure(let failureValue) : continuation.resume(throwing: failureValue)
        }
      }
    }
  }
  
  func fetchWithOutAsyncAwait(thumbnail:String, completion:@escaping((Result<UIImage,Error>)->Void)) {
    let request = URLRequest.init(url: URL.init(string: thumbnail)!)
    
    let task = URLSession.shared.dataTask(with: request) {  data, response, error in
      if let error = error {
        completion(.failure(error))
      } else if let code = (response as? HTTPURLResponse)?.statusCode, code != 200 {
        completion(.failure(FetchError.badID))
      }else{
        guard let image = UIImage.init(data: data!) else {
          completion(.failure(FetchError.badID))
          return
        }
        image.prepareThumbnail(of: CGSize(
          width: 300,
          height: 300)) {  image in
            guard let image = image else {
              completion(.failure(FetchError.badID))
              return
            }
            completion(.success(image))
          }
      }
      
      
    }
    task.resume()
  }
  
  func fetchAsync(thumbnail:String) async throws -> UIImage{
    let request = URLRequest.init(url: URL.init(string: thumbnail)!)
    let (data, response) =  try await URLSession.shared.data(for: request)
      
    guard let code = (response as? HTTPURLResponse)?.statusCode, code == 200  else {
      throw FetchError.badID
    }

    let image = UIImage(data: data)
    
    guard let image = await image?.thumbnail else {
      throw FetchError.badID
    }
    
    return image
  }
  
}


extension UIImage {
  var thumbnail: UIImage?{
    get async {
      let size = CGSize(width: 300, height: 300)
      return await byPreparingThumbnail(ofSize: size)
    }
  }
}
