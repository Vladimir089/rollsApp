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


func login(login: String, password: String, completion: @escaping (Bool) -> Void) {
    let headers: HTTPHeaders = [
        "accept": "*/*",
        "Content-Type": "application/json"
    ]
    
    let parameters: [String: Any] = [
        "username": login,
        "password": password
    ]
    
    AF.request("http://arbamarket.ru/api/v1/accounts/login/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
        switch response.result {
        case .success( _):
            if let data = response.data, let login = try? JSONDecoder().decode(Login.self, from: data) {
                authKey = login.authToken
                completion(true)
            } else {
                completion(false)
            }
           
        case .failure(let error):
            print("Произошла ошибка: \(error)")
            completion(false)
        }
    }
}
