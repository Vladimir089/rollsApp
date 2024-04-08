
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
    let phone: String
    let menuItems: String
    let clientsNumber: Int?
    let address: String
    let totalCost: Double?
    let paymentMethod: String
    let paymentStatus: String
    let status: String
    let cookingTime: String?
    let orderOnTime: String?
    let cafeID: Int
    let createdDateString: String // Строковое представление даты в формате ISO8601

    var formattedCreatedTime: String? {
           guard let date = createdDate else { return nil }
           
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "h:mm a"
           dateFormatter.timeZone = TimeZone.current // Установка текущего часового пояса
           return dateFormatter.string(from: date)
       }

    
    var createdDate: Date? { //+ 3 часа
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = isoDateFormatter.date(from: createdDateString) {
                return date
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Ваш текущий формат
                return dateFormatter.date(from: createdDateString)
            }
        }
    

    enum CodingKeys: String, CodingKey {
        case id, phone, clientsNumber, address, totalCost, status, cookingTime, orderOnTime
        case menuItems = "menu_items"
        case paymentMethod = "payment_method"
        case paymentStatus = "payment_status"
        case createdDateString = "created_date"
        case cafeID = "cafe_id"
    }
}


struct OrdersResponse: Codable {
    let orders: [Order]
}

var orderStatus: [(Order, String)] = []

