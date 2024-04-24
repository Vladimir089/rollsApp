import Foundation

struct StatisticsResponse: Codable {
    let earningsStatistics: EarningsStatistics
    let orderStatistics: [OrderStatistics]
    
    enum CodingKeys: String, CodingKey {
        case earningsStatistics = "earnings_statistics"
        case orderStatistics = "order_statistics"
    }
}

struct EarningsStatistics: Codable {
    let cash: Int
    let toCourier: Int
    let remittance: Int
    let atCheckout: Int
    let total: Double
    
    enum CodingKeys: String, CodingKey {
        case cash
        case toCourier = "to_courier"
        case remittance
        case atCheckout = "at_checkout"
        case total
    }
}

struct OrderStatistics: Codable {
    let date: String
    let count: Int
}


var stat: StatisticsResponse?
