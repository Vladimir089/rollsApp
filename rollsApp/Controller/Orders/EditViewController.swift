//
//  EditViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 16.04.2024.
//

import UIKit
import Alamofire

protocol EditViewControllerDelegate: AnyObject {
    func showVC()
    func getLastAdress(phoneNumber: String, cafeID: String, completion: @escaping (String) -> Void)
    func updateOrder(phonee: String, menuItems: String, clientsNumber: Int, adress: String, totalCost: Int, paymentMethod: String, timeOrder: String, cafeID: Int, orderId: Int, completion: @escaping (Bool) -> Void)
    func succesCreate()
    func showAdressVC()
    func cell()
    func changePaymentStatus()
    
    func startTimer()
    func stopTimer()
    func resetTimer()
}

class EditViewController: UIViewController {
    
    var delegate: OrderViewControllerDelegate?
    var indexOne = 0
    
    var inactivityTimer: Timer?
    
    var mainView: EditView?
    
    override func loadView() {
        mainView = EditView()
        self.view = mainView
        mainView?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(orderStatus[indexOne])
        mainView?.index = indexOne
        navigationController?.navigationBar.barTintColor = .white
        let image: UIImage = imageSatandart ?? UIImage()
        let imageView = UIImageView(image: image.resize(targetSize: CGSize(width: 30, height: 30)))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleAspectFit
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        customView.addSubview(imageView)

        imageView.frame = customView.bounds
        self.navigationItem.titleView = customView // Устанавливаем customView как заголовок

        // Создаем кнопку Редактировать/Сохранить
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Редактировать", style: .plain, target: self, action: #selector(toggleEditSave))
        mainView?.phoneTextField?.isUserInteractionEnabled = false
        mainView?.adressTextField?.isUserInteractionEnabled = false
        mainView?.commentTextField?.isUserInteractionEnabled = false
        mainView?.oplataSegmentedControl?.isUserInteractionEnabled = false
        mainView?.addButton?.isUserInteractionEnabled = false
        
        if let splitVC = self.splitViewController {
            startInactivityTimer()
        }
        // Подписка на уведомления о взаимодействиях
        NotificationCenter.default.addObserver(self, selector: #selector(resetInactivityTimer), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetInactivityTimer), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetInactivityTimer), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func startInactivityTimer() {
        // Сброс предыдущего таймера, если он существует
        inactivityTimer?.invalidate()
        
        // Запуск нового таймера на 1 минуту (60 секунд)
        inactivityTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(handleInactivity), userInfo: nil, repeats: false)
    }
    
    @objc func handleInactivity() {
        if let splitVC = self.splitViewController {
            let newNavController = UINavigationController(rootViewController: lottieVC)
            splitVC.showDetailViewController(newNavController, sender: nil)
            lottieVC.changeInterface(named: "wait")
        }
        print("Прошла минута без активности")
    }
    

    
    @objc func resetInactivityTimer() {
        print("Активность обнаружена, сброс таймера")
        print(123)
        startInactivityTimer()
    }
    
    // Отслеживание других событий взаимодействия (например, свайпы)
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        resetInactivityTimer()
    }
    
    
    
    
    

    // Метод, который будет вызываться при нажатии на кнопку Редактировать/Сохранить
    @objc func toggleEditSave() {
           if self.navigationItem.rightBarButtonItem?.title == "Редактировать" {
               stopTimer()
               UIView.animate(withDuration: 0.5) { [self] in
                   
                   
                   mainView?.oplataSegmentedControl?.isUserInteractionEnabled = true
                   mainView?.addButton?.isUserInteractionEnabled = true
                   mainView?.isEdit = 2
                   
                   mainView?.tableView?.snp.updateConstraints({ make in
                       make.height.equalTo((menuItemsArr.count + 1) * 44)
                   })
                   
                   mainView?.phoneTextField?.isUserInteractionEnabled = true
                   mainView?.adressTextField?.isUserInteractionEnabled = true
                   mainView?.commentTextField?.isUserInteractionEnabled = true
                   mainView?.callButtonPhone?.alpha = 0
                   
                   mainView?.layoutIfNeeded()
                   mainView?.scrollView.layoutIfNeeded()
                   mainView?.tableView?.reloadData()
               }
               mainView?.checkEdit()
               self.navigationItem.rightBarButtonItem?.title = "Сохранить"
           } else {
               UIView.animate(withDuration: 0.5) { [self] in
                   mainView?.oplataSegmentedControl?.isUserInteractionEnabled = false
                   mainView?.addButton?.isUserInteractionEnabled = false
                   mainView?.isEdit = 1
                   mainView?.callButtonPhone?.alpha = 1
                   
                   mainView?.tableView?.snp.updateConstraints({ make in
                       make.height.equalTo((menuItemsArr.count) * 44)
                   })
                   
                   mainView?.phoneTextField?.isUserInteractionEnabled = false
                   mainView?.adressTextField?.isUserInteractionEnabled = false
                   mainView?.commentTextField?.isUserInteractionEnabled = false
                   
                   mainView?.layoutIfNeeded()
                   mainView?.scrollView.layoutIfNeeded()
                   mainView?.tableView?.reloadData()
               }
               mainView?.checkEdit()
               self.navigationItem.rightBarButtonItem?.title = "Редактировать"
               mainView?.saveOrder()
           }
       
       }
    
    func cleanывString(_ string: String) -> String {
        // Удаление пробелов
        let noSpaces = string.replacingOccurrences(of: " ", with: "")
        // Удаление скобок
        let cleanString = noSpaces.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        return cleanString
    }

    deinit {
        if UIDevice.current.userInterfaceIdiom != .pad {
            print("dfsdfsdfsdfs")
            menuItemsArr.removeAll()
            menuItemIndex.removeAll()
            adress = ""
            totalCoast = 0
        } else {
            inactivityTimer?.invalidate()
            NotificationCenter.default.removeObserver(self)
        }
        
    }
}

extension EditViewController: EditViewControllerDelegate {
    func resetTimer() {
        if self.navigationItem.rightBarButtonItem?.title == "Редактировать" {
            startInactivityTimer()
            print(123)
        }
    }
    
    
    
    
    
    
    
    func startTimer() {
        if let splitVC = self.splitViewController {
            startInactivityTimer()
        }
    }
    
    func stopTimer() {
        inactivityTimer?.invalidate()
    }
    
    
    
    func changePaymentStatus() {
        
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/change_payment_status/?cafe_id=\(cafeID)&pk=\(orderStatus[indexOne].id)", method: .post, headers: headers).response { response in
            switch response.result {
            case .success(_):
                orderStatus[self.indexOne].paymentStatus = "Оплачено"
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                        self.mainView?.createOrderButton?.alpha = 0
                    }
                }
            case .failure(_):
                print(2)
            }
        }
    }
    
    
    func cell() {
        let phoneNumber: String = mainView?.phoneTextField?.text ?? ""

        if let url = URL(string: "tel://\(phoneNumber)") {
            print(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Не удалось сформировать url")
        }
    }
    
    func showAdressVC() {
        
        
      
        
        
        let vc = AdressViewController()
        vc.similadAdressView = mainView?.similadAdressView
        vc.adress = self.mainView?.adressTextField?.text ?? ""
        present(vc, animated: true)
    }
    
    func succesCreate() {
        UIView.animate(withDuration: 0.5) { [self] in
            mainView?.oplataSegmentedControl?.isUserInteractionEnabled = false
            mainView?.addButton?.isUserInteractionEnabled = false
            mainView?.isEdit = 1
            mainView?.callButtonPhone?.alpha = 1
            
            mainView?.tableView?.snp.updateConstraints({ make in
                make.height.equalTo((menuItemsArr.count) * 44)
            })
            
            mainView?.phoneTextField?.isUserInteractionEnabled = false
            mainView?.adressTextField?.isUserInteractionEnabled = false
            mainView?.commentTextField?.isUserInteractionEnabled = false
            
            mainView?.layoutIfNeeded()
            mainView?.scrollView.layoutIfNeeded()
            mainView?.tableView?.reloadData()
        }
        mainView?.checkEdit()
        self.navigationItem.rightBarButtonItem?.title = "Редактировать"
        startTimer()
    }
    
    
    func getLastAdress(phoneNumber: String, cafeID: String, completion: @escaping (String) -> Void) {
        var a = ""

        // Очистка строк от пробелов и скобок
        let cleanPhoneNumber = phoneNumber
        let cleanCafeID = cafeID

        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_last_address/?phone_number=\(cleanPhoneNumber)&cafe_id=\(cleanCafeID)", method: .get, headers: headers).responseJSON { response in
            debugPrint(response)
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let address = json["address"] as? [String: Any],
                   let addressValue = address["address"] as? String {
                a = addressValue
                }
            case .failure(_):
                a = ""
            }
            completion(a)
        }
    }

    
    func showVC() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let vc = DishesMenuViewControllerController()
            vc.coast = mainView?.similadAdressView
            vc.delegateEdit = self.mainView
            delegate?.openSplitEdit(vc: self) //ЭТО НЕПОНЯТНО ЧТО
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = DishesMenuViewControllerController()
            vc.coast = mainView?.similadAdressView
            vc.delegateEdit = self.mainView
            self.present(vc, animated: true)
        }
    
    }
    
    
    func updateOrder(phonee: String, menuItems: String, clientsNumber: Int, adress: String, totalCost: Int, paymentMethod: String, timeOrder: String, cafeID: Int, orderId: Int, completion: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            HTTPHeader.accept("application/json"),
            HTTPHeader.contentType("application/json"),
            HTTPHeader.authorization(bearerToken: authKey)
        ]
        
        let parameters: [String : Any] = [
            "phone": phonee,
            "menu_items": menuItems,
            "clients_number": clientsNumber,
            "address": adress,
            "total_cost": totalCost,
            "payment_method": paymentMethod,
            //"order_on_time": timeOrder,  // к определенному времени
            "cafe_id": cafeID
        ]
        AF.request("http://arbamarket.ru/api/v1/main/edit_order/\(orderId)/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            debugPrint(response)
            switch response.result {
            case .success(_):
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }

    
    
    
}
