//
//  AdressViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 15.04.2024.
//

import UIKit

protocol AdressViewControllerDelegate: AnyObject {
    func fillTextField(adress: String)
    func dismiss()
}

class AdressViewController: UIViewController {

    var similadAdressView: SimilarAdressTable?
    var adressTextField: UITextField?
    var adress = ""
    
    //MARK: -viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .settingBG
        createInterface()
        similadAdressView?.secondDelegate = self

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adressTextField?.becomeFirstResponder()
    }

    @objc func closeBut() {
        adressTextField?.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: -create interface func
    
    func createInterface() {
        let closeButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Готово", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
            button.setTitleColor(.systemBlue, for: .normal)
            button.addTarget(self, action: #selector(closeBut), for: .touchUpInside)
            return button
        }()
        
        adressTextField = {
            let textField = UITextField()
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.leftViewMode = .always
            textField.text = adress
            
            let buttonClear = UIButton(type: .system)
            buttonClear.backgroundColor = .settings
            buttonClear.setImage(UIImage(systemName: "xmark"), for: .normal)
            
            buttonClear.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7)
            buttonClear.addTarget(self, action: #selector(clearAdres), for: .touchUpInside)
            textField.rightView = buttonClear
            textField.rightViewMode = .whileEditing
            textField.textColor = .TC
            textField.backgroundColor = .settings
            textField.layer.cornerRadius = 10
            textField.placeholder = "Поиск"
            textField.delegate = self
            return textField
        }()

        
        view.addSubview(adressTextField!)
        adressTextField?.snp.makeConstraints({ make in
            make.left.equalToSuperview().inset(15)
            make.right.equalToSuperview().inset(80)
            make.top.equalToSuperview().inset(10)
            make.height.equalTo(44)
        })
        view.addSubview(similadAdressView!)
        similadAdressView?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.top.equalTo((adressTextField?.snp.bottom)!).inset(-15)
        })
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(44)
            make.left.equalTo((adressTextField?.snp.right)!).inset(-5)
            make.top.equalTo((adressTextField?.snp.top)!)
        }
    }
    
    deinit {
        print("ЗАКРЫЛИ")
    }
    
    @objc func clearAdres() {
        adressTextField?.text = nil
        adress = ""
    }
}

extension AdressViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == adressTextField {
            if let a = adressTextField?.text  {
                similadAdressView?.reload(address: a)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        adressTextField?.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        return true
    }
}

extension AdressViewController: AdressViewControllerDelegate {
    func fillTextField(adress: String) {
        adressTextField?.text = adress
    }
    
    func dismiss() {
        adressTextField?.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
