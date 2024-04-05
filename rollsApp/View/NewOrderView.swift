//
//  NewOrderView.swift
//  rollsApp
//
//  Created by Владимир Кацап on 05.04.2024.
//

import UIKit

class NewOrderView: UIView {

    override init(frame: CGRect) {
        super .init(frame: frame)
        settingsView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func settingsView() {
        backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    }
}
