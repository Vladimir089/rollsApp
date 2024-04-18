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
var isFirstLoadApp = 0


var indexPathsToInsert: [IndexPath] = []
var indexPathsToUpdate: [IndexPath] = []
protocol OrderViewControllerDelegate: AnyObject {
    func reloadCollection()
    func createButtonGo(index: Int)
    func closeVC()
    func detailVC(index: Int)
}


class OrderViewController: UIViewController {
    
    var mainView: AllOrdersView?
    var isFirstLoad = true
    var newOrderStatus: [(Order, OrderStatusResponse)] = []

    var isLoad = false
    let queue = DispatchQueue(label: "Timer")
    var isOpen = false
    var isWorkCicle = false
    var refreshControl = UIRefreshControl()
    

    
    override func loadView() {
        login(login: "Bairam", password: "1122")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView = AllOrdersView()
        self.view = mainView
        mainView?.addNewOrderButton?.addTarget(self, action: #selector(newOrder), for: .touchUpInside)
        mainView?.delegate = self
        setupRefreshControl()
    }
    
    func setupRefreshControl() {
        //refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        mainView?.collectionView?.refreshControl = refreshControl
    }
    
    @objc func refreshData() {
        refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func backgroundTask() {
        isWorkCicle = true
        while true {
            if (isLoad == true && isOpen == true) || (isLoad == false && isOpen == true) || (isLoad == true && isOpen == false) {
                sleep(1)
                print("НЕТ")
                DispatchQueue.main.sync { [self] in
                    self.refreshControl.endRefreshing()
                }
            } else {
                print("ДА")
                DispatchQueue.main.async { [self] in
                    regenerateTable()
                    isWorkCicle = false
                }
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
    func detailVC(index: Int) {
        let vc = EditViewController()
        isLoad = true
        isOpen = true
        vc.delegate = self
        vc.indexOne = index
        let backItem = UIBarButtonItem()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 17), // Устанавливаем жирный шрифт размером 17
            .foregroundColor: UIColor.black // Устанавливаем цвет текста в черный
        ]
        self.navigationItem.backBarButtonItem = backItem
        backItem.title = "Заказ №\(orderStatus[index].0.id)"
        backItem.setTitleTextAttributes(attributes, for: .normal)
        
        self.refreshControl.endRefreshing()

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
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
            arrCount = 10
        } else {
            arrCount = orderStatus.count
        }
            
           //ИДЕЯ - ГРУЗИТЬ В ФОНЕ ЗАКАЗЫ В ОТДЕЛЬНЫЙ АРХИВ И ПРИ ПРОКРУТКЕ ОТОБРАЖАТЬ ИХ
            
        let methods = ["page_size": 10, "page": 1]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_orders_history/?cafe_id=\(cafeID)", method: .get, parameters: methods, headers: headers).responseJSON { response in
            debugPrint(response)
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
                if (item1.1.orderStatus == "Заказ отменен" && item2.1.orderStatus != "Заказ отменен") || (item1.1.orderStatus == "Отклонен" && item2.1.orderStatus != "Отклонен") || (item1.1.orderStatus == "Завершен" && item2.1.orderStatus != "Завершен") || (item1.1.orderStatus == "Заказ выполнен" && item2.1.orderStatus != "Заказ выполнен") {
                    return false // item1 должен быть после item2
                } else if (item1.1.orderStatus != "Заказ отменен" && item2.1.orderStatus == "Заказ отменен") || (item1.1.orderStatus != "Отклонен" && item2.1.orderStatus == "Отклонен") || (item1.1.orderStatus != "Завершен" && item2.1.orderStatus == "Завершен") || (item1.1.orderStatus != "Заказ выполнен" && item2.1.orderStatus == "Заказ выполнен") {
                    return true // item1 должен быть перед item2
                } else {
                    let date1 = item1.0.createdDate ?? Date()
                    let date2 = item2.0.createdDate ?? Date()
                    return date1 > date2
                }
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


