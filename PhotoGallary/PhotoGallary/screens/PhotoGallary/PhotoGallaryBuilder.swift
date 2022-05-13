// 
//  PhotoGallaryBuilder.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import UIKit

final class PhotoGallaryBuilder {
    
    static func build() -> PhotoGallaryViewController {
        let view = PhotoGallaryViewController()
        let presenter = PhotoGallaryPresenter(view: view)
        
        view.presenter = presenter
        
        return view
    }
    
}
