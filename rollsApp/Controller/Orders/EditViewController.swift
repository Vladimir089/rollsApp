//
//  EditViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 16.04.2024.
//

import UIKit
import Alamofire

protocol EditViewControllerDelegate: AnyObject {
    func showVC()
    func getLastAdress(phoneNumber: String, cafeID: String, completion: @escaping (String) -> Void)
    func updateOrder(phonee: String, menuItems: String, clientsNumber: Int, adress: String, totalCost: Int, paymentMethod: String, timeOrder: String, cafeID: Int, orderId: Int, completion: @escaping (Bool) -> Void)
    func succesCreate()
    func showAdressVC()
    func cell()
}

class EditViewController: UIViewController {
    
    var delegate: OrderViewControllerDelegate?
    var indexOne = 0
    
    var mainView: EditView?
    
    override func loadView() {
        mainView = EditView()
        self.view = mainView
        mainView?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView?.index = indexOne
        navigationController?.navigationBar.barTintColor = .white
        let image: UIImage = imageSatandart ?? UIImage()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30)) // Установите нужные размеры
        customView.addSubview(imageView)
        imageView.frame = customView.bounds
        let barButtonItem = UIBarButtonItem(customView: customView)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        

    }

    deinit {
        menuItemsArr.removeAll()
        menuItemIndex.removeAll()
        adress = ""
        totalCoast = 0
        delegate?.closeVC()
    }
}

extension EditViewController: EditViewControllerDelegate {
    func cell() {
        let phoneNumber: String = mainView?.phoneTextField?.text ?? ""

        if let url = URL(string: "tel://+7\(phoneNumber)") {
            print(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Не удалось сформировать url")
        }
    }
    
    func showAdressVC() {
        let vc = AdressViewController()
        vc.similadAdressView = mainView?.similadAdressView
        vc.adress = self.mainView?.adressTextField?.text ?? ""
        present(vc, animated: true)
    }
    
    func succesCreate() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    func getLastAdress(phoneNumber: String, cafeID: String, completion: @escaping (String) -> Void) {
        var lastAdress = ""
        
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
                    lastAdress = addressValue
                }
            case .failure(_):
                lastAdress = ""
            }
            completion(lastAdress)
        }
    }

    
    func showVC() {
        let vc = DishesMenuViewControllerController()
        vc.coast = mainView?.similadAdressView
        vc.delegateEdit = self.mainView
        self.present(vc, animated: true)
    }
    
    
    func updateOrder(phonee: String, menuItems: String, clientsNumber: Int, adress: String, totalCost: Int, paymentMethod: String, timeOrder: String, cafeID: Int, orderId: Int, completion: @escaping (Bool) -> Void) {
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
        AF.request("http://arbamarket.ru/api/v1/main/edit_order/\(orderId)/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            debugPrint(response)
            switch response.result {
            case .success(_):
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }

    
    
    
}
