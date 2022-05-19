//
//  AlertActionModel.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 19.05.22.
//

import Foundation
import UIKit

struct AlertActionModel {
    var title: String
    var style: UIAlertAction.Style
    var completion: () -> ()
}
