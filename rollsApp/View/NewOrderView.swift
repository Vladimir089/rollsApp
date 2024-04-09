//
//  NewOrderView.swift
//  rollsApp
//
//  Created by Владимир Кацап on 05.04.2024.
//

import UIKit
import SnapKit

class NewOrderView: UIView {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    var phoneTextField: UITextField?
    var tableView: UITableView?
    var addButton: UIButton?
    weak var delegate: NewOrderViewControllerShowWCDelegate?
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        settingsView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateContentSize()
        print(menuItemsArr)
    }
    
    func updateContentSize() {
        let contentHeight = contentView.subviews.reduce(0) { max($0, $1.frame.maxY) }
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func hideKeyboard() {
        endEditing(true)
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
        
        let testView: UIView = {
            let view = UIView()
            view.backgroundColor = .red
            return view
        }()
        contentView.addSubview(testView)
        testView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tableView!.snp.bottom).inset(-10)
            make.height.equalTo(100)
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
        textField.resignFirstResponder()
        return true
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
            let key = Array(menuItemsArr.keys)[indexPath.row]
            let value = menuItemsArr[key]
            if let c = value {
                label.text = "\(key) - \(c)"
            }
            
            label.font = .systemFont(ofSize: 18, weight: .regular)
            label.textColor = .black
            cell.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(delButton.snp.right).inset(-10)
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
        delegate?.showVC()
    }
    
    @objc func delButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview as? UITableViewCell, let indexPath = tableView?.indexPath(for: cell) else {
            return
        }
        // Удаляем элемент из массива
        let key = Array(menuItemsArr.keys)[indexPath.row]
        menuItemsArr.removeValue(forKey: key)
        print(menuItemsArr)
        
        // Обновляем таблицу
        tableView?.beginUpdates()
        tableView?.deleteRows(at: [indexPath], with: .automatic)
        tableView?.endUpdates()
        
        // Пересчитываем высоту таблицы и обновляем контент внутри скроллвью
        UIView.animate(withDuration: 0.5) {
            self.tableView?.reloadData()
            self.layoutIfNeeded()
            self.tableView?.snp.updateConstraints({ make in
                make.height.equalTo((menuItemsArr.count + 1) * 44)
            })
            self.scrollView.layoutIfNeeded()
            self.tableView?.layoutIfNeeded()
            self.updateContentSize()
        }
    }

}
