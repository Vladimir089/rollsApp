//
//  LoginModel.swift
//  rollsApp
//
//  Created by Владимир Кацап on 08.04.2024.
//

import Foundation
import Alamofire

var authKey = ""

struct Login: Codable {
    let msg, authToken: String

    enum CodingKeys: String, CodingKey {
        case msg
        case authToken = "auth_token"
    }
}


