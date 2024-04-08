//
//  OrderViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit
import Alamofire

protocol OrderViewControllerDelegate: AnyObject {
    func reloadCollection()
}

class OrderViewController: UIViewController {
    
    var mainView: AllOrdersView?
    var timer: Timer?

    
    override func loadView() {
        login(login: "Bairam", password: "1122")
        //startTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView = AllOrdersView()
        self.view = mainView
        mainView?.addNewOrderButton?.addTarget(self, action: #selector(newOrder), for: .touchUpInside)
        
    }
    @objc func timerAction() {
        getAllOrders(isTimer: true)
        print("Timer fired!")
    }
    
    func startTimer() {
        let timeInterval: TimeInterval = 60.0
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
        let cafeId = 1 //тест
        let headers: HTTPHeaders = [
                HTTPHeader.authorization(bearerToken: authKey),
                HTTPHeader.accept("application/json")
            ]
        AF.request("http://arbamarket.ru/api/v1/main/get_orders_history/?cafe_id=\(cafeId)", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                if let data = response.data, let order = try? JSONDecoder().decode(OrdersResponse.self, from: data) {
                    if isTimer == true {
                        orderStatus.removeAll()
                    }
                    self.getOrderDetail(orders: order.orders)
                    
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getOrderDetail(orders: [Order]) {
        // Сортировка массива заказов по дате создания
        
       
        let dispatchGroup = DispatchGroup()
        
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]

        for order in orders {
            dispatchGroup.enter()
            let currentOrder = order
            print(currentOrder.createdDate)
            AF.request("http://arbamarket.ru/api/v1/delivery/update_status_order/?order_id=\(currentOrder.id)&cafe_id=\(order.cafeID)", method: .post, headers: headers).responseJSON { response in
                switch response.result {
                case .success(_):
                    if let data = response.data, let status = try? JSONDecoder().decode(OrderStatusResponse.self, from: data) {
                        orderStatus.append((currentOrder, status.orderStatus))

                    }
                case .failure(_):
                    orderStatus.append((currentOrder, "Заказ отменен"))

                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            orderStatus.sort { (item1, item2) -> Bool in
                let date1 = item1.0.createdDate ?? Date()
                let date2 = item2.0.createdDate ?? Date()
                return date1 > date2
            }
            self.reloadCollection()
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
        
        AF.request("http://arbamarket.ru/api/v1/accounts/login/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    if let data = response.data, let login = try? JSONDecoder().decode(Login.self, from: data) {
                        authKey = login.authToken
                        self.getAllOrders(isTimer: false)
                    }
                   
                case .failure(let error):
                    print("Произошла ошибка: \(error)")
                    // Обработка ошибки здесь
                }
            }
    }
    
    
}

extension OrderViewController: OrderViewControllerDelegate {
    func reloadCollection() {
        mainView?.collectionView?.reloadData()
        
    }
    
    
}
