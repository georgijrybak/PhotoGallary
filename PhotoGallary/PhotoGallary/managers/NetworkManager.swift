//
//  NetworkManager.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import UIKit

class NetworkManager {
    enum FetcherError: Error {
        case invalidURL
        case missingData
    }

    let cacheManager = CacheManager()

    //MARK: - Manager Methods
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {

        if let cachedImage = cacheManager.chechCachedImage(key: url) {
            completion(cachedImage)
        } else {
            let request = URLRequest(
                url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad,
                timeoutInterval: 10
            )
            let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

                guard error == nil,
                      data != nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let `self` = self
                else {
                    DispatchQueue.main.async {
                        completion(UIImage(named: "imageIsNotAvaiable"))
                    }
                    return
                }

                guard
                    let image = UIImage(data: data!),
                    let compressedImage = image.compressTo(1)
                else { return }

                self.cacheManager.cacheImage(image: compressedImage, key: url)

                DispatchQueue.main.async {
                    completion(compressedImage)
                }
            }
            dataTask.resume()
        }
    }

    func fetchCredits(completion: @escaping (Result<Credits, Error>) -> Void) {
        guard let url = URL(string: Settings.NetworkLinks.mainLink) else {
            completion(.failure(FetcherError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(FetcherError.missingData))
                return
            }

            do {
                let result = try JSONDecoder().decode(Credits.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }

        }.resume()
    }
}
