//
//  CreateOrder.swift
//  rollsApp
//
//  Created by Владимир Кацап on 09.04.2024.
//

import Foundation
import UIKit

var menuItemsArr = [String: (Int, Int)]() //тут сам заказ, надо перевести в массив строк при создании заказа
var menuItemIndex = [(String, Int)]() //хранение ключей 
var adress = ""
var totalCoast = 0




var allDishes: [(Dish, UIImage)] = []

struct Dish: Codable {
    let id: Int
    let name: String
    let category: String
    let price: Int
    let img: String?
}

struct DishesResponse: Codable {
    let dishes: [Dish]
}


