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
    func showVC() {
        print(1)
        let vc = DishesMenuViewControllerController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
}
