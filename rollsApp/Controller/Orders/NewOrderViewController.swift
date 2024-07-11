//
//  NewOrderViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 05.04.2024.
//

import UIKit
import Alamofire
import InputMask

protocol NewOrderViewControllerDelegate: AnyObject {
    func removeDelegates()
}

protocol NewOrderViewControllerShowWCDelegate: AnyObject {
    func showVC()
    func getLastAdress(phoneNumber: String, cafeID: String, completion: @escaping (String) -> Void)
    func createNewOrder(phonee: String, menuItems: String, clientsNumber: Int, adress: String, totalCost: Int, paymentMethod: String, timeOrder: String, cafeID: Int, completion: @escaping (Bool) -> Void)
    func succesCreate()
    func showAdressVC()
}

class NewOrderViewController: UIViewController {
    
    var mainView: NewOrderView?
    weak var delegate: OrderViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(menuItemsArr)
        mainView = NewOrderView()
        mainView?.delegate = self
        self.view = mainView
        
    }
    
    
    
    deinit {
        menuItemsArr.removeAll()
        menuItemIndex.removeAll()
        adress = ""
        totalCoast = 0
        delegate?.close()
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
    
    func cleaвnString(_ string: String) -> String {
        // Удаление пробелов
        let noSpaces = string.replacingOccurrences(of: " ", with: "")
        // Удаление скобок
        let cleanString = noSpaces.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        return cleanString
    }
}


extension NewOrderViewController: NewOrderViewControllerDelegate {
    func removeDelegates() {
        delegate = nil
    }
}

extension NewOrderViewController: NewOrderViewControllerShowWCDelegate {
    
    
    func showAdressVC() {
        let vc = AdressViewController()
        vc.similadAdressView = mainView?.similadAdressView
        vc.adress = self.mainView?.adressTextField?.text ?? ""
        present(vc, animated: true)
    }
    
    func succesCreate() {
        dismiss(animated: true, completion: nil)
    }
    

    func getLastAdress(phoneNumber: String, cafeID: String, completion: @escaping (String) -> Void) {
        var a = ""

        // Очистка строк от пробелов и скобок
        let cleanPhoneNumber = phoneNumber
        let cleanCafeID = cafeID

        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_last_address/?phone_number=\(cleanPhoneNumber)&cafe_id=\(cleanCafeID)", method: .get, headers: headers).responseJSON { response in
            debugPrint(response)
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

        if UIDevice.current.userInterfaceIdiom == .pad {
//            let vc = DishesMenuViewControllerController()
//            vc.coast = mainView?.similadAdressView
//            vc.delegate = self.mainView
//            self.navigationController?.pushViewController(vc, animated: true)
            //ПОКА ДЕЛАЕМ РЕДАКТИРОВАНИЕ ПО ЭТОМУ ТАК
            
            let vc = DishesMenuViewControllerController()
            vc.coast = mainView?.similadAdressView
            vc.delegate = self.mainView
            self.present(vc, animated: true)
            
        } else {
            let vc = DishesMenuViewControllerController()
            vc.coast = mainView?.similadAdressView
            vc.delegate = self.mainView
            self.present(vc, animated: true)
        }
        
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
        
        AF.request("http://arbamarket.ru/api/v1/main/create_order/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            print(response)
            switch response.result {
            case .success(_):
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    } 
}
