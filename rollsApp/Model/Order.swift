
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
    let clientsNumber: Int
    let address: String
    let totalCost: Int
    let paymentMethod: String
    let paymentStatus: String
    let status: String
    let cookingTime: String?
    let orderOnTime: String?
    let cafeID: Int
    let createdDateString: String // Строковое представление даты в формате ISO8601

    // Форматирование времени создания заказа
    var formattedCreatedTime: String? {
        guard let date = createdDate else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = TimeZone.current // Установка текущего часового пояса
        return dateFormatter.string(from: date)
    }

    // Преобразование строки с датой в объект типа Date
    var createdDate: Date? {
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
        case id, phone, address, status, cookingTime, orderOnTime
        case menuItems = "menu_items"
        case totalCost = "total_cost"
        case clientsNumber = "clients_number"
        case paymentMethod = "payment_method"
        case paymentStatus = "payment_status"
        case createdDateString = "created_date"
        case cafeID = "cafe"
    }
}



struct OrdersResponse: Codable {
    let orders: [Order]
}

var orderStatus: [(Order, String)] = []

