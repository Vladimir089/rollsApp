//
//  OrderViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit
import Alamofire
import AlamofireImage


let cafeID = 2

protocol OrderViewControllerDelegate: AnyObject {
    func reloadCollection()
    func createButtonGo(index: Int)
    func succes()
    func startTime()
    func stopTime()
}


class OrderViewController: UIViewController {
    
    var mainView: AllOrdersView?
    var timer: Timer?
    var newOrderStatus: [(Order, String)] = []
    var indexPathsToUpdate: [IndexPath] = []
    
    
    override func loadView() {
        login(login: "Bairam", password: "1122")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView = AllOrdersView()
        self.view = mainView
        mainView?.addNewOrderButton?.addTarget(self, action: #selector(newOrder), for: .touchUpInside)
        mainView?.delegate = self
    }
    @objc func timerAction() {
        regenerateTable()
        print("Timer fired!")
    }
    
    func startTimer() {
        let timeInterval: TimeInterval = 30.0
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func newOrder() {
        let vc = NewOrderViewController()
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func getAllOrders(isTimer: Bool)  {
        orderStatus.removeAll()
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("application/json")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_orders_history/?cafe_id=\(cafeID)", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                if let data = response.data, let order = try? JSONDecoder().decode(OrdersResponse.self, from: data) {
                   
                    DispatchQueue.global().async {
                        self.getOrderDetail(orders: order.orders)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getOrderDetail(orders: [Order]) {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 50
  
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
                            DispatchQueue.main.async {
                                orderStatus.append((order, status.orderStatus))
                                print("статус \(status.orderStatus)")
                            }
                        }
                    case .failure(_):
                        DispatchQueue.main.async {
                            orderStatus.append((order, "Вызвать"))
                            print(1)
                        }
                    }
                    dispatchGroup.leave()
                }
                dispatchGroup.wait()
            }
            operationQueue.addOperation(operation)
        }
        
        operationQueue.waitUntilAllOperationsAreFinished()
        
        orderStatus.sort { (item1, item2) -> Bool in
            let date1 = item1.0.createdDate ?? Date()
            let date2 = item2.0.createdDate ?? Date()
            return date1 > date2
        }
        
        DispatchQueue.main.async {
            print(orderStatus)
            self.mainView?.collectionView?.reloadData()
        }
    }

    
    func login(login: String, password: String) {
        let headers: HTTPHeaders = [
            "accept": "*/*",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "username": login,
            "password": password
        ]
        
        AF.request("http://arbamarket.ru/api/v1/accounts/login/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success( _):
                if let data = response.data, let login = try? JSONDecoder().decode(Login.self, from: data) {
                    authKey = login.authToken
                    
                    self.getAllOrders(isTimer: false)
                    self.getDishes()
                    self.startTimer()
                }
                
            case .failure(let error):
                print("Произошла ошибка: \(error)")
                
            }
        }
    }
    
    func getDishes() {
        
        allDishes.removeAll()
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("application/json")
        ]
        AF.request("http://arbamarket.ru/api/v1/main/get_dishes/?cafe_id=\(cafeID)", method: .get, headers: headers).responseData{ response in
            switch response.result {
            case .success(_):
                if let data = response.data, let dishes = try? JSONDecoder().decode(DishesResponse.self, from: data) {
                    
                    for i in dishes.dishes {
                        self.getImage(d: i)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    
    func getImage(d: Dish) {
        //http://arbamarket.ru/media/main/dishes/image_27.png
        if let url = d.img {
            AF.request("http://arbamarket.ru\(url)").responseImage { response in
                switch response.result {
                case .success(let image):
                    allDishes.append((d, image))
                case .failure(let error):
                    allDishes.append((d, .imageDishes))
                }
                
            }
        }
    }
    
    
    
}

extension OrderViewController: OrderViewControllerDelegate {
    func succes() {
        mainView?.succes()
    }
    
    
    
    func createButtonGo(index: Int) {
        let dispatchGroup = DispatchGroup()
        
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        if orderStatus.count < index {
            return
        }
        
        dispatchGroup.enter()
        let currentOrder = orderStatus[index]
        AF.request("http://arbamarket.ru/api/v1/delivery/create_order/?order_id=\(currentOrder.0.id)&cafe_id=\(currentOrder.0.cafeID)", method: .post, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                print(response)
            case .failure(_):
                print(1)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .global()) {
            DispatchQueue.main.sync {
                self.getAllOrders(isTimer: false)
            }
            
        }
    }
    
    func reloadCollection() {
        regenerateTable()
    }
    
    func stopTime() {
        print(12)
        stopTimer()
    }
    
    func startTime() {
        print(1333)
        self.startTimer()
    }
    
    
}

extension OrderViewController { //для обновления чтобы таблица не моргала
    func regenerateTable() {
        newOrderStatus.removeAll()
        mainView?.addNewOrderButton?.isUserInteractionEnabled = false
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("application/json")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_orders_history/?cafe_id=\(cafeID)", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                if let data = response.data, let order = try? JSONDecoder().decode(OrdersResponse.self, from: data) {
                   
                    DispatchQueue.global().async {
                        self.getOrderNewDetail(orders: order.orders)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
  
    
    func getOrderNewDetail(orders: [Order]) {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 50
  
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
                            DispatchQueue.main.async {
                                self.newOrderStatus.append((order, status.orderStatus))
                            }
                        }
                    case .failure(_):
                        DispatchQueue.main.async {
                            self.newOrderStatus.append((order, "Вызвать"))
                        }
                    }
                    dispatchGroup.leave()
                }
                dispatchGroup.wait()
            }
            operationQueue.addOperation(operation)
        }
        
        operationQueue.waitUntilAllOperationsAreFinished()
        
        
        
        
        
        updateOrderStatus()
        
        
        
    }
    
    
    func updateOrderStatus() {
        var indexPathsToInsert: [IndexPath] = []
        var indexPathsToUpdate: [IndexPath] = []
        var count = 0
        for newOrder in newOrderStatus {
                let (newOrderItem, newOrderStatus) = newOrder
                if let index = orderStatus.firstIndex(where: { $0.0.id == newOrderItem.id }) {
                    // Заказ уже присутствует в orderStatus, проверяем статус
                    let (existingOrderItem, existingOrderStatus) = orderStatus[index]
                    if existingOrderStatus != newOrderStatus {
                        indexPathsToUpdate.append(IndexPath(row: index, section: 0))
                        orderStatus[index] = (newOrderItem, newOrderStatus)
                        indexPathsToUpdate.append(IndexPath(row: index, section: 0))
                    }
                } else {
                    count += 1
                    orderStatus.append(newOrder)
                }
            }

        
        orderStatus.sort { (item1, item2) -> Bool in
            let date1 = item1.0.createdDate ?? Date()
            let date2 = item2.0.createdDate ?? Date()
            return date1 > date2
        }
        
        
        DispatchQueue.main.async {
            let newCount = (self.newOrderStatus.count - orderStatus.count) + count // Определяем количество новых элементов
            guard newCount > 0 else {
                self.mainView?.addNewOrderButton?.isUserInteractionEnabled = true
                return
            }

            for index in 0..<newCount {
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToInsert.append(indexPath)
            }

            UIView.animate(withDuration: 0.8) {
                self.mainView?.collectionView?.performBatchUpdates({
                    self.mainView?.collectionView?.insertItems(at: indexPathsToInsert)
                    self.mainView?.collectionView?.reloadItems(at: indexPathsToUpdate)
                    self.mainView?.addNewOrderButton?.isUserInteractionEnabled = true
                }, completion: nil)
            }
        }

    }

    
}
