//
//  OrderViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit
import Alamofire
import AlamofireImage



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
    var authCheckTimer: Timer?
    var isLoad = false
    let queue = DispatchQueue(label: "Timer")
    var isOpen = false
    var isWorkCicle = false
    var refreshControl = UIRefreshControl()
    
  //MARK: -viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView = AllOrdersView()
        self.view = mainView
        mainView?.addNewOrderButton?.addTarget(self, action: #selector(newOrder), for: .touchUpInside)
        mainView?.delegate = self
        setupRefreshControl()
        startAuthCheckTimer()
    }
    
    func setupRefreshControl() {
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
            if ((isLoad == true && isOpen == true) || (isLoad == false && isOpen == true) || (isLoad == true && isOpen == false))  {
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
    
    func stopAuthCheckTimer() {
        authCheckTimer?.invalidate()
        authCheckTimer = nil
    }
    
    func startAuthCheckTimer() {
        authCheckTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkAuthKey), userInfo: nil, repeats: true)
    }
    
    @objc func checkAuthKey() {
        // Проверяем, есть ли значение у authKey
        if !authKey.isEmpty {
            stopAuthCheckTimer()
            reloadCollection()
            getDishes()
           
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
            print(url, "sdfsdfsd")
            AF.request("http://arbamarket.ru\(url)").responseImage { response in
                switch response.result {
                case .success(let image):
                    allDishes.append((d, image))
                case .failure(_):
                    allDishes.append((d, imageSatandart ?? UIImage()))
                }
                
            }
        }
    }
    
    deinit {
        stopAuthCheckTimer()
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
            .font: UIFont.boldSystemFont(ofSize: 17),
            .foregroundColor: UIColor.black ]
        backItem.title = "Заказ №\(orderStatus[index].0.id)"
        backItem.setTitleTextAttributes(attributes, for: .normal)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        self.refreshControl.endRefreshing()
        navigationController?.pushViewController(vc, animated: true)
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
            debugPrint(response)
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

//extension OrderViewController: UIApplicationDelegate {
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        isOpen = true
//        isLoad = true
//        print(123)
//    }
//    
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        closeVC()
//    }
//}
