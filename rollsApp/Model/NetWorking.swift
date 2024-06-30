
import UIKit
import Alamofire



//MARK: -Table

var newOrdersForInsert: [Order] = []

extension OrderViewController { //для обновления чтобы таблица не моргала
    
    func formatPhoneNumber(_ phone: String) -> String {
        let digits = phone.compactMap { $0.isNumber ? $0 : nil }
        guard digits.count >= 11 else { return phone } // На случай, если номер короче ожидаемого
        
        let country = String(digits[0])
        let code = String(digits[1...3])
        let part1 = String(digits[4...6])
        let part2 = String(digits[7...8])
        let part3 = String(digits[9...10])
        
        return "+\(country) (\(code)) \(part1) \(part2) \(part3)"
    }
    
    
    func regenerateTable() {
        isLoad = true
        self.refreshControl.beginRefreshing()

        // Очищаем вспомогательные массивы
        indexPathsToInsert.removeAll()
        indexPathsToUpdate.removeAll()
        var indexPathsToDelete: [IndexPath] = []
        
        print("ВЫПОЛНЯЕТСЯ ЗАГРУЗКА")
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("application/json")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_today_orders/?cafe_id=\(cafeID)", method: .get, headers: headers).response { response in
            switch response.result {
            case .success(_):
                if let data = response.data, let order = try? JSONDecoder().decode(OrdersResponse.self, from: data) {
                    var newOrders = order.orders
                    let newOrderIDs = Set(newOrders.map { $0.id })
                    var newOrdersForInsert: [Order] = []
                    
                    for (index, existingOrder) in orderStatus.enumerated().reversed() {
                        if !newOrderIDs.contains(existingOrder.id) {
                            orderStatus.remove(at: index)
                            indexPathsToDelete.append(IndexPath(item: index, section: 0))
                        }
                    }
                    

                    for newOrder in newOrders {
                        
                        
                        var order = newOrder
                        order.phone = self.formatPhoneNumber(order.phone)
                        
                        if let existingIndex = orderStatus.firstIndex(where: {$0.id == newOrder.id}) {
                            // Заказ уже существует, проверяем на изменения
                            if orderStatus[existingIndex].phone != order.phone || orderStatus[existingIndex].menuItems != order.menuItems ||  orderStatus[existingIndex].clientsNumber != order.clientsNumber || orderStatus[existingIndex].address != order.address || orderStatus[existingIndex].totalCost != order.totalCost ||
                                orderStatus[existingIndex].paymentMethod != order.paymentMethod ||
                                orderStatus[existingIndex].status != order.status ||
                                orderStatus[existingIndex].cookingTime != order.cookingTime ||
                                orderStatus[existingIndex].orderOnTime != order.orderOnTime ||
                                orderStatus[existingIndex].step != order.step ||
                                orderStatus[existingIndex].orderForCourierStatus != order.orderForCourierStatus   {
                                
                                orderStatus[existingIndex] = order
                                let indexPath = IndexPath(item: existingIndex, section: 0)
                                indexPathsToUpdate.append(indexPath)
                            }
                        } else {
                            // Новый заказ, добавляем во временный массив
                            newOrdersForInsert.append(order)
                        }
                    }
                    
                    newOrdersForInsert.sort(by: {$0.id > $1.id})

                    // Вставляем отсортированные новые заказы в начало основного массива
                    for newOrder in newOrdersForInsert.reversed() {
                        orderStatus.insert(newOrder, at: 0)
                    }

                    // Генерируем IndexPath для новых заказов
                    indexPathsToInsert = newOrdersForInsert.indices.map { IndexPath(row: $0, section: 0) }
                    
                    DispatchQueue.main.async {
                        if isFirstLoadApp == 0 {
                            self.mainView?.collectionView?.reloadData()
                        } else {
                            // Вставляем новые элементы
                            if !indexPathsToInsert.isEmpty {
                                self.mainView?.collectionView?.insertItems(at: indexPathsToInsert)
                            }
                            // Обновляем измененные элементы
                            if !indexPathsToUpdate.isEmpty {
                                self.mainView?.collectionView?.reloadItems(at: indexPathsToUpdate)
                            }
                            
                            if !indexPathsToDelete.isEmpty {
                                self.mainView?.collectionView?.deleteItems(at: indexPathsToDelete)
                            }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.regenerateTable()
                    }
                    self.refreshControl.endRefreshing()
                    // После успешной загрузки
                    isFirstLoadApp += 1

                }
                
            case .failure(_):
                self.isLoad = false
                print("ERRRRRRRRROR")
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    self.regenerateTable()
                }
            }
        }
    }
    
    
    

    

    
    
}

//MARK: -Login

extension LoginViewController {
    func login(login: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "accept": "*/*",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "username": login,
            "password": password
        ]
        
        AF.request("http://arbamarket.ru/api/v1/accounts/login/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            debugPrint(response)
            switch response.result {
            case .success( _):
                if let data = response.data, let login = try? JSONDecoder().decode(Login.self, from: data) {
                    authKey = login.authToken
                    self.getCafeInfo()
                    
                    indexPathsToInsert.removeAll()
                    indexPathsToUpdate.removeAll()
                    orderStatus.removeAll()
                   
                    
                    
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "http://arbamarket.ru/api/v1/accounts/login/", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
                print(232)
            }
        }
    }
    
    
    func getCafeInfo() {
        
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("application/json")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/accounts/get_cafe_info/?auth_token=\(authKey)", method: .post, headers: headers).response { response in
            switch response.result {
            case .success( _):
                if let data = response.data, let cafe = try? JSONDecoder().decode(Cafe.self, from: data) {
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(cafe) {
                        UserDefaults.standard.set(encoded, forKey: "info")
                    }
                    cafeID = cafe.id
                    nameCafe = cafe.title
                    adresCafe = cafe.address
                    if cafe.number.hasPrefix("8") {
                        phoneCafe = String(cafe.number.dropFirst())
                    } else {
                        phoneCafe = cafe.number
                    }
                    
                    self.loadStandartImage(url: cafe.img)
                }
            case .failure(let error):
                print(232)
            }
            
        }
        
    }
   
    
    func loadStandartImage(url: String) {
        
        AF.request("http://arbamarket.ru\(url)").responseImage { response in
            switch response.result {
            case .success(let image):
                imageSatandart = image
            case .failure(_):
                imageSatandart = UIImage(named: "standart")
            }
            
        }
        
    }
    
}

//MARK: -Stat

extension StatViewController {
    func getStatisticAll(completion: @escaping () -> Void) {
        stat = nil
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey)]
        AF.request("http://arbamarket.ru/api/v1/main/get_statistics/?cafe_id=\(cafeID)", method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            debugPrint(response)
            switch response.result {
            case .success( _):
                if let data = response.data, let statistic = try? JSONDecoder().decode(StatisticsResponse.self, from: data) {
                    stat = statistic
                    print(statistic.orderStatistics)
                    completion()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}


extension SimilarAdressTable {
    func reload(address: String) {
        let headers: HTTPHeaders = [.accept("application/json")]
        AF.request("http://arbamarket.ru/api/v1/main/get_similar_addresses/?cafe_id=\(cafeID)&value=\(address)", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                guard let json = value as? [String: Any] else {
                    print("Invalid JSON format")
                    return
                }
                if let value = json["value"] as? String {
                    print("Value:", value)
                } else {
                    print("Value not found")
                }
                if let fullAddresses = json["full_addresses"] as? [String] {
                    self.adressArr.removeAll()
                    self.adressArr = fullAddresses
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                } else {
                    print("Full addresses not found")
                }
            case .failure(let error):
                print("Request failed with error:", error)
            }
        }
    }
    
    func getCostAdress() {
        let headers: HTTPHeaders = [.accept("application/json")]
        
        var menu = ""

        for (index, (key, value)) in menuItemsArr.enumerated() {
            let count = value.0 // Получаем первое значение типа Int из кортежа
            
            menu.append("\(key) - \(count)")
            
            if index != menuItemsArr.count - 1 {
                menu.append(", ")
            }
        }
        
        AF.request("http://arbamarket.ru/api/v1/main/get_total_cost/?cafe_id=\(cafeID)&menu=\(menu)&address=\(adress)", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    if let totalCost = json["total_cost"] as? Int,
                       let addressCost = json["address_cost"] as? Int {
                        print("Total cost:", totalCost)
                        print("Address cost:", addressCost)
                        
                        print(adress)
                        DispatchQueue.main.async {
                            self.delelagate?.fillTextField(adress: adress, cost: "\(addressCost)")
                            self.delelagate?.fillButton(coast: "\(totalCost)")
                            self.secondDelegate?.fillTextField(adress: adress)
                            self.delelagate?.updateTable()
                            self.editDelegate?.fillButton(coast: "\(totalCost)")
                            self.editDelegate?.fillTextField(adress: adress, cost: "\(addressCost)")
                            self.editDelegate?.updateTable()
                            self.secondDelegate?.dismiss()
                        }
                        
                        
                    }
                } else {
                    print("Invalid JSON format")
                }
                
            case .failure(let error):
                print("Request failed with error:", error)
                
            }
        }
    

    }
}


