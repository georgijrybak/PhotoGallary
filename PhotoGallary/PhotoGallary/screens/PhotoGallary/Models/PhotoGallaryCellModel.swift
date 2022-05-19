//
//  PhotoGallaryCellModel.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import UIKit

struct PhotoGallaryCellModel {
    var userName: String
    var photoURL: String
    var userURL: String
    var image: UIImage
    var id: String
}

struct RequestCellModel {
    var size: CGSize
    var indexPath: Int
    var id: String
}
