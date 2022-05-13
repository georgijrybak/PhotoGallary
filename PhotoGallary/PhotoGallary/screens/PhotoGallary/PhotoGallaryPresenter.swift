// 
//  PhotoGallaryPresenter.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import Foundation

protocol PhotoGallaryPresenterProtocol: AnyObject {
    init(view: PhotoGallaryViewControllerProtocol)
}

final class PhotoGallaryPresenter: PhotoGallaryPresenterProtocol {
    
    private weak var view: PhotoGallaryViewControllerProtocol?
    
    init(view: PhotoGallaryViewControllerProtocol) {
        self.view = view
    }
}
