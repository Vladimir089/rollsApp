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
var isFirstLoadApp = true

var indexPathsToInsert: [IndexPath] = []
var indexPathsToUpdate: [IndexPath] = []
protocol OrderViewControllerDelegate: AnyObject {
    func reloadCollection()
    func createButtonGo(index: Int)
    func closeVC()
}


class OrderViewController: UIViewController {
    
    var mainView: AllOrdersView?
    var isFirstLoad = true
    var newOrderStatus: [(Order, String)] = []

    var isLoad = false
    let queue = DispatchQueue(label: "Timer")
    var isOpen = false
    var isWorkCicle = false
    
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
   
    func backgroundTask() {
        isWorkCicle = true
        while true {
            if (isLoad == true && isOpen == true) || (isLoad == false && isOpen == true) || (isLoad == true && isOpen == false) {
                sleep(1)
                print("НЕТ")
            } else {
                print("ДА")
                regenerateTable()
                isWorkCicle = false
                break
            }
        }
    }
    
   
    
    @objc private func newOrder() {
        let vc = NewOrderViewController()
        vc.delegate = self
        isLoad = true
        isOpen = true
        self.present(vc, animated: true)
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
                    
                    self.reloadCollection()
                    self.getDishes()
                    
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
    func closeVC() {
        isLoad = false
        isOpen = false
        if isWorkCicle == false {
            print("ЗАПУСК")
            backgroundTask()
        }

    }
    

    
    
    
    func createButtonGo(index: Int) {
        
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        if orderStatus.count < index {
            return
        }
        
        let currentOrder = orderStatus[index]
        AF.request("http://arbamarket.ru/api/v1/delivery/create_order/?order_id=\(currentOrder.0.id)&cafe_id=\(currentOrder.0.cafeID)", method: .post, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                print(response)
            case .failure(_):
                print(1)
            }
        }
        

    }
    
    func reloadCollection() {
        if isLoad == false && isOpen == false  {
            print("ЗАКРЫТО")
            regenerateTable()
        } else {
           print("ОТКРЫТО")
            queue.async {
                self.backgroundTask()
            }
        }
    }
    
   
    
    
}

extension OrderViewController { //для обновления чтобы таблица не моргала
    func regenerateTable() {
        isLoad = true
        print("ВЫПОЛНЯЕТСЯ ЗАГРУЗКА")
        newOrderStatus.removeAll()
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
                
            case .failure(_):
                self.isLoad = false
                print("ERRRRRRRRROR")
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
                                self.newOrderStatus.append((order, status.orderStatus))
                            }
                        }
                    case .failure(_):
                        DispatchQueue.global().sync {
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
        print("-----------------------------------------")
        updateOrderStatus()
    }

    func updateOrderStatus() {
        indexPathsToInsert.removeAll()
        indexPathsToUpdate.removeAll()
        print("Индекс патч \(indexPathsToInsert)")
        var count = 0

        
        print( newOrderStatus.count)
        for newOrder in newOrderStatus {
            
            let (newOrderItem, newOrderStatus) = newOrder
            if let index = orderStatus.firstIndex(where: { $0.0.id == newOrderItem.id }) {
                let (_, existingOrderStatus) = orderStatus[index]
                if existingOrderStatus != newOrderStatus {
                    indexPathsToUpdate.append(IndexPath(row: index, section: 0))
                    orderStatus[index] = (newOrderItem, newOrderStatus)
                }
            } else {
                count += 1
                orderStatus.append(newOrder)
                // Добавляем новый индекс только если это новый элемент
                indexPathsToInsert.append(IndexPath(row: count - 1, section: 0))
            }
        }

        orderStatus.sort { (item1, item2) -> Bool in
            let date1 = item1.0.createdDate ?? Date()
            let date2 = item2.0.createdDate ?? Date()
            return date1 > date2
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
                    isFirstLoadApp = false
                }
            })
        }
    }



    
}
