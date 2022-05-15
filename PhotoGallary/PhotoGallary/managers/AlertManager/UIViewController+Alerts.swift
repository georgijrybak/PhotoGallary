//
//  UIViewController+Alerts.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 15.05.22.
//

import UIKit

class AlertManager {

    enum Alerts {
        case noItnernet, cantDownloadData
    }

    static let shared = AlertManager()

    func getAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        return alert
    }
}
