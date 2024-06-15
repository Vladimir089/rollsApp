//
//  LoginModel.swift
//  rollsApp
//
//  Created by Владимир Кацап on 08.04.2024.
//

import Foundation
import Alamofire

var authKey = ""
var cafeID = 0
var nameCafe = "Cafe"
var adresCafe = "Adres"


struct Login: Codable {
    let msg, authToken: String

    enum CodingKeys: String, CodingKey {
        case msg
        case authToken = "auth_token"
    }
}


struct Cafe: Codable {
    let id: Int
    let title: String
    let address: String
    let number: String
    let customerID: Int
    let serviceID: Int
    let img: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case address
        case number
        case customerID = "customer_id"
        case serviceID = "service_id"
        case img
    }
}
