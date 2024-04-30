//
//  LoginViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 22.04.2024.
//

import UIKit
import Alamofire
import SnapKit

class LoginViewController: UIViewController {
    var loginTextField, passwordTextField: UITextField?
    var isSave: Bool = false
    var checkBoxButton: UIButton?
    var vhodButton: UIButton?
    var texSupportLabel: UILabel?
    var tabBar = TabBarViewController()
    var orderVC: OrderViewController?
    
    //MARK: -viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.object(forKey: "authKey") != nil {
            authKey = UserDefaults.standard.string(forKey: "authKey") ?? ""
            navigationController?.setViewControllers([tabBar], animated: false)
        } else {
            createInterface()
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    func createInterface() {
        view.backgroundColor = UIColor(hex: "#5350E5")
        let gesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(gesture)
        
        let imageView: UIImageView = {
            let image: UIImage = .imageLogin
            let imageView = UIImageView(image: image)
            return imageView
        }()
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(135)
            make.width.equalTo(170)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-170)
        }
        let labelOrder: UILabel = {
            let label = UILabel()
            label.text = "Заказы"
            label.font = .systemFont(ofSize: 34, weight: .semibold)
            label.textColor = .white
            return label
        }()
        view.addSubview(labelOrder)
        labelOrder.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(-15)
        }
        loginTextField = {
            let textField = UITextField()
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
            textField.leftView = view
            textField.rightView = view
            textField.textColor = .black
            textField.leftViewMode = .always
            textField.rightViewMode = .always
            textField.backgroundColor = .white
            textField.borderStyle = .none
            textField.layer.cornerRadius = 10
            textField.placeholder = "Логин"
            textField.delegate = self
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(hex: "#5350E5")]
            let attributedPlaceholder = NSAttributedString(string: "Логин", attributes: attributes)
            textField.attributedPlaceholder = attributedPlaceholder
            return textField
        }()
        
        view.addSubview(loginTextField ?? UITextField())
        loginTextField?.snp.makeConstraints({ make in
            make.height.equalTo(56)
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(labelOrder.snp.bottom).inset(-20)
        })
        
        passwordTextField = {
            let textField = UITextField()
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
            textField.leftView = view
            textField.rightView = view
            textField.leftViewMode = .always
            textField.rightViewMode = .always
            textField.textColor = .black
            textField.backgroundColor = .white
            textField.borderStyle = .none
            textField.layer.cornerRadius = 10
            textField.placeholder = "Пароль"
            textField.isSecureTextEntry = true
            textField.delegate = self
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(hex: "#5350E5")]
            let attributedPlaceholder = NSAttributedString(string: "Пароль", attributes: attributes)
            textField.attributedPlaceholder = attributedPlaceholder
            return textField
        }()
        
        view.addSubview(passwordTextField ?? UITextField())
        passwordTextField?.snp.makeConstraints({ make in
            make.height.equalTo(56)
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo((loginTextField?.snp.bottom)!).inset(-20)
        })
        
        checkBoxButton = {
            let button = UIButton(type: .custom)
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 5
            button.setImage(UIImage(named: "unchecked"), for: .normal) // Устанавливаем изображение пустого квадрата
            button.addTarget(self, action: #selector(checkBoxTapped(_:)), for: .touchUpInside)
            return button
        }()
        
        view.addSubview(checkBoxButton ?? UIButton())
        checkBoxButton?.snp.makeConstraints { make in
            make.width.height.equalTo(24) // Устанавливаем размер чекбокса
            make.top.equalTo((passwordTextField?.snp.bottom)!).inset(-20) // Устанавливаем расположение чекбокса
            make.left.equalToSuperview().offset(20) // Устанавливаем расположение чекбокса
        }
        
        let rememberMeLabel: UILabel = {
            let label = UILabel()
            label.text = "Запомнить меня"
            label.textColor = .white
            label.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(checkBoxTapped(_:)))
            label.addGestureRecognizer(gesture)
            label.font = .systemFont(ofSize: 17, weight: .regular)
            return label
        }()
        view.addSubview(rememberMeLabel)
        rememberMeLabel.snp.makeConstraints { make in
            make.left.equalTo((checkBoxButton?.snp.right)!).inset(-10)
            make.centerY.equalTo((checkBoxButton?.snp.centerY)!)
        }
        
        texSupportLabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 17, weight: .regular)
            let attributedString = NSMutableAttributedString(string: "Техподдержка +7(928)355-03-02")
            attributedString.removeAttribute(.underlineStyle, range: NSRange(location: 0, length: attributedString.length))
            if let range = attributedString.string.range(of: "+7(928)355-03-02") {
                let nsRange = NSRange(range, in: attributedString.string)
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
            }
            label.attributedText = attributedString
            label.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePhoneTap(_:)))
            label.addGestureRecognizer(tapGesture)
            return label
        }()
        
        
        view.addSubview(texSupportLabel ?? UILabel())
        texSupportLabel?.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(50)
            make.centerX.equalToSuperview()
        }
        
        vhodButton = {
            let button = UIButton(type: .system)
            button.setTitle("Войти", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            button.backgroundColor = UIColor(hex: "#43539F")
            button.layer.cornerRadius = 10
            button.addTarget(self, action: #selector(goLogin), for: .touchUpInside)
            return button
        }()
        view.addSubview(vhodButton ?? UIButton())
        vhodButton?.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo((texSupportLabel?.snp.top)!).inset(-15)
            make.height.equalTo(56)
        }
    }
    
    func updateCheckBoxState() {
        if isSave {
            checkBoxButton?.setImage(UIImage(named: "checked"), for: .normal)
        } else {
            checkBoxButton?.setImage(UIImage(named: "unchecked"), for: .normal)
        }
    }
    
    //MARK: -objc func
    
    @objc func keyboardWillShow(notification: Notification) {
        self.view.frame.origin.y = -100
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func endEditing() {
        loginTextField?.endEditing(true)
        passwordTextField?.endEditing(true)
    }
    
    @objc func goLogin() {
        self.vhodButton?.isEnabled = false
        let loginText = loginTextField?.text ?? ""
        let password = passwordTextField?.text ?? ""
        
        login(login: loginText, password: password) { result in
            switch result {
            case .success:
                UIView.animate(withDuration: 0.3) {
                    self.vhodButton?.backgroundColor = .systemGreen
                } completion: { _ in
                    self.vhodButton?.isEnabled = false
                    if self.isSave == true {
                        UserDefaults.standard.setValue(authKey, forKey: "authKey")
                    }
                    self.navigationController?.setViewControllers([self.tabBar], animated: true)
                }
            case .failure(let error):
                UserDefaults.standard.removeObject(forKey: "authKey")
                self.vhodButton?.isEnabled = false
                UIView.transition(with: self.vhodButton!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.vhodButton?.backgroundColor = .red
                }, completion: { _ in
                    UIView.transition(with: self.vhodButton!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.vhodButton?.backgroundColor = UIColor(hex: "#43539F")
                    }, completion: nil)
                })
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.vhodButton?.transform = CGAffineTransform(translationX: -10, y: 0)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1, animations: {
                        self.vhodButton?.transform = CGAffineTransform(translationX: 10, y: 0)
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.1, animations: {
                            self.vhodButton?.transform = .identity
                            self.vhodButton?.isEnabled = true
                        })
                    })
                })
                
            }
        }
    }
    
    
    @objc func handlePhoneTap(_ sender: UITapGestureRecognizer) {
        if let phone = texSupportLabel?.text?.replacingOccurrences(of: "Техподдержка ", with: ""), let phoneURL = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func checkBoxTapped(_ sender: UIButton) {
        isSave = !isSave
        updateCheckBoxState()
        print(1)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
