//
//  NewOrderView.swift
//  rollsApp
//
//  Created by Владимир Кацап on 05.04.2024.
//

import UIKit
import SnapKit

protocol NewOrderViewProtocol: AnyObject {
    func fillTextField(adress: String, cost: String)
    func fillButton(coast: String)
}

class NewOrderView: UIView {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    var phoneTextField: UITextField?
    var tableView: UITableView?
    var addButton: UIButton?
    weak var delegate: NewOrderViewControllerShowWCDelegate?
    var adressButton: UIButton?
    var adressTextField: UITextField?
    let similadAdressView = SimilarAdressTable()
    var similarLabel: UILabel?
    var commentTextField: UITextField?
    var oplataSegmentedControl: UISegmentedControl?
    var createOrderButton: UIButton?
    let itemsForSegmented = ["Перевод", "Наличка", "На кассе"]
    
    var fallView: UIView?
    
    
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        settingsView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateContentSize()
        updateCreateOrderButtonState()
    }
    
    func updateContentSize() {
        let contentHeight = contentView.subviews.reduce(0) { max($0, $1.frame.maxY) }
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    private func updateCreateOrderButtonState() {
        if phoneTextField?.text != "" && adressTextField?.text != "" && menuItemsArr.count != 0 {
            createOrderButton?.isEnabled = true
            print(1)
        } else {
            createOrderButton?.isEnabled = false
            print(2)
        }
    }

    
    @objc func hideKeyboard() {
        phoneTextField?.endEditing(true)
        updateCreateOrderButtonState()
    }
    
    func settingsView() {
        backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        let tapInViewGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(tapInViewGesture)
        addGestureRecognizer(tapInViewGesture)
        scrollView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        let hideView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(red: 98/255, green: 119/255, blue: 128/255, alpha: 1)
            view.layer.cornerRadius = 1
            return view
        }()
        
        addSubview(hideView)
        hideView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.width.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
        }
        
        let newOrderLabel: UILabel = {
            let label = UILabel()
            label.text = "Новый Заказ"
            label.font = .systemFont(ofSize: 41, weight: .bold)
            label.textColor = .black
            return label
        }()
        
        addSubview(newOrderLabel)
        newOrderLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(50)
        }
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(newOrderLabel.snp.bottom).inset(-10)
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            
        }
        
        let numberPhoneLabel = generateLabel(text: "НОМЕР ТЕЛЕФОНА",
                                             font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                             isUnderlining: false,
                                             textColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1))
        
        contentView.addSubview(numberPhoneLabel)
        numberPhoneLabel.snp.makeConstraints { make in
            make.left.equalTo(newOrderLabel.snp.left).inset(10)
            make.top.equalToSuperview()
        }
        
        let guestLabel = generateLabel(text: "Гость",
                                       font: UIFont.systemFont(ofSize: 15, weight: .bold),
                                       isUnderlining: true,
                                       textColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1))
        contentView.addSubview(guestLabel)
        guestLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(25)
            make.top.equalTo(numberPhoneLabel.snp.top)
        }
        
        phoneTextField = {
            let textField = UITextField()
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.leftViewMode = .always
            textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.rightViewMode = .always
            textField.keyboardType = .numberPad
            textField.textColor = .black
            textField.backgroundColor = .white
            textField.layer.cornerRadius = 10
            textField.delegate = self
            return textField
        }()
        scrollView.addSubview(phoneTextField!)
        phoneTextField?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(numberPhoneLabel.snp.bottom).inset(-10)
            make.height.equalTo(44)
        })
        
        let orderLabel = generateLabel(text: "ЗАКАЗ",
                                       font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                       isUnderlining: false,
                                       textColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1))
        contentView.addSubview(orderLabel)
        orderLabel.snp.makeConstraints { make in
            make.left.equalTo(newOrderLabel.snp.left).inset(10)
            make.top.equalTo(phoneTextField!.snp.bottom).inset(-20)
        }
        
        tableView = {
            let view = UITableView()
            view.delegate = self
            view.dataSource = self
            view.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            view.backgroundColor = .white
            view.layer.cornerRadius = 10
            view.isScrollEnabled = false
            view.rowHeight = UITableView.automaticDimension // Установка автоматической высоты ячеек
            view.estimatedRowHeight = 44
            view.separatorStyle = .none
            return view
        }()
        scrollView.addSubview(tableView!)
        tableView?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(orderLabel.snp.bottom).inset(-10)
            make.height.equalTo((menuItemsArr.count + 1) * 44)
        })
        
        let adressLabel = generateLabel(text: "АДРЕС",
                                       font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                       isUnderlining: false,
                                       textColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1))
        scrollView.addSubview(adressLabel)
        adressLabel.snp.makeConstraints { make in
            make.left.equalTo(newOrderLabel.snp.left).inset(10)
            make.top.equalTo(tableView!.snp.bottom).inset(-20)
        }
        
        adressButton = {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            button.tintColor = UIColor(red: 85/255, green: 112/255, blue: 241/255, alpha: 1)
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(fillAdress), for: .touchUpInside)
            return button
        }()
        scrollView.addSubview(adressButton!)
        adressButton?.snp.makeConstraints({ make in
            make.right.left.equalToSuperview().inset(25)
            make.top.equalTo(adressLabel.snp.bottom)
            make.height.equalTo(0)
        })
        
        adressTextField = {
            let textField = UITextField()
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.leftViewMode = .always
            
            similarLabel = UILabel()
            similarLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            similarLabel?.text = "0 ₽  "
            similarLabel?.textColor = .black

            textField.rightView = similarLabel!
            textField.rightViewMode = .always
            textField.textColor = .black
            textField.backgroundColor = .white
            textField.layer.cornerRadius = 10
            textField.delegate = self
            return textField
        }()

        scrollView.addSubview(adressTextField!)
        adressTextField?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(adressButton!.snp.bottom).inset(-10)
            make.height.equalTo(44)
        })
        
        scrollView.addSubview(similadAdressView)
        similadAdressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo((adressTextField?.snp.bottom)!).inset(-5)
            make.height.equalTo(0)
        }
        similadAdressView.delelagate = self
        
        let sSoboiLabel = generateLabel(text: "С собой",
                                       font: UIFont.systemFont(ofSize: 15, weight: .bold),
                                       isUnderlining: true,
                                       textColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1))
        
        let stoleLabel = generateLabel(text: "Стол",
                                       font: UIFont.systemFont(ofSize: 15, weight: .bold),
                                       isUnderlining: true,
                                       textColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1))
        
        contentView.addSubview(stoleLabel)
        stoleLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(25)
            make.centerY.equalTo(adressLabel.snp.centerY)
        }
        contentView.addSubview(sSoboiLabel)
        sSoboiLabel.snp.makeConstraints { make in
            make.right.equalTo(stoleLabel.snp.left).inset(-10)
            make.centerY.equalTo(adressLabel.snp.centerY)
        }
        
        let commentLabel = generateLabel(text: "КОММЕНТАРИЙ",
                                       font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                       isUnderlining: false,
                                       textColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1))
        contentView.addSubview(commentLabel)
        commentLabel.snp.makeConstraints { make in
            make.left.equalTo(newOrderLabel.snp.left).inset(10)
            make.top.equalTo(similadAdressView.snp.bottom).inset(-20)
        }
        
        commentTextField = {
            let textField = UITextField()
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.leftViewMode = .always
            textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.rightViewMode = .always
            textField.textColor = .black
            textField.backgroundColor = .white
            textField.layer.cornerRadius = 10
            textField.delegate = self
            return textField
        }()
        scrollView.addSubview(commentTextField!)
        commentTextField?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(commentLabel.snp.bottom).inset(-10)
            make.height.equalTo(44)
        })
        
        oplataSegmentedControl = {
            
            let segmentedControl = UISegmentedControl(items: itemsForSegmented)
            segmentedControl.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 230/255, alpha: 1)
            segmentedControl.selectedSegmentTintColor = .white
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            segmentedControl.selectedSegmentIndex = 0
            return segmentedControl
        }()
        scrollView.addSubview(oplataSegmentedControl!)
        oplataSegmentedControl?.snp.makeConstraints({ make in
            make.height.equalTo(44)
            make.top.equalTo((commentTextField?.snp.bottom)!).inset(-15)
            make.left.right.equalTo(commentTextField!)
        })
        
        createOrderButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            button.setTitle("Создать 0 ₽", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            button.tintColor = .white
            button.addTarget(self, action: #selector(createOrder), for: .touchUpInside)
            button.layer.cornerRadius = 12
            return button
        }()

        scrollView.addSubview(createOrderButton!)
        createOrderButton?.snp.makeConstraints({ make in
            make.height.equalTo(50)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo((oplataSegmentedControl?.snp.bottom)!).inset(-15)
        })
        
        let botView: UIView = {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }()
        contentView.addSubview(botView)
        botView.snp.makeConstraints { make in
            make.height.equalTo(100) //мб тут сдеклать высоту таблицы
            make.left.right.equalToSuperview()
            make.top.equalTo((createOrderButton?.snp.bottom)!).inset(-15)
        }
        
        fallView = {
            let view = UIView()
            view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            view.alpha = 0
            view.layer.cornerRadius = 20
            return view
        }()
        addSubview(fallView!)
        fallView!.snp.makeConstraints { make in
            make.height.width.equalTo(200)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let image: UIImage = .fall
        let imageView = UIImageView(image: image)
        fallView!.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.width.equalTo(120)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }
        
        let label = UILabel()
        label.text = "Ошибка в создании"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        fallView?.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(imageView.snp.bottom).inset(-10)
        }
        
    }
    
    
    @objc func createOrder() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let currentDate = Date()
       print(12)
        
        let phone = phoneTextField?.text ?? ""
        var menuItems = ""
        let clientNumber = 1
        let adress = adress
        let coast = totalCoast
        let payMethod = itemsForSegmented[oplataSegmentedControl!.selectedSegmentIndex]
        let timeOrder = dateFormatter.string(from: currentDate)
        let idCafe = cafeID
        print(timeOrder)

        
        for (index, (key, value)) in menuItemsArr.enumerated() {
            let count = value.0
            menuItems.append("\(key) - \(count)")

            if index != menuItemsArr.count - 1 {
                menuItems.append(", ")
            }
        }
        
        delegate?.createNewOrder(phonee: phone, menuItems: menuItems, clientsNumber: clientNumber, adress: adress, totalCost: coast, paymentMethod: payMethod, timeOrder: timeOrder, cafeID: idCafe) { success in
            if success {
                self.delegate?.succesCreate()
                
            } else {
                UIView.animate(withDuration: 0.8) {
                    self.fallView?.alpha = 100
                }
                
                UIView.animate(withDuration: 0.5, delay: 2.0, options: [], animations: {
                    self.fallView?.alpha = 0
                }, completion: nil)
            }
        }

    }
    
    @objc func fillAdress() {
        if adressButton?.titleLabel?.text != nil {
            adressTextField?.text = adressButton?.titleLabel?.text
            if let a = adressButton?.titleLabel?.text {
                adress = a
                similadAdressView.getCostAdress()
            }
            UIView.animate(withDuration: 0.5) {
                self.adressButton?.setTitle(nil, for: .normal)
                self.adressButton?.snp.updateConstraints { make in
                    make.height.equalTo(0)
                    make.left.right.equalToSuperview().inset(15)
                }
                self.layoutIfNeeded()
            }
        }
    }
    
    func generateLabel(text: String, font: UIFont, isUnderlining: Bool, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.font = font
        label.text = text
        label.textColor = textColor
        if isUnderlining == true {
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
            let underlineAttributedString = NSAttributedString(string: text, attributes: underlineAttribute)
            label.attributedText = underlineAttributedString
        }
        return label
    }
    
    
    
    
    
}


extension NewOrderView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        if textField == adressTextField {
            UIView.animate(withDuration: 0.5) { [self] in
                self.frame.origin.y = 0
                similadAdressView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
                commentTextField?.isUserInteractionEnabled = true
                self.layoutIfNeeded()
                textField.endEditing(true)
            }
        }
        if textField == commentTextField {
            UIView.animate(withDuration: 0.5) { [self] in
                self.frame.origin.y = 0
                self.layoutIfNeeded()
            }
            commentTextField?.endEditing(true)
            adressTextField?.isUserInteractionEnabled = true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if var a = phoneTextField?.text {
            let adress: ()? = delegate?.getLastAdress(phoneNumber: a, cafeID: "\(cafeID)") { adress in
                if adress != "" && self.adressTextField?.text == "" {
                    self.adressButton?.setTitle(adress, for: .normal)
                    UIView.animate(withDuration: 0.5) {
                        self.adressButton?.snp.updateConstraints { make in
                            make.height.equalTo(22)
                        }
                        self.layoutIfNeeded()
                    }
                }
                if adress == "" {
                    
                    self.adressButton?.setTitle(nil, for: .normal)
                    UIView.animate(withDuration: 0.5) {
                        self.adressButton?.snp.updateConstraints { make in
                            //make.height.equalTo(0)
                        }
                        self.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == adressTextField {
            UIView.animate(withDuration: 0.5) { [self] in
                self.frame.origin.y -= 280
                similadAdressView.snp.updateConstraints { make in
                    make.height.equalTo(280)
                }
                commentTextField?.isUserInteractionEnabled = false
                self.layoutIfNeeded()
            }
           
        }
        if textField == commentTextField {
            UIView.animate(withDuration: 0.5) { [self] in
                self.frame.origin.y -= 280
                adressTextField?.isUserInteractionEnabled = false
                self.layoutIfNeeded()
            }
        }
       
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == adressTextField {
            if var a = adressTextField?.text  {
                similadAdressView.reload(address: a)
            }
        }
        updateCreateOrderButtonState()
    }
    
    
}


extension NewOrderView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemsArr.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        if indexPath.row >= menuItemsArr.count  {
        
            addButton = {
                let button = UIButton(type: .system)
                button.setTitle("Добавить", for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
                button.tintColor = UIColor(red: 85/255, green: 112/255, blue: 241/255, alpha: 1)
                button.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
                return button
            }()
            cell.addSubview(addButton!)
            addButton?.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(21)
                make.centerY.equalToSuperview()
            }
            cell.accessoryView = addButton
            
        } else {
            
            let delButton: UIButton = {
                var button = UIButton(type: .system)
                let image = UIImage(systemName: "minus.circle.fill")
                button.setImage(image, for: .normal)
                button.tintColor = .systemRed
                return button
            }()
            cell.addSubview(delButton)
            delButton.snp.makeConstraints { make in
                make.height.width.equalTo(25)
                make.left.equalToSuperview().inset(20)
                make.centerY.equalToSuperview()
            }
            delButton.addTarget(self, action: #selector(delButtonTapped(_:)), for: .touchUpInside)
            let label = UILabel()
            let key = Array(menuItemsArr.keys)[indexPath.row] // Получаем ключ по индексу строки
            if let value = menuItemsArr[key] {
                let count = value.0 // Получаем первый элемент кортежа, представляющий количество
                label.text = "\(key) - \(count)"
            }
  
            
            label.font = .systemFont(ofSize: 18, weight: .regular)
            label.textColor = .black
            cell.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(delButton.snp.right).inset(-10)
                make.centerY.equalToSuperview()
            }
            let costLabel = UILabel()
            
            costLabel.font = .systemFont(ofSize: 18, weight: .bold)
            costLabel.textColor = .black
            if let value = menuItemsArr[key] {
                let count = value.1
                costLabel.text = "\(count) ₽"
            }
            cell.addSubview(costLabel)
            costLabel.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(15)
                make.centerY.equalToSuperview()
            }
            
            let separatorView = UIView()
            separatorView.backgroundColor = UIColor(red: 185/255, green: 185/255, blue: 187/255, alpha: 1)
            cell.addSubview(separatorView)
            separatorView.snp.makeConstraints { make in
                make.left.equalTo(delButton.snp.left).inset(1)
                make.right.equalToSuperview().inset(15)
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
            cell.accessoryView = delButton
        }
        
        return cell
    }
    
    @objc func addButtonTapped(_ sender: UIButton) {
        phoneTextField?.endEditing(true)
        adressTextField?.endEditing(true)
        delegate?.showVC()
    }
    
    @objc func delButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview as? UITableViewCell, let indexPath = tableView?.indexPath(for: cell) else {
            return
        }

        let key = Array(menuItemsArr.keys)[indexPath.row]
        menuItemsArr.removeValue(forKey: key)
        print(menuItemsArr)
        similadAdressView.getCostAdress()
        tableView?.beginUpdates()
        tableView?.deleteRows(at: [indexPath], with: .automatic)
        tableView?.endUpdates()
        updateCreateOrderButtonState()

        UIView.animate(withDuration: 0.5) {
            // Восстановление состояния адреса перед обновлением таблицы
            let previousAdress = self.adressButton?.titleLabel?.text
            let previousAdressText = self.adressTextField?.text
            
            // Обновление данных в таблице
            self.tableView?.reloadData()
            
            // Восстановление состояния адреса после обновления таблицы
            self.adressButton?.setTitle(previousAdress, for: .normal)
            self.adressTextField?.text = previousAdressText
            
            // Пересчет высоты таблицы
            self.tableView?.snp.updateConstraints({ make in
                make.height.equalTo((menuItemsArr.count + 1) * 44)
            })
            
            // Обновление размера и содержимого scrollView
            self.layoutIfNeeded()
            self.scrollView.layoutIfNeeded()
            self.updateContentSize()
        }
    }

    

}

extension NewOrderView: NewOrderViewProtocol {
    func fillButton(coast: String) {
        createOrderButton?.setTitle("Создать \(coast) ₽", for: .normal)
        totalCoast = Int(coast) ?? 0
        print(totalCoast)
    }
    
    func fillTextField(adress: String, cost: String) {
        adressTextField?.text = adress
        similarLabel?.text = "\(cost) ₽  "
        UIView.animate(withDuration: 0.3) { [self] in
            self.frame.origin.y = 0
            similadAdressView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            commentTextField?.alpha = 100
            self.layoutIfNeeded()
        }
        adressTextField?.endEditing(true)
        if adressTextField?.text != "" {
            self.adressButton?.setTitle(nil, for: .normal)
            UIView.animate(withDuration: 0.5) {
                self.adressButton?.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
                self.layoutIfNeeded()
            }
        }
    }
    
    
    
    
}

