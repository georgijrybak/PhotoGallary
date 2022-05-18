//
//  NetworkManager.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import UIKit

protocol NetworkManagerProtocol {
    func downloadImage(url: URL, size: CGSize, completion: @escaping (UIImage) -> Void)
    func fetchCredits(completion: @escaping (Result<Credits, Error>) -> Void)
}

class NetworkManager: NetworkManagerProtocol {
    enum FetcherError: Error {
        case invalidURL
        case missingData
    }

    let cacheManager = CacheManager()

    //MARK: - Manager Methods
    func downloadImage(url: URL, size: CGSize, completion: @escaping (UIImage) -> Void) {

        if let cachedImage = cacheManager.checkCachedImage(key: url) {
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
                        guard let image = UIImage(named: "imageIsNotAvaiable") else { return }
                        completion(image)
                    }
                    return
                }

                guard
                    let image = UIImage(data: data!)
                else { return }

//                self.cacheManager.cacheImage(image: image.crop(to: size), key: url)
                self.cacheManager.cacheImage(image: image, key: url)


                DispatchQueue.main.async {
                    completion(image.crop(to: size))
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
