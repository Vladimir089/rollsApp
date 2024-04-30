//
//  EditView.swift
//  rollsApp
//
//  Created by Владимир Кацап on 16.04.2024.
//

import UIKit

protocol EditViewProtocol: AnyObject {
    func fillTextField(adress: String, cost: String)
    func fillButton(coast: String)
    func updateTable()
}

class EditView: UIView {
    
    var index: Int = 0 {
        didSet {
            fillData()
            createInterface()
        }
    }
    
    weak var delegate: EditViewControllerDelegate?
    let scrollView = UIScrollView()
    let contentView = UIView()
    var phoneTextField: UITextField?
    var tableView: UITableView?
    var addButton: UIButton?
    var adressButton: UIButton?
    var adressTextField: UITextField?
    let similadAdressView = SimilarAdressTable()
    var similarLabel: UILabel?
    var commentTextField: UITextField?
    var oplataSegmentedControl: UISegmentedControl?
    var createOrderButton: UIButton?
    let itemsForSegmented = ["Перевод", "Наличка", "На кассе"]
    var numberPhoneLabel: UILabel?
    
    //MARK: -init
    override init(frame: CGRect) {
        super .init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateContentSize()
        print(menuItemsArr)

    }
    
    func fillData() {
        //адрес
        adress = orderStatus[index].0.address
        //меню
        let inputString = orderStatus[index].0.menuItems
        let items = inputString.components(separatedBy: ", ")
        for item in items {
            let components = item.components(separatedBy: " - ")
            if components.count == 2 {
                let name = components[0]
                if let quantity = Int(components[1]) {
                    if let index = allDishes.firstIndex(where: { $0.0.name == name }) {
                        let price = allDishes[index].0.price * quantity // Цена блюда
                        menuItemsArr.append((name, (quantity, price)))
                    } else {
                        print("Блюдо с названием '\(name)' не найдено в массиве allDishes.")
                    }
                } else {
                    print("Ошибка при преобразовании количества для элемента: \(item)")
                }
            } else {
                print("Ошибка разделения элемента: \(item)")
            }
        }
        similadAdressView.getCostAdress()
    }
    
    func updateContentSize() {
        let contentHeight = contentView.subviews.reduce(0) { max($0, $1.frame.maxY) }
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
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
    
    func createInterface() {
        backgroundColor = .white
        let tapInViewGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(tapInViewGesture)
        addGestureRecognizer(tapInViewGesture)
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        contentView.isUserInteractionEnabled = true
        addSubview(scrollView)
        
        scrollView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        contentView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            //make.top.equalToSuperview().inset(100)
            make.top.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            
        }
        
        numberPhoneLabel = generateLabel(text: "НОМЕР ТЕЛЕФОНА",
                                             font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                             isUnderlining: false,
                                             textColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1))
        
        contentView.addSubview(numberPhoneLabel!)
        numberPhoneLabel?.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(25)
            make.top.equalToSuperview().inset(20)
        }
        
        let guestLabel = generateLabel(text: "Гость",
                                       font: UIFont.systemFont(ofSize: 15, weight: .bold),
                                       isUnderlining: true,
                                       textColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1))
        contentView.addSubview(guestLabel)
        guestLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(25)
            make.top.equalTo((numberPhoneLabel?.snp.top)!)
        }
        
        phoneTextField = {
            let textField = UITextField()
            let leftPaddingView = UIView(frame: CGRect(x: 10, y: 0, width: 37, height: 40))
            let view = UIView(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
            view.backgroundColor = UIColor(hex: "#F2F2F7")
            view.layer.cornerRadius = 5
            let label = UILabel(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
            label.textColor = .black
            label.text = "+7"
            view.addSubview(label)
            leftPaddingView.addSubview(view)
            textField.leftView = leftPaddingView
            textField.leftViewMode = .always
            textField.leftViewMode = .always
            textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.rightViewMode = .always
            textField.keyboardType = .numberPad
            textField.textColor = .black
            textField.text = orderStatus[index].0.phone
            textField.backgroundColor = .white
            textField.layer.cornerRadius = 10
            textField.delegate = self
            return textField
        }()
        scrollView.addSubview(phoneTextField!)
        phoneTextField?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo((numberPhoneLabel?.snp.bottom)!).inset(-10)
            make.height.equalTo(44)
        })
        
        let orderLabel = generateLabel(text: "ЗАКАЗ",
                                       font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                       isUnderlining: false,
                                       textColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1))
        contentView.addSubview(orderLabel)
        orderLabel.snp.makeConstraints { make in
            make.left.equalTo((numberPhoneLabel?.snp.left)!)
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
            make.left.equalTo((numberPhoneLabel?.snp.left)!)
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
            textField.text = orderStatus[index].0.address
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
        
        similadAdressView.editDelegate = self
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
            make.left.equalTo((numberPhoneLabel?.snp.left)!)
            make.top.equalTo(adressTextField!.snp.bottom).inset(-20)
        }
        
        commentTextField = {
            let textField = UITextField()
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.leftViewMode = .always
            textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.rightViewMode = .always
            textField.text = "\(orderStatus[index].0.clientsNumber)"
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
            var indexOplata = 0
            for index in 0..<itemsForSegmented.count {
                print(index)
                if itemsForSegmented[index] == orderStatus[self.index].0.paymentMethod {
                    indexOplata = index
                }
            }
            print(orderStatus[index].0.paymentMethod)
            let segmentedControl = UISegmentedControl(items: itemsForSegmented)
            segmentedControl.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 230/255, alpha: 1)
            segmentedControl.selectedSegmentTintColor = .white
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            segmentedControl.selectedSegmentIndex = indexOplata
            segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
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
            button.setTitle("Сохранить 0 ₽", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            button.tintColor = .white
            button.addTarget(self, action: #selector(saveOrder), for: .touchUpInside)
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
            make.height.equalTo(200) //мб тут сдеклать высоту таблицы
            make.left.right.equalToSuperview()
            make.top.equalTo((createOrderButton?.snp.bottom)!).inset(-15)
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
    
    //MARK: -Objc func
    
    @objc func hideKeyboard() {
        phoneTextField?.endEditing(true)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
    }
    
    @objc func saveOrder() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let currentDate = Date()

        
        let phone = phoneTextField?.text ?? ""
        var menuItems = ""
        let clientNumber = Int(commentTextField?.text ?? "1") ?? 1
        let adress = adress
        let coast = totalCoast
        let payMethod = itemsForSegmented[oplataSegmentedControl!.selectedSegmentIndex]
        let timeOrder = dateFormatter.string(from: currentDate)
        let idCafe = cafeID
        let orderID = orderStatus[index].0.id

        if phoneTextField?.text?.count ?? 0 < 10 {
            UIView.animate(withDuration: 0.5) {
                self.phoneTextField?.backgroundColor = .red
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.animate(withDuration: 0.5) {
                    self.phoneTextField?.backgroundColor = .white // или ваш исходный цвет
                }
            }
            return
        }
        
        for (index, (key, value)) in menuItemsArr.enumerated() {
            let count = value.0
            menuItems.append("\(key) - \(count)")

            if index != menuItemsArr.count - 1 {
                menuItems.append(", ")
            }
        }
        
       
        print("МЕТОД ОПЛАТЫ \(payMethod)")
    
        
        delegate?.updateOrder(phonee: phone, menuItems: menuItems, clientsNumber: clientNumber, adress: adress, totalCost: coast, paymentMethod: payMethod, timeOrder: timeOrder, cafeID: idCafe, orderId: orderID, completion:  { success in
            if success {
                self.delegate?.succesCreate()
                
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.createOrderButton?.center.x -= 12
                }) { _ in
                    // Анимация движения кнопки вправо после завершения анимации влево
                    UIView.animate(withDuration: 0.2, animations: {
                        self.createOrderButton?.center.x += 24
                    }) { _ in
                        // Возврат кнопки в исходное положение после завершения анимации вправо
                        UIView.animate(withDuration: 0.2, animations: {
                            self.createOrderButton?.center.x -= 12
                        })
                    }
                }
                // Анимация изменения цвета кнопки
                UIView.transition(with: self.createOrderButton!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.createOrderButton?.backgroundColor = .red
                }) { _ in
                    // Возвращаем исходный цвет после завершения анимации
                    UIView.transition(with: self.createOrderButton!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        self.createOrderButton?.backgroundColor = .systemBlue
                    }, completion: nil)
                }
            }
        })
        
    }
}

extension EditView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTextField {
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            return newString.count <= 10
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        if textField == adressTextField {
            UIView.animate(withDuration: 0.5) { [self] in
                self.frame.origin.y = 0
                commentTextField?.isUserInteractionEnabled = true
                self.layoutIfNeeded()
                textField.endEditing(true)
            }
        }
        if textField == commentTextField {
            UIView.animate(withDuration: 0.5) { [self] in
                self.frame.origin.y = 0
                self.layoutIfNeeded()
                textField.endEditing(true)
                adressTextField?.isUserInteractionEnabled = true
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textPhoneTextField = phoneTextField?.text {
            let _: ()? = delegate?.getLastAdress(phoneNumber: textPhoneTextField, cafeID: "\(cafeID)") { adress in
                if adress != "" && self.adressTextField?.text == "" {
                    self.adressButton?.setTitle(adress, for: .normal)
                    UIView.animate(withDuration: 0.5) {
                        self.adressButton?.snp.updateConstraints { make in
                            make.height.equalTo(22)
                        }
                        self.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == adressTextField {
            delegate?.showAdressVC()
            adressTextField?.endEditing(true)
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == adressTextField {
            if var a = adressTextField?.text  {
                similadAdressView.reload(address: a)
            }
        }
    }
}


extension EditView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemsArr.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        if indexPath.row >= menuItemsArr.count  {
        
            addButton = {
                let button = UIButton(type: .system)
                button.setTitle("Изменить", for: .normal)
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
            if indexPath.row < menuItemsArr.count {
                let item = menuItemsArr[indexPath.row]
                let key = item.0
                let value = item.1
                label.text = "\(key) - "
            } else {
                label.text = ""
            }
            label.font = .systemFont(ofSize: 18, weight: .regular)
            label.textColor = .black
            cell.addSubview(label)
            let labelCount = UILabel()
            if indexPath.row < menuItemsArr.count {
                let item = menuItemsArr[indexPath.row]
                let value = item.1.0
                labelCount.text = "\(value)"
            } else {
                labelCount.text = ""
            }
            labelCount.font = .systemFont(ofSize: 18, weight: .semibold)
            labelCount.textColor = UIColor(red: 85/255, green: 51/255, blue: 85/255, alpha: 1)
            cell.addSubview(labelCount)
            
            label.snp.makeConstraints { make in
                make.left.equalTo(delButton.snp.right).inset(-10)
                make.centerY.equalToSuperview()
            }
            labelCount.snp.makeConstraints { make in
                make.left.equalTo(label.snp.right)
                make.centerY.equalToSuperview()
            }
            let costLabel = UILabel()
            
            costLabel.font = .systemFont(ofSize: 18, weight: .bold)
            costLabel.textColor = .black
            if indexPath.row < menuItemsArr.count {
                let item = menuItemsArr[indexPath.row]
                let value = item.1.1
                costLabel.text = "\(value) ₽"
            } else {
                labelCount.text = ""
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

        if indexPath.row < menuItemsArr.count {
            var item = menuItemsArr[indexPath.row]
            if item.1.0 > 1 {
                var pricePerItem = item.1.1 / item.1.0
                item.1.0 -= 1
                item.1.1 -= pricePerItem
                menuItemsArr[indexPath.row] = item
            } else {
                menuItemsArr.remove(at: indexPath.row)
                tableView?.deleteRows(at: [indexPath], with: .automatic)
            }
        }

        similadAdressView.getCostAdress()
        tableView?.beginUpdates()
        tableView?.endUpdates()

        UIView.animate(withDuration: 0.5) {
            let previousAdress = self.adressButton?.titleLabel?.text
            let previousAdressText = self.adressTextField?.text
            self.tableView?.reloadData()
            self.adressButton?.setTitle(previousAdress, for: .normal)
            self.adressTextField?.text = previousAdressText
            self.tableView?.snp.updateConstraints({ make in
                make.height.equalTo((menuItemsArr.count + 1) * 44)
            })
            self.layoutIfNeeded()
            self.scrollView.layoutIfNeeded()
            self.updateContentSize()
        }
    }
}

extension EditView: EditViewProtocol {
    func updateTable() {
        print("Обновляем")
        self.tableView?.snp.updateConstraints({ make in
            make.height.equalTo((menuItemsArr.count + 1) * 44)
        })
        self.tableView?.reloadData()
        // Обновление размера и содержимого scrollView
        self.layoutIfNeeded()
        self.scrollView.layoutIfNeeded()
        self.updateContentSize()
    }
    
    func fillButton(coast: String) {
        createOrderButton?.setTitle("Сохранить \(coast) ₽", for: .normal)
        totalCoast = Int(coast) ?? 0
        print(totalCoast)
    }
    
    func fillTextField(adress: String, cost: String) {
        adressTextField?.text = adress
        similarLabel?.text = "\(cost) ₽  "
        UIView.animate(withDuration: 0.3) { [self] in
            self.frame.origin.y = 0
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

