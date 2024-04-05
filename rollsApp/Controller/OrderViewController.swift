//
//  OrderViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit

protocol OrderViewControllerDelegate: AnyObject {
    func reloadCollection()
}

class OrderViewController: UIViewController {
    
    var mainView: AllOrdersView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView = AllOrdersView()
        self.view = mainView
        mainView?.addNewOrderButton?.addTarget(self, action: #selector(newOrder), for: .touchUpInside)
    }
    
    @objc private func newOrder() {
        let vc = NewOrderViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension OrderViewController: OrderViewControllerDelegate {
    func reloadCollection() {
        mainView?.collectionView?.reloadData()
        print(12)
    }
    
    
}
