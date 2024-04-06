//
//  NewOrderViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 05.04.2024.
//

import UIKit

class NewOrderViewController: UIViewController {
    
    var mainView: NewOrderView?
    var delegate: OrderViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView = NewOrderView()
        self.view = mainView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.reloadCollection()
    }
   
    

   
}
