//
//  EditView.swift
//  rollsApp
//
//  Created by Владимир Кацап on 16.04.2024.
//

import UIKit
import Alamofire

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
    var callButton: UIButton?
    var labelItog: UILabel?
    var isEdit = 1
    var callButtonPhone: UIButton?
    
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
    }
    
    func fillData() {
        //адрес
        adress = orderStatus[index].address
        //меню
        let inputString = orderStatus[index].menuItems
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
        backgroundColor = .settingBG
        let tapInViewGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(tapInViewGesture)
        addGestureRecognizer(tapInViewGesture)
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        contentView.isUserInteractionEnabled = true
        addSubview(scrollView)
        
        scrollView.backgroundColor = .settingBG
        contentView.backgroundColor = .settingBG
        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            
        }
        
        tableView = {
            let view = UITableView()
            view.delegate = self
            view.dataSource = self
            view.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            view.backgroundColor = .settings
            view.layer.cornerRadius = 15
            view.isScrollEnabled = false
            view.rowHeight = UITableView.automaticDimension // Установка автоматической высоты ячеек
            view.estimatedRowHeight = 44
            view.separatorStyle = .none
            return view
        }()
        scrollView.addSubview(tableView!)
        tableView?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview()
            if isEdit == 1 {
                make.height.equalTo((menuItemsArr.count) * 44)
            } else {
                make.height.equalTo((menuItemsArr.count + 1) * 44)
            }
        })
        
        let viewCenter: UIView = {
            let view = UIView()
            view.backgroundColor = .settings
            view.layer.cornerRadius = 20
            return view
        }()
        scrollView.addSubview(viewCenter)
        viewCenter.snp.makeConstraints { make in
            make.height.equalTo(134)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo((tableView ?? UIView()).snp.bottom).inset(-25)
        }
        
        callButtonPhone = {
            let button = UIButton(type: .system)
            let image = UIImage.clearPhone.resize(targetSize: CGSize(width: 20, height: 20))
            button.setImage(image, for: .normal)
            button.backgroundColor = .clear
            return button
        }()
        viewCenter.addSubview(callButtonPhone!)
        callButtonPhone?.snp.makeConstraints({ make in
            make.height.width.equalTo(44)
            make.right.equalToSuperview().inset(13)
            make.top.equalToSuperview()
        })
        callButtonPhone?.addTarget(self, action: #selector(call), for: .touchUpInside)
        
        phoneTextField = {
            let textField = UITextField()
            textField.placeholder = "Номер телефона"
            textField.leftViewMode = .always
            textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            textField.rightViewMode = .always
            textField.keyboardType = .numberPad
            textField.textColor = .TC
            textField.backgroundColor = .settings
            textField.layer.cornerRadius = 10
            textField.delegate = self
            textField.text = orderStatus[index].phone
            return textField
        }()
        viewCenter.addSubview(phoneTextField!)
        phoneTextField?.snp.makeConstraints({ make in
            make.left.equalToSuperview().inset(13)
            make.right.equalTo(callButtonPhone!.snp.left)
            make.height.equalTo(44)
            make.top.equalToSuperview()
        })
        
        adressButton = {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            button.tintColor = .TC
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(fillAdress), for: .touchUpInside)
            button.alpha = 0
            return button
        }()
        scrollView.addSubview(adressButton!)
        adressButton?.snp.makeConstraints({ make in
            make.left.equalTo((phoneTextField ?? UIView()).snp.left)
            make.bottom.equalTo(viewCenter.snp.top)
            make.height.equalTo(18)
            
        })
        
        let oneSep: UIView = {
            let view = UIView()
            view.backgroundColor = .separator
            return view
        }()
        viewCenter.addSubview(oneSep)
        oneSep.snp.makeConstraints { make in
            make.height.equalTo(0.3)
            make.left.right.equalToSuperview().inset(13)
            make.top.equalTo((phoneTextField ?? UIView()).snp.bottom)
        }
        
        adressTextField = {
            let textField = UITextField()
            similarLabel = UILabel()
            similarLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            similarLabel?.text = "0 ₽  "
            similarLabel?.textColor = .TC
            textField.text = orderStatus[index].address
            textField.placeholder = "Адрес"
            textField.rightView = similarLabel!
            textField.rightViewMode = .always
            textField.textColor = .TC
            textField.backgroundColor = .settings
            textField.layer.cornerRadius = 10
            textField.delegate = self
            return textField
        }()
        similadAdressView.editDelegate = self
        scrollView.addSubview(adressTextField!)
        adressTextField?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(28)
            make.top.equalTo(oneSep.snp.bottom)
            make.height.equalTo(44)
        })
        
        
        let twoSep: UIView = {
            let view = UIView()
            view.backgroundColor = .separator
            return view
        }()
        viewCenter.addSubview(twoSep)
        twoSep.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.left.right.equalToSuperview().inset(13)
            make.top.equalTo((adressTextField ?? UIView()).snp.bottom)
        }
        
        commentTextField = {
            let textField = UITextField()
            textField.leftViewMode = .always
            textField.placeholder = "Комментарий"
            textField.textColor = .TC
            textField.backgroundColor = .settings
            textField.layer.cornerRadius = 10
            textField.delegate = self
            textField.text = "\(orderStatus[index].clientsNumber)"
            return textField
        }()
        viewCenter.addSubview(commentTextField!)
        commentTextField?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(13)
            make.top.equalTo(twoSep.snp.bottom)
            make.height.equalTo(44)
        })
        
        
        
        
        
        
        oplataSegmentedControl = {
            var indexOplata = 0
            for index in 0..<itemsForSegmented.count {
                print(index)
                if itemsForSegmented[index] == orderStatus[self.index].paymentMethod {
                    indexOplata = index
                }
            }
            print(orderStatus[index].paymentMethod)
            let segmentedControl = UISegmentedControl(items: itemsForSegmented)
            segmentedControl.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 230/255, alpha: 1)
            segmentedControl.selectedSegmentTintColor = .white
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            segmentedControl.selectedSegmentIndex = indexOplata
            segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
            segmentedControl.isUserInteractionEnabled = false
            return segmentedControl
        }()
        scrollView.addSubview(oplataSegmentedControl!)
        oplataSegmentedControl?.snp.makeConstraints({ make in
            make.height.equalTo(44)
            make.top.equalTo(viewCenter.snp.bottom).inset(-25)
            make.left.right.equalToSuperview().inset(15)
        })
        
        let viewBotton: UIView = {
            let view = UIView()
            view.backgroundColor = .settings
            view.layer.cornerRadius = 12
            return view
        }()
        contentView.addSubview(viewBotton)
        viewBotton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(oplataSegmentedControl!.snp.bottom).inset(-25)
        }
        
        let labelItogText: UILabel = {
            let label = UILabel()
            label.text = "Итого"
            label.font = .systemFont(ofSize: 18, weight: .bold)
            label.textColor = .TC
            return label
        }()
        viewBotton.addSubview(labelItogText)
        labelItogText.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        labelItog = {
            let label = UILabel()
            label.text = "0 ₽"
            label.font = .systemFont(ofSize: 18, weight: .bold)
            label.textColor = .TC
            label.textAlignment = .right
            return label
        }()
        viewBotton.addSubview(labelItog!)
        labelItog?.snp.makeConstraints({ make in
            make.left.equalTo(labelItogText.snp.right)
            make.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        })
        
        
        createOrderButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            button.setTitle("Сохранить", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            button.tintColor = .white
            button.alpha = 0
            button.layer.cornerRadius = 12
            return button
        }()
        
        if isEdit == 1 && orderStatus[index].paymentStatus != "Оплачено" {
            createOrderButton?.setTitle("Оплатить", for: .normal)
            createOrderButton?.backgroundColor = .systemGreen
            createOrderButton?.addTarget(self, action: #selector(changeStatus), for: .touchUpInside)
            createOrderButton?.alpha = 1
        } else if isEdit == 1 && orderStatus[index].paymentStatus == "Оплачено" {
            createOrderButton?.alpha = 0
        } else {
            createOrderButton?.setTitle("Сохранить", for: .normal)
            createOrderButton?.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            createOrderButton?.addTarget(self, action: #selector(saveOrder), for: .touchUpInside)
            createOrderButton?.alpha = 1
        }
            
        
        scrollView.addSubview(createOrderButton!)
        createOrderButton?.snp.makeConstraints({ make in
            make.height.equalTo(50)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(viewBotton.snp.bottom).inset(-25)
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
        
        
        checkEdit()
        
    }
    
    func checkEdit() {
        createOrderButton?.removeTarget(nil, action: nil, for: .allEvents)
        
        if isEdit == 1 && orderStatus[index].paymentStatus == "Не оплачено" {
            createOrderButton?.setTitle("Оплатить", for: .normal)
            createOrderButton?.backgroundColor = .systemGreen
            createOrderButton?.addTarget(self, action: #selector(changeStatus), for: .touchUpInside)
            UIView.animate(withDuration: 0.5) {
                self.createOrderButton?.alpha = 1
            }
            
        } else if isEdit == 1 && orderStatus[index].paymentStatus == "Оплачено" {
            createOrderButton?.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.createOrderButton?.alpha = 0
            }
        } else {
            createOrderButton?.setTitle("Сохранить", for: .normal)
            createOrderButton?.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            createOrderButton?.addTarget(self, action: #selector(saveOrder), for: .touchUpInside)
            UIView.animate(withDuration: 0.5) {
                self.createOrderButton?.alpha = 1
            }
        }
    }
    
    
    
    @objc func changeStatus() {
        delegate?.changePaymentStatus()
    }
    
    @objc func call() {
        delegate?.cell()
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
    
    func generateButton(text: String, font: UIFont, isUnderlining: Bool, textColor: UIColor) -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = font
        button.setTitle(text, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        if isUnderlining == true {
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
            let underlineAttributedString = NSAttributedString(string: text, attributes: underlineAttribute)
            button.titleLabel?.attributedText = underlineAttributedString
        }
        return button
    }
    
    func butonIsEnabled() {
        if menuItemsArr.count != 0 {
            createOrderButton?.isEnabled = true
        } else {
            createOrderButton?.isEnabled = false
        }
    }
    
    //MARK: -Objc func
    
    
    
    @objc func hideKeyboard() {
        butonIsEnabled()
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
        
        
        var phone = phoneTextField?.text ?? ""
        var menuItems = ""
        let clientNumber = Int(commentTextField?.text ?? "1") ?? 1
        var adress = adress
        let coast = totalCoast
        let payMethod = itemsForSegmented[oplataSegmentedControl!.selectedSegmentIndex]
        let timeOrder = dateFormatter.string(from: currentDate)
        let idCafe = cafeID
        let orderID = orderStatus[index].id
        
        if phoneTextField?.text?.count ?? 0 < 10 {
            phone = "+7\(phoneCafe)"
        }
        
        if adress == "" {
            adress = "С собой, 0, Самовывоз"
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
        butonIsEnabled()
        if textField == phoneTextField {
            // Если начинается ввод и поле пустое, устанавливаем "+7 "
            if textField.text?.isEmpty ?? true && string.count > 0 {
                textField.text = "+7 "
                // После установки "+7 " нужно применить форматирование для оставшейся части номера (если есть)
                let formattedString = formatPhoneNumber(number: textField.text! + string)
                textField.text = formattedString
                return false
            }
            
            // Временная строка с возможным новым значением
            let prospectiveText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            // Проверка на попытку удаления части "+7 "
            if string.count == 0 && range.location < 3 {
                // Предотвратим удаление "+7"
                return false
            } else {
                // Применить форматирование для новой строки
                let formattedString = formatPhoneNumber(number: prospectiveText)
                textField.text = formattedString
                // Предотвратить дальнейшую обработку ввода, так как мы уже обновили текст поля ввода
                return false
            }
        }
        // Для других полей ввода возвратить true, чтобы разрешить обычное изменение текста
        return true
    }
    
    func formatPhoneNumber(number: String) -> String {
        butonIsEnabled()
        var cleanNumber = number.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        
        // Убедиться, что номер начинается с "7" и удаление первой "7"
        if cleanNumber.hasPrefix("7") {
            cleanNumber = String(cleanNumber.dropFirst())
        }
        
        // Контент после "+7 ", который нам нужно проверить на нежелательные символы и возможно удалить
        let additionalNumbers = cleanNumber
        
        // Удаление нежелательных символов из начала дополнительной части номера
        let charsToRemove: [Character] = ["+", "7", "8"]
        let filteredNumbers = additionalNumbers.drop(while: { charsToRemove.contains($0) })
        
        var result = "+7 "
        let mask = "(###) ### ## ##"
        var index = filteredNumbers.startIndex
        
        for ch in mask where index < filteredNumbers.endIndex {
            if ch == "#" {
                result.append(filteredNumbers[index])
                index = filteredNumbers.index(after: index)
            } else {
                result.append(ch)
            }
        }
        
        return result
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        butonIsEnabled()
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
            butonIsEnabled()
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
        butonIsEnabled()
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
        butonIsEnabled()
        if textField == adressTextField {
            delegate?.showAdressVC()
            adressTextField?.endEditing(true)
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        butonIsEnabled()
        if textField == adressTextField {
            if let text = adressTextField?.text  {
                similadAdressView.reload(address: text)
            }
        }
    }
}


extension EditView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEdit == 1 {
            return menuItemsArr.count
        } else {
            return menuItemsArr.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        if indexPath.row >= menuItemsArr.count  {
            
            addButton = {
                let button = UIButton(type: .system)
                button.setTitle("Изменить", for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
                button.tintColor = .systemBlue
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
                let button = UIButton(type: .system)
                let image = UIImage(systemName: "minus.circle.fill")
                button.setImage(image, for: .normal)
                button.tintColor = .systemRed
                return button
            }()
            cell.addSubview(delButton)
            delButton.snp.makeConstraints { make in
                if isEdit == 1 {
                    make.height.width.equalTo(0)
                    make.left.equalToSuperview().inset(10)
                } else {
                    make.height.width.equalTo(25)
                    make.left.equalToSuperview().inset(20)
                }
                
                make.left.equalToSuperview().inset(20)
                make.centerY.equalToSuperview()
            }
            delButton.addTarget(self, action: #selector(delButtonTapped(_:)), for: .touchUpInside)
            let label = UILabel()
            if indexPath.row < menuItemsArr.count {
                let item = menuItemsArr[indexPath.row]
                let key = item.0
                label.text = "\(key) - "
            } else {
                label.text = ""
            }
            label.font = .systemFont(ofSize: 18, weight: .regular)
            label.textColor = .TC
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
            labelCount.textColor = UIColor(red: 85/255, green: 51/255, blue: 85/255, alpha: 1) //ТУТ
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
            costLabel.textColor = .TC
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
                make.left.equalToSuperview().inset(20)
                make.right.equalToSuperview().inset(15)
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
            
            
            if indexPath.row == menuItemsArr.count - 1 && isEdit == 1 {
                separatorView.alpha = 0
            } else {
                separatorView.alpha = 1
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
        butonIsEnabled()
        guard let cell = sender.superview as? UITableViewCell, let indexPath = tableView?.indexPath(for: cell) else {
            return
        }
        
        if indexPath.row < menuItemsArr.count {
            var item = menuItemsArr[indexPath.row]
            if item.1.0 > 1 {
                let pricePerItem = item.1.1 / item.1.0
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
        butonIsEnabled()
        print("Обновляем")
        self.tableView?.snp.updateConstraints({ make in
            if isEdit == 1 {
                make.height.equalTo((menuItemsArr.count) * 44)
            } else {
                make.height.equalTo((menuItemsArr.count + 1) * 44)
            }
            
        })
        self.tableView?.reloadData()
        // Обновление размера и содержимого scrollView
        self.layoutIfNeeded()
        self.scrollView.layoutIfNeeded()
        self.updateContentSize()
    }
    
    func fillButton(coast: String) {
        butonIsEnabled()
        labelItog?.text = "\(coast) ₽"
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

