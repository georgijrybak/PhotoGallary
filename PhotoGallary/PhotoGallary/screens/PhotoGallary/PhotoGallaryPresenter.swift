// 
//  PhotoGallaryPresenter.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import UIKit
import Network

protocol PhotoGallaryPresenterProtocol: AnyObject {
    init(view: PhotoGallaryViewControllerProtocol)
    func fetchCredits()
    func fetchCollectionViewCellModel(request: RequestCellModel, completion: @escaping (PhotoGallaryCellModel) -> Void)
    func fetchModelForCollectionView() -> [CreditModel]
    func fetchTimerStarted()
    func fetchTimerStopped()
}

final class PhotoGallaryPresenter: PhotoGallaryPresenterProtocol, NetworkCheckManagerDelegate {

    private weak var view: PhotoGallaryViewControllerProtocol?

    var networkManager: NetworkManagerProtocol!

    private var model = [CreditModel]()

    private var timer = Timer()
    
    init(view: PhotoGallaryViewControllerProtocol) {
        self.view = view
        NetworkCheckManager.shared.delegate = self

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

        models.sort(by: { $0.userName < $1.userName })
        models.append(models[0])
        models.insert(models[models.count - 2], at: 0)

        return models
    }

    @objc private func methodOfReceivedNotification(notification: Notification) {
        view?.openSafari(url: notification.object as! URL)
    }

    @objc private func moveNext() {
        view?.moveToNextPhoto()
    }

    //MARK: - Protocol Methods
    func fetchCredits(){
        networkManager.fetchCredits { result in
            switch result {
            case .success(let data):
                self.model = self.prepareModel(data: data )
                self.view?.updateCollectionView()
            case .failure(_):
                let alertModel = AlertModel(
                    title: "Opps",
                    message: "Can't load data",
                    actionTitle: "Try again",
                    type: .cantDownloadData
                )
                DispatchQueue.main.async {
                    self.view?.showAlert(alertModel: alertModel)
                }
            }
        }
    }

    func fetchCollectionViewCellModel(request: RequestCellModel, completion: @escaping (PhotoGallaryCellModel) -> Void)  {

        let url = URL(string: Settings.NetworkLinks.mainLink + model[request.indexPath].key + ".jpg")

        networkManager.downloadImage(url: url!, size: request.size) { [weak self] image in
            guard let self = self else { return }
            let cellModel = PhotoGallaryCellModel(
                userName: self.model[request.indexPath].userName,
                photoURL: self.model[request.indexPath].photoURL,
                userURL: self.model[request.indexPath].userURL,
                image: image,
                id: request.id
            )
            completion(cellModel)
        }
    }

    func fetchModelForCollectionView() -> [CreditModel] {
        return model
    }

    func fetchTimerStarted() {
        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(moveNext),
            userInfo: nil,
            repeats: true
        )
    }

    func fetchTimerStopped() {
        timer.invalidate()
    }

    func connectionStatus(isConnected: Bool) {
        if !isConnected {
            DispatchQueue.main.async {
                self.view?.showAlert(
                    alertModel: AlertModel(
                        title: "Opps",
                        message: "Device is not connected to the internet",
                        actionTitle: "Open settings",
                        type: .noItnernet
                    )
                )
            }
        }
    }
}

