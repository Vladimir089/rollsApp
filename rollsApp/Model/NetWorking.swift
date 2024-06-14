
import UIKit
import Alamofire



//MARK: -Table

extension OrderViewController { //для обновления чтобы таблица не моргала
    
 
    
    
    func regenerateTable() {
        isLoad = true
        self.refreshControl.beginRefreshing()
        
        
        print("ВЫПОЛНЯЕТСЯ ЗАГРУЗКА")
        newOrderStatus.removeAll()
        
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("application/json")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_today_orders/?cafe_id=\(cafeID)", method: .get, headers: headers).response { response in
            switch response.result {
            case .success(_):
                print(1112)
                if let data = response.data, let order = try? JSONDecoder().decode(OrdersResponse.self, from: data) {
                    DispatchQueue.global().async {
                        self.getOrderNewDetail(orders: order.orders)
                    }
                }
                
            case .failure(_):
                self.isLoad = false
                print("ERRRRRRRRROR")
                self.regenerateTable()
                return
            }
        }
        
    }
    
    
    
    func getOrderNewDetail(orders: [Order]) {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        
        for order in orders {
            let operation = BlockOperation {
                let dispatchGroup = DispatchGroup()
                let headers: HTTPHeaders = [
                    HTTPHeader.authorization(bearerToken: authKey),
                    HTTPHeader.accept("*/*")
                ]
                
                dispatchGroup.enter()
                AF.request("http://arbamarket.ru/api/v1/delivery/update_status_order/?order_id=\(order.id)&cafe_id=\(order.cafeID)", method: .post, headers: headers).responseJSON { response in
                    switch response.result {
                    case .success(_):
                        if let data = response.data, let status = try? JSONDecoder().decode(OrderStatusResponse.self, from: data) {
                            DispatchQueue.global().sync {
                                self.newOrderStatus.append((order, status))
                            }
                        }
                    case .failure(_):
                        DispatchQueue.global().sync {
                            let stat = OrderStatusResponse(status: 1, orderStatus: "Вызвать", orderColor: "#5570F1")
                            self.newOrderStatus.append((order, stat))
                            
                        }
                    }
                    dispatchGroup.leave()
                }
                dispatchGroup.wait()
            }
            operationQueue.addOperation(operation)
        }
        
        operationQueue.waitUntilAllOperationsAreFinished()
        print("-----------------------------------------")
        updateOrderStatus()
    }
    
    func updateOrderStatus() {
        indexPathsToInsert.removeAll()
        indexPathsToUpdate.removeAll()
        print("Индекс патч \(indexPathsToInsert)")
        var count = 0
        
        
        print( newOrderStatus.count)
        if isFirstLoadApp != 0 {
            print("НЕ ПЕРВАЯ ЗАГРУЗКА")
            for newOrder in newOrderStatus {
                
                let (newOrderItem, newOrderStatus) = newOrder
                if let index = orderStatus.firstIndex(where: { $0.0.id == newOrderItem.id }) {
                    let (_, existingOrderStatus) = orderStatus[index]
                    let (existingOrder, _) = orderStatus[index]
                    print(1)
                    if (existingOrderStatus.orderStatus != newOrderStatus.orderStatus) || (existingOrder.phone != newOrderItem.phone ) || (existingOrder.address != newOrderItem.address) || (existingOrder.menuItems != newOrderItem.menuItems) || (existingOrder.paymentStatus != newOrderItem.paymentStatus) ||  (existingOrder.status != newOrderItem.status) ||  (existingOrder.paymentMethod != newOrderItem.paymentMethod) {
                        indexPathsToUpdate.append(IndexPath(row: index, section: 0))
                        orderStatus[index] = (newOrderItem, newOrderStatus)
                    }
                } else {
                    count += 1
                    orderStatus.append(newOrder)
                    indexPathsToInsert.append(IndexPath(row: count - 1, section: 0))
                }
            }
        } else {
            print("ПЕРВАЯ ЗАГРУЗКА")
            DispatchQueue.concurrentPerform(iterations: newOrderStatus.count) { index in
                let newOrder = newOrderStatus[index]
                let (newOrderItem, newOrderStatus) = newOrder
                
                
                if orderStatus.indices.contains(index), let existingIndex = orderStatus.firstIndex(where: { $0.0.id == newOrderItem.id }) {
                    let (_, existingOrderStatus) = orderStatus[existingIndex]
                    let (existingOrder, _) = orderStatus[existingIndex]
                    
                    if (existingOrderStatus.orderStatus != newOrderStatus.orderStatus) || (existingOrder.phone != newOrderItem.phone ) || (existingOrder.address != newOrderItem.address) || (existingOrder.menuItems != newOrderItem.menuItems) || (existingOrder.paymentStatus != newOrderItem.paymentStatus) ||  (existingOrder.status != newOrderItem.status) ||  (existingOrder.paymentMethod != newOrderItem.paymentMethod) {
                        DispatchQueue.main.async {
                            indexPathsToUpdate.append(IndexPath(row: existingIndex, section: 0))
                            orderStatus[existingIndex] = (newOrderItem, newOrderStatus)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let count = orderStatus.count
                        orderStatus.append(newOrder)
                        indexPathsToInsert.append(IndexPath(row: count, section: 0))
                        
                    }
                }
            }
            
        }
        DispatchQueue.main.async {
            orderStatus.sort { (item1: (Order, OrderStatusResponse), item2: (Order, OrderStatusResponse)) -> Bool in
                
                let date1 = item1.0.createdDate ?? Date()
                let date2 = item2.0.createdDate ?? Date()
                return date1 > date2
            }
        }
        
        
        DispatchQueue.main.sync {
            self.mainView?.collectionView?.performBatchUpdates({
                // Сначала обновляем элементы
                self.mainView?.collectionView?.reloadItems(at: indexPathsToUpdate)
                
                print(" обновление \(indexPathsToUpdate)")
                self.mainView?.collectionView?.insertItems(at: indexPathsToInsert)
                print(" вставка \(indexPathsToInsert)")
                
            }, completion: { _ in
                if self.isOpen == false {
                    self.isLoad = false
                    print("УСПЕХ")
                    self.reloadCollection()
                    self.refreshControl.endRefreshing()
                    if isFirstLoadApp < 2 {
                        isFirstLoadApp += 1
                    }
                }
            })
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
        
        AF.request("http://arbamarket.ru/api/v1/main/get_total_cost/?menu=\(menu)&address=\(adress)", method: .get, headers: headers).responseJSON { response in
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
