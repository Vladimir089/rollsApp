//
//  TabBarViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 23.04.2024.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    let orderVC = OrderViewController()
    let statVC = StatViewController()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#AFAFAF")
        return view
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        orderVC.title = "Заказы"
        orderVC.tabBarItem.image = UIImage.orders.resize(targetSize: CGSize(width: 30, height: 30))
        
        statVC.title = "Статистика"
        statVC.tabBarItem.image = UIImage.stat.resize(targetSize: CGSize(width: 30, height: 30))
        
        let controllers = [statVC, orderVC]
        
        
        self.viewControllers = controllers
        tabBar.backgroundColor = UIColor(hex: "#F2F2F7")
        tabBar.unselectedItemTintColor = UIColor(hex: "#AFAFAF")
        tabBar.tintColor = UIColor(hex: "#5350E5")
        view.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1.5)
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

        // Определяем новый размер изображения в соответствии с коэффициентом масштабирования
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // Создаем контекст с новыми размерами изображения
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
