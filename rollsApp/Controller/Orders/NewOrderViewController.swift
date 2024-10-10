//
//  NewOrderViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 05.04.2024.
//

import UIKit
import Alamofire
import Lottie

protocol NewOrderViewControllerDelegate: AnyObject {
    func removeDelegates()
}

protocol NewOrderViewControllerShowWCDelegate: AnyObject {
    func showVC()
    func reloadDishes()
    func getLastAdress(phoneNumber: String, cafeID: String, completion: @escaping (String) -> Void)
    func createNewOrder(phonee: String, menuItems: String, clientsNumber: String, adress: String, totalCost: Int, paymentMethod: String, timeOrder: String, cafeID: Int, completion: @escaping (Bool) -> Void)
    func succesCreate()
    func showAdressVC()
}

class NewOrderViewController: UIViewController {
    
    var mainView: NewOrderView?
    weak var delegate: OrderViewControllerDelegate?
    
    var vcDishes = DishesMenuViewControllerController()
    var isMediumPage = false //если нажата кнопка нового заказа из меню
    var isModal = false 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        returnClearView()
        if  isMediumPage == false {
            if let splitVC = self.splitViewController  {
                vcDishes = DishesMenuViewControllerController()
                vcDishes.coast = mainView?.similadAdressView
                vcDishes.delegate = self.mainView
                let newNavController = UINavigationController(rootViewController: vcDishes)
                splitVC.showDetailViewController(newNavController, sender: nil)
                
            
            }
        }
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(menuItemsArr)
        mainView = NewOrderView()
        mainView?.delegate = self
        self.view = mainView
        returnClearView()
    }
    
    private func returnClearView() {
        
        menuItemsArr.removeAll()
        menuItemIndex.removeAll()
        adress = ""
        totalCoast = 0
        self.mainView = NewOrderView()
        self.mainView?.delegate = self
        self.view = self.mainView
        
        if let splitVC = self.splitViewController {
            mainView?.hideIphoneComponents = true
            self.isModal = false
        }
        
        mainView?.isModal = isModal
        mainView?.checkIphone()
       
       
        
    }
    
   
    
    deinit {
        if UIDevice.current.userInterfaceIdiom != .pad {
            print("new ok")
            menuItemsArr.removeAll()
            menuItemIndex.removeAll()
            adress = ""
            totalCoast = 0
            delegate?.close()
        }
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
    
    func cleanString(_ string: String) -> String {
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
    func reloadDishes() {
        vcDishes.settingsView()
        vcDishes.collectionView?.reloadData()
    }
    
    func getLastAdress(phoneNumber: String, cafeID: String, completion: @escaping (String) -> Void) {
        var resultAddress = ""

        // Очистка строк от пробелов и скобок
        let cleanPhoneNumber = phoneNumber
        let cleanCafeID = cafeID

        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]

        // Создание URLComponents для корректного кодирования параметров
        var urlComponents = URLComponents(string: "http://arbamarket.ru/api/v1/main/get_last_address/")
        urlComponents?.queryItems = [
            URLQueryItem(name: "phone_number", value: cleanPhoneNumber),
            URLQueryItem(name: "cafe_id", value: cleanCafeID)
        ]

        // Получение закодированного URL
        guard let encodedURL = urlComponents?.url else {
            print("Ошибка: не удалось создать закодированный URL.")
            completion(resultAddress)
            return
        }

        // Выполнение запроса с использованием Alamofire
        AF.request(encodedURL, method: .get, headers: headers).responseJSON { response in
            debugPrint(response)
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let address = json["address"] as? [String: Any],
                   let addressValue = address["address"] as? String {
                    resultAddress = addressValue
                }
            case .failure(_):
                resultAddress = ""
            }
            completion(resultAddress)
        }
    }
    
  
    
    
    
    func showAdressVC() {
        let vc = AdressViewController()
        vc.similadAdressView = mainView?.similadAdressView
        //vc.adress = self.mainView?.adressTextField?.text ?? ""
        present(vc, animated: true)
    }
    
    func succesCreate() {
        if let splitVC = self.splitViewController {
            let newNavController = lottieVC
            splitVC.showDetailViewController(newNavController, sender: nil)
            lottieVC.changeInterface(named: "Done")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                menuItemsArr.removeAll()
                menuItemIndex.removeAll()
                adress = ""
                totalCoast = 0
                self.mainView = NewOrderView()
                self.mainView?.delegate = self
                self.view = self.mainView
                self.returnClearView()
            }
          
        } else {
            
            UIView.animate(withDuration: 0.4) {
                self.mainView?.animationView.alpha = 1
                self.mainView?.animationViewLottie.play()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
                UIView.animate(withDuration: 0.3) {
                    self.mainView?.animationView.alpha = 0
                    self.mainView?.animationViewLottie.stop()
                }
                
                menuItemsArr.removeAll()
                menuItemIndex.removeAll()
                adress = ""
                totalCoast = 0
                self.mainView = NewOrderView()
                self.mainView?.delegate = self
                self.view = self.mainView
                self.returnClearView()
                self.dismiss(animated: true)
            }
        } 
       
    }
    

 

   
    func showVC() {

        if UIDevice.current.userInterfaceIdiom == .pad {
            let vc = DishesMenuViewControllerController()
            vc.coast = mainView?.similadAdressView
            vc.delegate = self.mainView
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let vc = DishesMenuViewControllerController()
            vc.coast = mainView?.similadAdressView
            vc.delegate = self.mainView
            self.present(vc, animated: true)
        }
        
    }
    
    func createNewOrder(phonee: String, menuItems: String, clientsNumber: String, adress: String, totalCost: Int, paymentMethod: String, timeOrder: String, cafeID: Int, completion: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            HTTPHeader.accept("application/json"),
            HTTPHeader.contentType("application/json"),
            HTTPHeader.authorization(bearerToken: authKey)
        ]
        
        let parameters: [String : Any] = [
            "phone": phonee,
            "menu_items": menuItems,
            "clients_number": String(clientsNumber),
            "address": adress,
            "total_cost": totalCost,
            "payment_method": paymentMethod,
            //"order_on_time": timeOrder,  // к определенному времени
            "cafe_id": cafeID
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/create_order/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
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
