//
//  AlertModel.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 15.05.22.
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var actionTitle: String
    var style: UIAlertController.Style
    var type: AlertManager.Alerts
    var data: [String: String]?
    var actions: [AlertActionModel]
}
