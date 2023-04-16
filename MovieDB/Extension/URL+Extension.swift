//
//  URL+Extension.swift
//  MovieDB
//
//  Created by Sinan Ulusoy on 15.01.2023.
//

import UIKit

extension URL {

    typealias ImageResult = (Result<UIImage?, APIError>) -> Void
    typealias JsonResult<T> = (Result<T, APIError>) -> Void
    
    func fetchImage(completion: @escaping ImageResult) {
        ImageService.shared.checkCache(from: self) { image in
            if let image = image {
                completion(.success(image))
                return
            }
            NetworkService.shared.fetchData(url: self) { imageResponse in
                switch imageResponse {
                case .success(let data):
                    let image = ImageService.shared.dataToImage(data: data)
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchJsonData<T: Decodable>(completion: @escaping JsonResult<T>) {
        NetworkService.shared.fetchData(url: self) { dataResponse in
            switch dataResponse {
            case .success(let data):
                do {
                    let res = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(res))
                } catch {
                    completion(.failure(.decodeError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
