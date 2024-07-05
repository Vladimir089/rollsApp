//
//  OrderViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit
import Alamofire
import AlamofireImage
import Kingfisher



var isFirstLoadApp = 0
var dishLoad = false 



var indexPathsToInsert: [IndexPath] = []
var indexPathsToUpdate: [IndexPath] = []

protocol OrderViewControllerDelegate: AnyObject {

    func createButtonGo(index: Int, completion: @escaping () -> Void)
    func detailVC(index: Int)
    func close()
    func issued(index: Int, completion: @escaping () -> Void)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isOpen = false
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
            reload()
            getDishes() {
                NotificationCenter.default.post(name: Notification.Name("dishLoadNotification"), object: nil)
                dishLoad = true
            }
           
        }
    }
    
    func reload() {
        self.mainView?.collectionView?.reloadData()
        regenerateTable() {
            DispatchQueue.main.async {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.reload()
                }
            }
           
        }
    }
    
    func getDishes(completion: @escaping () -> Void) {
        allDishes.removeAll()
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("application/json")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_dishes/?cafe_id=\(cafeID)", method: .get, headers: headers).responseData { response in
            switch response.result {
            case .success(_):
                if let data = response.data, let dishes = try? JSONDecoder().decode(DishesResponse.self, from: data) {
                    let dispatchGroup = DispatchGroup()
                    
                    for i in dishes.dishes {
                        dispatchGroup.enter()
                        self.getImage(d: i) {
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion()
                    }
                }
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }

    func getImage(d: Dish, completion: @escaping () -> Void) {
        if let url = d.img {
            KingfisherManager.shared.retrieveImage(with: URL(string: "http://arbamarket.ru\(url)")!) { response in
                switch response {
                case .success(let image):
                    allDishes.append((d, image.image))
                case .failure(let error):
                    allDishes.append((d, imageSatandart ?? UIImage()))
                }
                completion()
            }
            
        } else {
            completion()
        }
    }
    
    deinit {
        stopAuthCheckTimer()
    }
}

extension OrderViewController: OrderViewControllerDelegate {
    func close() {
        isOpen = false
    }
    
    
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
        backItem.title = "Заказ №\(orderStatus[index].id)"
        backItem.setTitleTextAttributes(attributes, for: .normal)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        self.refreshControl.endRefreshing()
        navigationController?.pushViewController(vc, animated: true)
    }
    
  
    
    func createButtonGo(index: Int, completion: @escaping () -> Void) {
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        if orderStatus.count < index {
            return
        }
        let currentOrder = orderStatus[index]
        print(currentOrder.id, 324)
        
        let messageText = "Вызвать курьера на адрес \(currentOrder.address) ?"
        let attributedString = NSMutableAttributedString(string: messageText)

        // Настройка атрибутов для жирного текста
        let boldAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        let range = (messageText as NSString).range(of: currentOrder.address)

        // Применение атрибутов к части строки
        attributedString.addAttributes(boldAttribute, range: range)
        
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        alertController.setValue(attributedString, forKey: "attributedMessage")


        // Создаем первое действие
        let action1 = UIAlertAction(title: "Отмена", style: .destructive) { (action) in
            return
        }

        // Создаем второе действие
        let action2 = UIAlertAction(title: "Вызвать", style: .default) { (action) in
            AF.request("http://arbamarket.ru/api/v1/delivery/create_order/?order_id=\(currentOrder.id)&cafe_id=\(currentOrder.cafeID)", method: .post, headers: headers).responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response)
                case .failure(_):
                    print(1)
                }
            }
            completion() 
        }

        // Добавляем действия к UIAlertController
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    func issued(index: Int, completion: @escaping () -> Void) {
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        if orderStatus.count < index {
            return
        }
        let currentOrder = orderStatus[index]
       

        AF.request("http://arbamarket.ru/api/v1/main/change_issued_filed/?cafe_id=\(currentOrder.cafeID)&order_id=\(currentOrder.id)", method: .post, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                print(response)
            case .failure(_):
                print(1)
            }
        }
        completion()

      
        
        
        
        
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
