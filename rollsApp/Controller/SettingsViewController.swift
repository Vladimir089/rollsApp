//
//  SettingsViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 24.04.2024.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let alertContoller = UIAlertController(title: "Внимание", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F2F2F7")
        settingsAlert()
        settingsView()
    }
    
    
    let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выйти", for: .normal)
        button.tintColor = .systemRed
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(closeApp), for: .touchUpInside)
        return button
    }()

    func settingsView() {
        let orderLabel: UILabel = {
            let label = UILabel()
            label.text = "Настройки"
            label.font = .systemFont(ofSize: 41, weight: .bold)
            label.textColor = .black
            return label
        }()
        view.addSubview(orderLabel)
        orderLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(75)
        }
        
        let nameView = UIView()
        nameView.layer.cornerRadius = 14
        nameView.backgroundColor = .white
        view.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(70)
            make.top.equalTo(orderLabel.snp.bottom).inset(-20)
        }
        let cafeImageView: UIImageView = {
            let image:UIImage = .image
            let imageView = UIImageView(image: image)
            return imageView
        }()
        nameView.addSubview(cafeImageView)
        cafeImageView.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        let cafeNameLabel: UILabel = {
            let label = UILabel()
            label.text = "Байрам"
            label.font = .systemFont(ofSize: 23, weight: .bold)
            label.textColor = .black
            return label
        }()
        nameView.addSubview(cafeNameLabel)
        cafeNameLabel.snp.makeConstraints { make in
            make.left.equalTo(cafeImageView.snp.right).inset(-15)
            make.bottom.equalTo(cafeImageView.snp.centerY).offset(3)
        }
        
        let cafeAdressLabel: UILabel = {
            let label = UILabel()
            label.text = "Ленина, 49, Учкекен"
            label.font = .systemFont(ofSize: 15, weight: .regular)
            label.textColor = .black
            return label
        }()
        nameView.addSubview(cafeAdressLabel)
        cafeAdressLabel.snp.makeConstraints { make in
            make.left.equalTo(cafeImageView.snp.right).inset(-15)
            make.top.equalTo(cafeImageView.snp.centerY)
        }
        
        view.addSubview(exitButton)
        exitButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(nameView.snp.bottom).inset(-30)
        }
    }
    
    func settingsAlert() {
        let yesAction = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            UserDefaults.standard.removeObject(forKey: "authKey")
            authKey = ""
            self.navigationController?.setViewControllers([LoginViewController()], animated: false)
        }
        alertContoller.addAction(yesAction)
        
        // Добавляем действие для кнопки "Отмена"
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertContoller.addAction(cancelAction)
    }

    @objc func closeApp() {
        present(alertContoller, animated: true, completion: nil)
    }
}
