//
//  TabBarViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 23.04.2024.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    let orderVC = OrderViewController()
    let statVC = StatViewController()
    let settingsVC = SettingsViewController()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let orderVC = viewController as? OrderViewController {
            orderVC.isOpen = false
        } else {
            orderVC.isLoad = true
            orderVC.isOpen = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        orderVC.title = "Заказы"
        orderVC.tabBarItem.image = UIImage.orders.resize(targetSize: CGSize(width: 30, height: 30))
        let statNavController = UINavigationController(rootViewController: statVC)
        statNavController.title = "Статистика"
        statNavController.tabBarItem.image = UIImage.stat.resize(targetSize: CGSize(width: 30, height: 30))
        settingsVC.title = "Настройки"
        settingsVC.tabBarItem.image = UIImage.settings.resize(targetSize: CGSize(width: 30, height: 30))
        let controllers = [statNavController, orderVC, settingsVC]
        self.viewControllers = controllers
        tabBar.backgroundColor = .tabBar
        tabBar.unselectedItemTintColor = .iconsUnselected
        tabBar.tintColor = .systemBlue
        view.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(tabBar.snp.top)
            make.left.right.equalToSuperview()
        }
        selectedIndex = 1
        
       
        
    }
}


extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
