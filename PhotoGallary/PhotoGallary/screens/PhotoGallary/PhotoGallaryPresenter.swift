// 
//  PhotoGallaryPresenter.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import Foundation
import UIKit

protocol PhotoGallaryPresenterProtocol: AnyObject {
    init(view: PhotoGallaryViewControllerProtocol)
    func fetchCredits()
    func fetchCollectionViewCellModel(collectionViewModel: [CreditModel], indexPath: Int) -> PhotoGallaryCellModel
    func fetchModelForCollectionView() -> [CreditModel]
}

final class PhotoGallaryPresenter: PhotoGallaryPresenterProtocol {

    private weak var view: PhotoGallaryViewControllerProtocol?

    private let networkManager = NetworkManager()

    private var model = [CreditModel]()
    
    init(view: PhotoGallaryViewControllerProtocol) {
        self.view = view

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.methodOfReceivedNotification(notification:)),
            name: Notification.Name(Settings.NotificationIdentifires.safari),
            object: nil
        )
    }

//MARK: - Private Methods
    private func prepareModel(data: Credits) -> [CreditModel] {
        var models = [CreditModel]()

        for key in data.keys {
            if let value = data[key] {
                models.append(
                    CreditModel(
                        key: key,
                        photoURL: value.photoURL,
                        userURL: value.userURL,
                        userName: value.userName,
                        colors: value.colors
                    )
                )
            }
        }

        models.sorted(by: { $0.userName < $1.userName }).forEach { model in
            print(model.userName)
        }
        return models.sorted(by: { $0.userName < $1.userName } )
    }

    @objc private func methodOfReceivedNotification(notification: Notification) {
        view?.openSafari(url: notification.object as! URL)
    }

//MARK: - Protocol Methods
    func fetchCredits(){
        networkManager.fetchCredits { result in
            switch result {
            case .success(let data):
                self.model = self.prepareModel(data: data )
                self.view?.updateCollectionView()
            case .failure(let error):
                let alertModel = AlertModel(
                    title: "Opps",
                    message: error.localizedDescription,
                    actionTitle: "Try again",
                    type: .cantDownloadData
                )
                DispatchQueue.main.async {
                    self.view?.showAlert(alertModel: alertModel)
                }
            }
        }
    }

    func fetchCollectionViewCellModel(collectionViewModel: [CreditModel], indexPath: Int) -> PhotoGallaryCellModel {
        let cellModel = PhotoGallaryCellModel(
            imageURL: Settings.NetworkLinks.mainLink + collectionViewModel[indexPath].key + ".jpg",
            userName: collectionViewModel[indexPath].userName,
            photoURL: collectionViewModel[indexPath].photoURL,
            userURL: collectionViewModel[indexPath].userURL
        )
        return cellModel
    }

    func fetchModelForCollectionView() -> [CreditModel] {
        return model
    }

}
