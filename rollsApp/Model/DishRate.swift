//
//  DishRate.swift
//  rollsApp
//
//  Created by Владимир Кацап on 25.04.2024.
//

import Foundation

struct RatingDish: Codable {
    let name: String
    let quantity: Int
}

struct RatingDishesResponse: Codable {
    let dishes: [RatingDish]
}
