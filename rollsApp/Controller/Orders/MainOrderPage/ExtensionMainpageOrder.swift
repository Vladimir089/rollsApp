//
//  ExtensionMainpageOrder.swift
//  rollsApp
//
//  Created by Владимир Кацап on 25.08.2024.
//

import Foundation
import UIKit
import Alamofire
import Kingfisher



extension OrderViewController {
    func hideKB() {
        alertController?.textFields?[0].resignFirstResponder()
        alertController?.textFields?[1].resignFirstResponder()
        alertController?.textFields?[2].resignFirstResponder()
        alertController?.textFields?[3].resignFirstResponder()
        view.endEditing(true)
        timeTextField?.resignFirstResponder()
        view.resignFirstResponder()
    }
}
 

extension OrderViewController: OrderViewControllerDelegate {
 
    func close() {
        isOpen = false
    }
    
    func detailVC(index: Int) {
        if let existingDetailVC = navigationController?.viewControllers.first(where: { $0 is EditViewController }) as? EditViewController {
            if let indexToRemove = navigationController?.viewControllers.firstIndex(of: existingDetailVC) {
                navigationController?.viewControllers.remove(at: indexToRemove)
            }
        }

        let vc = EditViewController()
        vc.delegate = self
        vc.indexOne = index
        let backItem = UIBarButtonItem()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 17),
            .foregroundColor: UIColor.black
        ]
        backItem.title = "Заказ №\(orderStatus[index].id)"
        backItem.setTitleTextAttributes(attributes, for: .normal)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        self.refreshControl.endRefreshing()

        if let splitVC = self.splitViewController {
            menuItemsArr.removeAll()
            menuItemIndex.removeAll()
            adress = ""
            totalCoast = 0
            let detailNavController = UINavigationController(rootViewController: vc)
            splitVC.showDetailViewController(detailNavController, sender: nil)
        } else {
            isLoad = true
            isOpen = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
   
    @objc func hideAlert() {
        view.resignFirstResponder()
        if let alertController = alertController {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func doneButtonTapped() {
        textFieldORTimeButtonsTapped()
        // Форматирование выбранного времени
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let selectedTime = dateFormatter.string(from: timePicker.date)
        
        // Установка выбранного времени в текстовое поле
        timeTextField?.text = selectedTime
        
        let dateFormatterTwo = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // Форматируем дату и выводим её
        let formattedTimeTwo = dateFormatter.string(from: timePicker.date)
        selectTime = formattedTimeTwo
        
        selectedTimeforButText = "Время"
        
        // Закрытие пикера
        timeTextField?.resignFirstResponder()
    }
        
    
    
    @objc func callCourier(index: Int, completion: @escaping () -> Void) {
        
        
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        if orderStatus.count < index {
            return
        }
        let currentOrder = orderStatus[index]
     
        //completion()
        
        
        if selectedTimeforButText == "Время" , selectTime != nil {

            let timeE = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let formattedTime = dateFormatter.string(from: timeE)
            let time:String = selectTime ?? formattedTime
            print(time)
            AF.request("http://arbamarket.ru/api/v1/delivery/create_order/?order_id=\(currentOrder.id)&cafe_id=\(currentOrder.cafeID)&predict_time_order=\(time)", method: .post, headers: headers).responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response)
                case .failure(_):
                    print(1)
                }
            }
            completion()
            hideAlert()
        } else {
            AF.request("http://arbamarket.ru/api/v1/delivery/create_order/?order_id=\(currentOrder.id)&cafe_id=\(currentOrder.cafeID)", method: .post, headers: headers).responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response)
                case .failure(_):
                    print(1)
                }
            }
            completion()
            hideAlert()
        }
        
        
    }
    
    
    
    
    func createButtonGo(index: Int, completion: @escaping () -> Void) {
        
        fillArrButtoms()
        selectTime = nil
        selectedTimeforButText = "Сейчас"
      
        if orderStatus.count < index {
            return
        }
        let currentOrder = orderStatus[index]
        print(currentOrder.id, 324)
        
        let messageText = "Вызвать курьера на адрес \(currentOrder.address) ?"
        //let attributedString = NSMutableAttributedString(string: messageText)

        let boldAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        let range = (messageText as NSString).range(of: currentOrder.address)
//       attributedString.addAttributes(boldAttribute, range: range)
        
        alertController = UIAlertController(title: "адресадрес", message: "", preferredStyle: .alert)
        

        let action1 = UIAlertAction(title: "Отмена", style: .destructive) { _ in
            return
        }
        alertController?.addTextField()
        alertController?.addTextField()
        alertController?.addTextField()
        alertController?.addTextField()
        alertController?.textFields?[0].isEnabled = false
        alertController?.textFields?[1].isEnabled = false
        alertController?.textFields?[2].isEnabled = false
        alertController?.textFields?[3].isEnabled = false
        
        
        customView = UIView()
        customView?.backgroundColor = UIColor.white
        customView?.layer.cornerRadius = 20
        
        let label = UILabel()
        let mainText = "Вызвать курьера на адрес "
        let addressText = "\(currentOrder.address)"
        
        let mainFont = UIFont.systemFont(ofSize: 16)
        let addressFont = UIFont.boldSystemFont(ofSize: 16)
        
        let attributedString = NSMutableAttributedString(string: mainText, attributes: [NSAttributedString.Key.font: mainFont])
        let addressAttributedString = NSAttributedString(string: addressText, attributes: [NSAttributedString.Key.font: addressFont])
        attributedString.append(addressAttributedString)
        let questionText = " ?"
        let questionAttributedString = NSAttributedString(string: questionText, attributes: [NSAttributedString.Key.font: mainFont])
        attributedString.append(questionAttributedString)
        label.attributedText = attributedString
        label.textAlignment = .center
        label.numberOfLines  = 0
        label.textColor = .black
        
       

        alertController?.view.addSubview(customView!)
        customView?.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(270)
            make.height.equalTo(260)
        }
        
        
        customView?.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.left.right.equalToSuperview().inset(15)
        }
        

        noTimeButton = {
            let button = UIButton(type: .system)
            button.setTitle("Сейчас", for: .normal)
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 10
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            button.setTitleColor(.white, for: .normal)
            return button
        }()
        customView?.addSubview(noTimeButton!)
        noTimeButton?.snp.makeConstraints({ make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(44)
            make.right.equalTo(customView!.snp.centerX).offset(-7.5)
            make.top.equalTo(label.snp.bottom).inset(-15)
        })
        noTimeButton?.addTarget(self, action: #selector(noTimeButtonTapped), for: .touchUpInside)
        
        timeTextField = {
            let textField = UITextField()
            textField.text = "На Время"
            textField.textColor = .systemBlue
            textField.layer.cornerRadius = 10
            textField.textAlignment = .center
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
            textField.leftViewMode = .always
            textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
            textField.rightViewMode = .always
            textField.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            return textField
        }()
        customView?.addSubview(timeTextField!)
        timeTextField?.snp.makeConstraints({ make in
            make.left.equalTo(customView!.snp.centerX).offset(7.5)
            make.height.equalTo(44)
            make.right.equalToSuperview().inset(15)
            make.top.equalTo(label.snp.bottom).inset(-15)
        })
        timeTextField?.inputView = timePicker

        
        // Создание тулбара с кнопкой "Готово"
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        
        // Назначение тулбара в качестве inputAccessoryView для текстового поля
        timeTextField?.inputAccessoryView = toolbar
        
        
        stackViewAlert = UIStackView(arrangedSubviews: arrButtoms)
        stackViewAlert?.axis = .horizontal
        stackViewAlert?.distribution = .fillEqually
        stackViewAlert?.backgroundColor = .clear
        stackViewAlert?.spacing = 5
        stackViewAlert?.alpha  = 1
        stackViewAlert?.isUserInteractionEnabled = true
        customView?.addSubview(stackViewAlert!)
        stackViewAlert?.snp.makeConstraints({ make in
            make.top.equalTo(noTimeButton!.snp.bottom).inset(-15)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(44)
        })
        
        
    
        
        cancelButton = UIButton(type: .system)
        cancelButton?.setTitle("Отмена", for: .normal)
        cancelButton?.backgroundColor = .clear
        cancelButton?.layer.cornerRadius = 12
        cancelButton?.setTitleColor(.systemRed, for: .normal)
        cancelButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        customView?.addSubview(cancelButton!)
        
        
        
        
        
        cancelButton?.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
           // make.top.equalTo(segmentedControlAlert!.snp.bottom).inset(-15)
            make.height.equalTo(53)
            make.right.equalTo(customView!.snp.centerX).offset(-7.5)
            make.bottom.equalToSuperview()
        }
        cancelButton?.addTarget(self, action: #selector(hideAlert), for: .touchUpInside)
        
        okButtn = UIButton(type: .system)
        okButtn?.setTitle("Вызвать", for: .normal)
        okButtn?.tag = index
        okButtn?.backgroundColor = .clear
        okButtn?.layer.cornerRadius = 12
        okButtn?.setTitleColor(.systemBlue, for: .normal)
        okButtn?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        customView?.addSubview(okButtn!)
        okButtn?.snp.makeConstraints({ make in
            make.right.equalToSuperview().inset(15)
            // make.top.equalTo(segmentedControlAlert!.snp.bottom).inset(-15)
            make.height.equalTo(53)
            make.left.equalTo(customView!.snp.centerX).offset(7.5)
            make.bottom.equalToSuperview()
        })
        
        
        let topSep = UIView()
        topSep.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
        customView?.addSubview(topSep)
        topSep.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(okButtn!.snp.top)
        }
        
        let midSep = UIView()
        midSep.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
        customView?.addSubview(midSep)
        midSep.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.top.equalTo(topSep.snp.top)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        okButtn?.addAction(for: .touchUpInside) { [weak self] _ in
            self?.callCourier(index: index, completion: {
                completion()
                //print(234)
            })
            //completion()
            //print(2322224)
        }
        alertController?.addAction(action1)
        
        present(alertController!, animated: true,completion: {
            self.hideKB()

        })
        hideKB()
    }
    
   
    
    
    
    func issued(index: Int, completion: @escaping () -> Void) {
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        if orderStatus.count < index {
            return
        }
        let currentOrder = orderStatus[index]

        AF.request("http://arbamarket.ru/api/v1/main/change_issued_filed/?cafe_id=\(currentOrder.cafeID)&order_id=\(currentOrder.id)", method: .post, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                print(response)
            case .failure(_):
                print(1)
            }
        }
        completion()
    }
}














typealias UIButtonTargetClosure = (UIButton) -> ()

class ClosureSleeve {
    let closure: UIButtonTargetClosure

    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }

    @objc func invoke(_ sender: UIButton) {
        closure(sender)
    }
}

extension UIButton {
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }

    private var targetClosure: ClosureSleeve? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureSleeve
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func addAction(for controlEvents: UIControl.Event, _ closure: @escaping UIButtonTargetClosure) {
        let sleeve = ClosureSleeve(closure)
        targetClosure = sleeve
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
    }
}
