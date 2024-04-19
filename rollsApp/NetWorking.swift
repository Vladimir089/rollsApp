
import UIKit
import Alamofire

extension OrderViewController { //для обновления чтобы таблица не моргала
    func regenerateTable() {
        isLoad = true
        self.refreshControl.beginRefreshing()
        
        print("ВЫПОЛНЯЕТСЯ ЗАГРУЗКА")
        newOrderStatus.removeAll()

        // Загружаем данные из сети
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("application/json")
        ]
        var arrCount = 0
        
        if orderStatus.count == 0 {
            arrCount = 15
        } else {
            arrCount = orderStatus.count
        }
            
           //ИДЕЯ - ГРУЗИТЬ В ФОНЕ ЗАКАЗЫ В ОТДЕЛЬНЫЙ АРХИВ И ПРИ ПРОКРУТКЕ ОТОБРАЖАТЬ ИХ
            
        let methods = ["page_size": 15, "page": page]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_orders_history/?cafe_id=\(cafeID)", method: .get, parameters: methods, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                if let data = response.data {
                    do {
                        let orderResponse = try JSONDecoder().decode(OrdersResponse.self, from: data)
                        DispatchQueue.global().async {
                            self.getOrderNewDetail(orders: orderResponse.orders)
                        }
                    } catch {
                        print("Failed to decode JSON:", error)
                    }
                } else {
                    print("Data is empty")
                }
                
            case .failure(let error):
                self.isLoad = false
                print(error)
                print("ERRRRRRRRROR")
                print(response)
                //self.isLoad = true
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
                            var stat = OrderStatusResponse(status: 1, orderStatus: "Вызвать", orderColor: "#5570F1")
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
        print("Номер страницы ", page)
        updateOrderStatus()
    }

    func updateOrderStatus() {
        indexPathsToInsert.removeAll()
        indexPathsToUpdate.removeAll()
        
        var count = 0
        
        
        print( newOrderStatus.count)
        if isFirstLoadApp != 0 {
            print("НЕ ПЕРВАЯ ЗАГРУЗКА")
            for newOrder in newOrderStatus {
                
                let (newOrderItem, newOrderStatus) = newOrder
                if let index = orderStatus.firstIndex(where: { $0.0.id == newOrderItem.id }) {
                    let (_, existingOrderStatus) = orderStatus[index]
                    let (existingOrder, _) = orderStatus[index]
                    
                    
                    if (existingOrderStatus.orderStatus != newOrderStatus.orderStatus) || (existingOrder.phone != newOrderItem.phone ) || (existingOrder.address != newOrderItem.address) || (existingOrder.menuItems != newOrderItem.menuItems) || (existingOrder.paymentStatus != newOrderItem.paymentStatus) ||  (existingOrder.status != newOrderItem.status) ||  (existingOrder.paymentMethod != newOrderItem.paymentMethod) {
                        print("укукцку \(count)")
                        indexPathsToUpdate.append(IndexPath(row: index, section: 0))
                        orderStatus[index] = (newOrderItem, newOrderStatus)
                        
                    }
                    
                    
                    
                } else {
                    
                    
                        print("коунт \(count)")
                        count += 1
                    if page == 1 {
                        orderStatus.append(newOrder)
                        indexPathsToInsert.append(IndexPath(row: count, section: 0))
                    } else {
                        orderStatus.insert(newOrder, at: 0)
                        indexPathsToInsert.append(IndexPath(row: 0, section: 0))

                    }
                        
                    
                    
                    
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
        
        DispatchQueue.main.sync {
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


