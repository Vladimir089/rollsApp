//
//  NewOrderViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 05.04.2024.
//

import UIKit
import Alamofire
protocol NewOrderViewControllerDelegate: AnyObject {
//    func updateCollection()
    func removeDelegates()
}

protocol NewOrderViewControllerShowWCDelegate: AnyObject {
    func showVC()
    func getLastAdress(phoneNumber: String, cafeID: String, completion: @escaping (String) -> Void)
    func createNewOrder(phonee: String, menuItems: String, clientsNumber: Int, adress: String, totalCost: Int, paymentMethod: String, timeOrder: String, cafeID: Int, completion: @escaping (Bool) -> Void)
    func succesCreate()
}

class NewOrderViewController: UIViewController {
    
    var mainView: NewOrderView?
    var delegate: OrderViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(menuItemsArr)
        mainView = NewOrderView()
        mainView?.delegate = self
        self.view = mainView
        
    }
    
    
    deinit {
        menuItemsArr.removeAll()
        adress = ""
        totalCoast = 0
        print("dsdfsdfsdfsdfee232323")
        delegate?.closeVC()
    }

    
    
    override func viewDidLayoutSubviews() {
        mainView?.tableView?.reloadData()
        mainView?.layoutIfNeeded()
        mainView?.tableView?.snp.updateConstraints({ make in
            make.height.equalTo((menuItemsArr.count + 1) * 44)
        })
        mainView?.scrollView.layoutIfNeeded()
        mainView?.tableView?.layoutIfNeeded()
        mainView?.updateContentSize()
    }
    
   
    
   
    

   
}


extension NewOrderViewController: NewOrderViewControllerDelegate {
    func removeDelegates() {
        delegate = nil
    }
}

extension NewOrderViewController: NewOrderViewControllerShowWCDelegate {
    func succesCreate() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func getLastAdress(phoneNumber: String, cafeID: String, completion: @escaping (String) -> Void) {
        var a = ""
        
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_last_address/?phone_number=\(phoneNumber)&cafe_id=\(cafeID)", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let address = json["address"] as? [String: Any],
                   let addressValue = address["address"] as? String {
                    a = addressValue
                }
            case .failure(_):
                a = ""
            }
            completion(a)
        }
    }

    
    func showVC() {
        print(1)
        let vc = DishesMenuViewControllerController()
        vc.coast = mainView?.similadAdressView
        vc.delegate = self.mainView
        self.present(vc, animated: true)
    }
    
    
    func createNewOrder(phonee: String, menuItems: String, clientsNumber: Int, adress: String, totalCost: Int, paymentMethod: String, timeOrder: String, cafeID: Int, completion: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            HTTPHeader.accept("application/json"),
            HTTPHeader.contentType("application/json"),
            HTTPHeader.authorization(bearerToken: authKey)
        ]
        
        let parameters: [String : Any] = [
            "phone": phonee,
            "menu_items": menuItems,
            "clients_number": clientsNumber,
            "address": adress,
            "total_cost": totalCost,
            "payment_method": paymentMethod,
            //"order_on_time": timeOrder,  // к определенному времени
            "cafe_id": cafeID
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/create_order/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }

    
    
    
}