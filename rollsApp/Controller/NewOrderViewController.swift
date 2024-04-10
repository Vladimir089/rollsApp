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
        print(menuItemsArr)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.reloadCollection()
    }
    
    
    
   
    

   
}


extension NewOrderViewController: NewOrderViewControllerDelegate {
    func removeDelegates() {
        delegate = nil
    }
}

extension NewOrderViewController: NewOrderViewControllerShowWCDelegate {
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
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    
    
}
