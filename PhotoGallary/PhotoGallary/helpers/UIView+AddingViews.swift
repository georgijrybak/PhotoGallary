//
//  UIView+AddingViews.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 14.05.22.
//

import UIKit

extension UIView {
    func addSubviews(_ array: [UIView]) {
        array.forEach {
            addSubview($0)
        }
    }
}
