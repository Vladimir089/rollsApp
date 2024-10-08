
import Foundation



struct OrderStatusResponse: Codable {
    let status: Int
    let orderStatus: String
    let orderColor: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case orderStatus = "order_status"
        case orderColor = "order_color"
    }
}


struct Order: Codable {
    let id: Int
    var phone: String
    let menuItems: String
    let clientsNumber: String
    let address: String
    let totalCost: Int?
    let paymentMethod: String
    var paymentStatus: String
    let status: String
    let cookingTime: String?
    let orderOnTime: String?
    let cafeID: Int
    let createdDateString: String?
    let step: Int?
    let orderForCourierStatus: String?
    let issued: Bool?
    let modifications: String?

    var formattedCreatedTime: String? {
        guard let date = createdDate else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }


    var createdDate: Date? {
        guard let dateString = createdDateString, !dateString.isEmpty else {
            return nil
        }

        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoDateFormatter.date(from: dateString) {
            return date
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return dateFormatter.date(from: dateString)
        }
    }


    enum CodingKeys: String, CodingKey {
        case id, phone, address, status, cookingTime, orderOnTime, modifications
        case menuItems = "menu_items"
        case totalCost = "total_cost"
        case clientsNumber = "clients_number"
        case paymentMethod = "payment_method"
        case paymentStatus = "payment_status"
        case createdDateString = "created_date"
        case cafeID = "cafe"
        case step = "step"
        case orderForCourierStatus = "order_for_courier__status"
        case issued = "issued"
        
    }
}



struct OrdersResponse: Codable {
    let orders: [Order]
}

var orderStatus: [(Order)] = []

