//
//  Settings.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import UIKit

class Settings {

    static let shared = Settings()

    private init() {}
    
    enum Colors {
        static let main = UIColor.white
        static let fontColor = UIColor.white
    }

    enum Fonts {
        static let appleSDGothicNeo = "AppleSDGothicNeo-UltraLight"
    }

    enum NotificationIdentifires {
        static let currentCell = "openAlertOfCurrentCell"
    }

    enum NetworkLinks {
        static let mainLink = "http://dev.bgsoft.biz/task/"
    }
}
