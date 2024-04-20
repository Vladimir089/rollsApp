
import UIKit
import Alamofire

var oldPage = 0


extension OrderViewController { //для обновления чтобы таблица не моргала
    
    
    func regenerateTable(forPage page : Int) {
        isLoad = true
        self.refreshControl.beginRefreshing()
        let dispatchGroup = DispatchGroup()
        
        print("ВЫПОЛНЯЕТСЯ ЗАГРУЗКА")
        newOrderStatus.removeAll()

        // Загружаем данные из сети
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("application/json")
        ]

     var pageSize = page * 15
           
            
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
        operationQueue.maxConcurrentOperationCount = 1
  
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
        updateOrderStatus() { [weak self] in
            DispatchQueue.main.sync {
                orderStatus.sort { (item1: (Order, OrderStatusResponse), item2: (Order, OrderStatusResponse)) -> Bool in
                    
                    let date1 = item1.0.createdDate ?? Date()
                    let date2 = item2.0.createdDate ?? Date()
                    return date1 > date2
                    
                }
                
                self?.mainView?.collectionView?.performBatchUpdates({
                    self?.mainView?.collectionView?.insertItems(at: indexPathsToInsert)

                    self?.mainView?.collectionView?.reloadItems(at: indexPathsToUpdate)
                    print(" обновление \(indexPathsToUpdate)")
                    //self?.mainView?.collectionView?.insertItems(at: indexPathsToInsert)
                    print(" вставка \(indexPathsToInsert)")
                    
                }, completion: { _ in
                    if let isOpen = self?.isOpen, isOpen == false {
                        self?.isLoad = false
                        
                       
                        
                        print("УСПЕХ")
                        self?.reloadCollection(forPage: page)
                        self?.refreshControl.endRefreshing()
                        if isFirstLoadApp < 2 {
                            isFirstLoadApp += 1
                        }
                    }
                })
            }
        }

    }

    func updateOrderStatus(completion: (() -> Void)?)  {
        indexPathsToInsert.removeAll()
        indexPathsToUpdate.removeAll()

        // Пройдемся по новым данным и сравним их с существующими данными
        for newOrder in newOrderStatus {
            let (newOrderItem, newOrderStatus) = newOrder
            
            if let index = orderStatus.firstIndex(where: { $0.0.id == newOrderItem.id }) {
                let (_, existingOrderStatus) = orderStatus[index]
                let (existingOrder, _) = orderStatus[index]

                // Если какое-то из полей отличается, обновим элемент в массиве orderStatus
                if (existingOrderStatus.orderStatus != newOrderStatus.orderStatus) ||
                   (existingOrder.phone != newOrderItem.phone ) ||
                   (existingOrder.address != newOrderItem.address) ||
                   (existingOrder.menuItems != newOrderItem.menuItems) ||
                   (existingOrder.paymentStatus != newOrderItem.paymentStatus) ||
                   (existingOrder.status != newOrderItem.status) ||
                   (existingOrder.paymentMethod != newOrderItem.paymentMethod) {
                    indexPathsToUpdate.append(IndexPath(row: index, section: 0))
                    orderStatus[index] = (newOrderItem, newOrderStatus)
                }
            } else {
                // Если элемент не найден в orderStatus, добавим его
                if page == 1  {
                    // Если пользователь находится на первой странице, добавляем новый заказ в начало массива
                    orderStatus.insert(newOrder, at: 0)
                    indexPathsToInsert.append(IndexPath(row: 0, section: 0))
                } else {
                    // В противном случае добавляем в конец массива
                    let count = orderStatus.count
                    orderStatus.append(newOrder)
                    indexPathsToInsert.append(IndexPath(row: count, section: 0))
                }
            }
        }

        completion?()
    }


}


