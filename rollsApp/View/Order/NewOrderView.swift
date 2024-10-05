//
//  NewOrderView.swift
//  rollsApp
//
//  Created by Владимир Кацап on 05.04.2024.
//

import UIKit
import SnapKit


//MARK: -Protocol

protocol NewOrderViewProtocol: AnyObject {
    func fillTextField(adress: String, cost: String)
    func fillButton(coast: String)
    func updateTable()
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

    var oldAdress = ""
    
    //MARK: -init
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        settingsView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateContentSize()

    }
    
    func updateContentSize() {
        let contentHeight = contentView.subviews.reduce(0) { max($0, $1.frame.maxY) }
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: -Func create interface
    
    private func settingsView() {
        backgroundColor = .settingBG
        
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
            make.width.equalTo(55)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }
        
        let newOrderLabel = generateLabel(text: "Новый Заказ", font: .systemFont(ofSize: 41, weight: .bold), isUnderlining: false, textColor: .TC)
        addSubview(newOrderLabel)
        newOrderLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(50)
        }
        
        scrollView.showsVerticalScrollIndicator = false
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
            make.height.equalTo((menuItemsArr.count + 1) * 44)
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
            return textField
        }()
        viewCenter.addSubview(phoneTextField!)
        phoneTextField?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(13)
            make.height.equalTo(44)
            make.top.equalToSuperview()
        })
        
        
        adressButton = {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            button.tintColor = .TC
            button.contentHorizontalAlignment = .left
            button.alpha = 0
            return button
        }()
        scrollView.addSubview(adressButton!)
        adressButton?.snp.makeConstraints({ make in
            make.right.equalTo((phoneTextField ?? UIView()).snp.right)
            make.bottom.equalTo(viewCenter.snp.top).inset(-3)
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
            //similarLabel?.backgroundColor = .red
            textField.placeholder = "Адрес"
            textField.rightView = similarLabel!
            textField.rightViewMode = .always
            textField.textColor = .TC
            textField.backgroundColor = .settings
            textField.layer.cornerRadius = 10
            textField.delegate = self
            return textField
        }()

        scrollView.addSubview(adressTextField!)
        adressTextField?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(28)
            //make.top.equalTo(adressButton!.snp.bottom).inset(-10)
            make.top.equalTo(oneSep.snp.bottom)
            make.height.equalTo(44)
        })
        

        similadAdressView.delelagate = self
        
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
            return textField
        }()
        viewCenter.addSubview(commentTextField!)
        commentTextField?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(13)
            make.top.equalTo(twoSep.snp.bottom)
            make.height.equalTo(44)
        })
 
        oplataSegmentedControl = {
            
            let segmentedControl = UISegmentedControl(items: itemsForSegmented)
            segmentedControl.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 230/255, alpha: 1)
            segmentedControl.selectedSegmentTintColor = .white
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
            return segmentedControl
        }()
        
        scrollView.addSubview(oplataSegmentedControl!)
        oplataSegmentedControl?.snp.makeConstraints({ make in
            make.height.equalTo(44)
            make.top.equalTo(viewCenter.snp.bottom).inset(-25)
            make.left.right.equalToSuperview().inset(15)
        })
        
        createOrderButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            button.setTitle("Создать 0 ₽", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            button.tintColor = .white
            button.addTarget(self, action: #selector(createOrder), for: .touchUpInside)
            button.layer.cornerRadius = 12
            button.isEnabled = false
            return button
        }()

        scrollView.addSubview(createOrderButton!)
        createOrderButton?.snp.makeConstraints({ make in
            make.height.equalTo(50)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo((oplataSegmentedControl?.snp.bottom)!).inset(-25)
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
    
    func butonIsEnabled() {
        if menuItemsArr.count != 0 {
            createOrderButton?.isEnabled = true
        } else {
            createOrderButton?.isEnabled = false
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
    
    //MARK: -objc func
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
    }
    

    
    @objc func createOrder() {
        
        self.createOrderButton?.isUserInteractionEnabled = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let currentDate = Date()
        
        var phone = phoneTextField?.text ?? ""
        var menuItems = ""
        let clientNumber: String = commentTextField?.text ?? ""
        var adress = adress
        let coast = totalCoast
        let payMethod = itemsForSegmented[oplataSegmentedControl!.selectedSegmentIndex]
        let timeOrder = dateFormatter.string(from: currentDate)
        let idCafe = cafeID


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
        
        delegate?.createNewOrder(phonee: phone, menuItems: menuItems, clientsNumber: clientNumber, adress: adress, totalCost: coast, paymentMethod: payMethod, timeOrder: timeOrder, cafeID: idCafe) { success in

            if success {
                self.delegate?.succesCreate()
                self.createOrderButton?.isUserInteractionEnabled = true
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.createOrderButton?.center.x -= 12
                    self.createOrderButton?.isUserInteractionEnabled = true
                }) { _ in
                    // Анимация движения кнопки вправо после завершения анимации влево
                    UIView.animate(withDuration: 0.2, animations: {
                        self.createOrderButton?.center.x += 24
                        self.createOrderButton?.isUserInteractionEnabled = true
                    }) { _ in
                        // Возврат кнопки в исходное положение после завершения анимации вправо
                        UIView.animate(withDuration: 0.2, animations: {
                            self.createOrderButton?.center.x -= 12
                            self.createOrderButton?.isUserInteractionEnabled = true 
                        })
                    }
                }
                // Анимация изменения цвета кнопки
                UIView.transition(with: self.createOrderButton!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.createOrderButton?.backgroundColor = .red
                    self.createOrderButton?.isUserInteractionEnabled = true
                }) { _ in
                    // Возвращаем исходный цвет после завершения анимации
                    UIView.transition(with: self.createOrderButton!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        self.createOrderButton?.backgroundColor = .systemBlue
                        self.createOrderButton?.isUserInteractionEnabled = true
                    }, completion: nil)
                }
                
                
            }
        }
        
    }
    

    
    @objc func hideKeyboard() {
        butonIsEnabled()
        phoneTextField?.endEditing(true)
    }
      
}


extension NewOrderView: UITextFieldDelegate {
    
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
                print(phoneTextField?.text ?? "")
                delegate?.getLastAdress(phoneNumber: phoneTextField?.text ?? "", cafeID: "\(cafeID)") { adres in
                    if adres != "" && self.adressTextField?.text == "" {
                        print(234)
                        self.oldAdress = adres
                        adress = adres
                        self.adressTextField?.text = adres
                        self.similadAdressView.getCostAdress()
                        if adress == self.oldAdress {
                            self.adressTextField?.textColor = .systemBlue
                        } else {
                            self.adressTextField?.textColor = .black
                        }
                    }

                }
                return false
            }

        }
        // Для других полей ввода возвратить true, чтобы разрешить обычное изменение текста
        return true
    }

    func formatPhoneNumber(number: String) -> String {
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
        butonIsEnabled()
        if let textPhoneTextField = phoneTextField?.text {
            let _: ()? = delegate?.getLastAdress(phoneNumber: textPhoneTextField, cafeID: "\(cafeID)") { adress in
                if adress != "" && self.adressTextField?.text == "" {
                    self.adressTextField?.text = adress
                }
                if adress == "" {
                    
                    self.adressTextField?.text = adress
                    
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
        if textField == commentTextField {
            UIView.animate(withDuration: 0.5) { [self] in
                adressTextField?.isUserInteractionEnabled = false
                self.layoutIfNeeded()
            }
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
                button.setTitle("Меню", for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
                button.tintColor = .systemBlue
                button.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
                return button
            }()
            cell.addSubview(addButton!)
            addButton?.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(13)
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
                make.height.width.equalTo(25)
                make.left.equalToSuperview().inset(13)
                make.centerY.equalToSuperview()
            }
            delButton.addTarget(self, action: #selector(delButtonTapped(_:)), for: .touchUpInside)
            let label = UILabel()
            // Проверяем, что индекс не превышает границы массива
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
            labelCount.textColor = UIColor(red: 85/255, green: 51/255, blue: 85/255, alpha: 1) //ТУТ менять
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
            separatorView.backgroundColor = .separator
            cell.addSubview(separatorView)
            separatorView.snp.makeConstraints { make in
                make.left.equalTo(delButton.snp.left).inset(1)
                make.right.equalToSuperview().inset(15)
                make.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
            cell.accessoryView = delButton
        }
        return cell
    }
    
    @objc func addButtonTapped(_ sender: UIButton) {
        butonIsEnabled()
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
                print(menuItemsArr)
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
            self.delegate?.reloadDishes()   
            self.updateContentSize()
        }
    }
}

extension NewOrderView: NewOrderViewProtocol {
    func updateTable() {
        butonIsEnabled()
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
        createOrderButton?.setTitle("Создать \(coast) ₽", for: .normal)
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
        if adress == self.oldAdress {
            self.adressTextField?.textColor = .systemBlue
        } else {
            self.adressTextField?.textColor = .black
        }
    }
}

