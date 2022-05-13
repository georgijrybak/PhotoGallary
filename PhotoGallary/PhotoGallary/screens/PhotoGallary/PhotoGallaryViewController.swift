// 
//  PhotoGallaryViewController.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import UIKit

protocol PhotoGallaryViewControllerProtocol: AnyObject {
    
}

final class PhotoGallaryViewController: UIViewController, PhotoGallaryViewControllerProtocol {

    var presenter: PhotoGallaryPresenterProtocol!

    override public func viewDidLoad() -> () {
        super.viewDidLoad()

    }
}
