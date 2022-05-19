//
//  AlertManager.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 15.05.22.
//

import UIKit

class AlertManager {

    enum Alerts {
        case noItnernet, cantDownloadData, cellNotification
    }

    static let shared = AlertManager()

    func getAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style, actionModels: [AlertActionModel]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        for actionModel in actionModels {
            let action = UIAlertAction(title: actionModel.title, style: actionModel.style) { _ in
                actionModel.completion()
            }
            alert.addAction(action)
        }

        return alert
    }
}
