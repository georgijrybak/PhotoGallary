//
//  NetworkModel.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 13.05.22.
//

import Foundation

struct CreditsValue: Codable {
    let photoURL, userURL: String
    let userName: String
    let colors: [String]

    enum CodingKeys: String, CodingKey {
        case photoURL = "photo_url"
        case userURL = "user_url"
        case userName = "user_name"
        case colors
    }
}

typealias Credits = [String: CreditsValue]
