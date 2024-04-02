//
//  OrderViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit

class OrderViewController: UIViewController {
    
    var mainView: AllOrdersView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView = AllOrdersView()
        self.view = mainView
        settingsCollection()
        
    }
    
    private func settingsCollection() {
       
        //настройки коллекции
    }
    
    
   


   

}
