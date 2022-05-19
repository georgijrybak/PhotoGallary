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
    func deleteCell(indexPath: Int)
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
            selector: #selector(self.receiveNotification(_:)),
            name: Notification.Name(Settings.NotificationIdentifires.currentCell),
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

    @objc private func receiveNotification(_ notification: Notification) {
        if
            let userURLString = notification.userInfo?["userURL"] as? String,
            let userURL = URL(string: userURLString),
            let photoURLString = notification.userInfo?["photoURL"] as? String,
            let photoURL = URL(string: photoURLString)
        {
            DispatchQueue.main.async {
                if let view = self.view {
                    let firstActionModel = AlertActionModel(
                        title: "Оpen user in Safari",
                        style: .default,
                        completion: {view.openSafari(url: userURL)}
                    )

                    let secondActionModel = AlertActionModel(
                        title: "Оpen photo in Safari",
                        style: .default,
                        completion: {view.openSafari(url: photoURL)}
                    )

                    let thirdActionModel = AlertActionModel(
                        title: "Delete",
                        style: .destructive,
                        completion: {view.deleteCell()}
                    )

                    let alert = AlertManager.shared.getAlert(
                        title: nil,
                        message: nil,
                        preferredStyle: .actionSheet,
                        actionModels: [firstActionModel, secondActionModel, thirdActionModel]
                    )

                    view.showAlert(alert)
                }
            }
        }
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
                DispatchQueue.main.async {
                    if let view = self.view {
                        let actionModel = AlertActionModel(
                            title: "Try again",
                            style: .default,
                            completion: { self.fetchCredits() }
                        )

                        let alert = AlertManager.shared.getAlert(
                            title: "Opps",
                            message: "Can't load data",
                            preferredStyle: .alert,
                            actionModels: [actionModel]
                        )

                        view.showAlert(alert)
                    }
                }
            }
        }
    }

    func fetchCollectionViewCellModel(request: RequestCellModel, completion: @escaping (PhotoGallaryCellModel) -> Void)  {

        guard let url = URL(
            string: Settings.NetworkLinks.mainLink + model[request.indexPath].key + ".jpg"
        ) else { return }

        networkManager.downloadImage(url: url, size: request.size) { [weak self] image in
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
                if let view = self.view {
                    let actionModel = AlertActionModel(
                        title: "Open settings",
                        style: .default,
                        completion: { view.openSettings() }
                    )

                    let alert = AlertManager.shared.getAlert(
                        title: "Opps",
                        message: "Device is not connected to the internet",
                        preferredStyle: .alert,
                        actionModels: [actionModel]
                    )

                    view.showAlert(alert)
                }
            }
        }
    }

    func deleteCell(indexPath: Int) {
        model.remove(at: indexPath)

        switch indexPath {
        case 1:
            model.remove(at: model.count - 1)
            model.insert(model[1], at: model.count)
        case model.count - 1:
            model.remove(at: 0)
            model.insert(model[model.count - 2], at: 0)
        default: break
        }
    }
}

