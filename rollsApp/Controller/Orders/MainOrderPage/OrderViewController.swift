import UIKit
import Alamofire
import Kingfisher

var isFirstLoadApp = 0
var dishLoad = false

var indexPathsToInsert: [IndexPath] = []
var indexPathsToUpdate: [IndexPath] = []

protocol OrderViewControllerDelegate: AnyObject {
    func createButtonGo(index: Int, completion: @escaping () -> Void)
    func detailVC(index: Int)
    func close()
    func issued(index: Int, completion: @escaping () -> Void)
}

class OrderViewController: UIViewController {
    
    var mainView: AllOrdersView?
    var isFirstLoad = true
    var newOrderStatus: [(Order, OrderStatusResponse)] = []
    var authCheckTimer: Timer?
    var isLoad = false
    let queue = DispatchQueue(label: "Timer")
    var isOpen = false
    var isWorkCicle = false
    var refreshControl = UIRefreshControl()
    
    //alert
    var alertController: UIAlertController?
    var customView: UIView?


    var stackViewAlert: UIStackView?
    var cancelButton, okButtn: UIButton?
    var arrButtoms: [UIButton] = []
    var selectedTimeforButText = "Сейчас"
    
    
    let arrTextBut = [15,20,30,40]
    var noTimeButton: UIButton?
    var timeTextField: UITextField?
    var selectTime: String?
    
    var isLoadView = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleInactivity()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView = AllOrdersView()
        self.view = mainView
        mainView?.addNewOrderButton?.addTarget(self, action: #selector(newOrder), for: .touchUpInside)
        mainView?.delegate = self
        setupRefreshControl()
        startAuthCheckTimer()
        handleInactivity()
        isLoadView = true
    }
    
    @objc func handleInactivity() {
        if let splitVC = self.splitViewController {
            let newNavController = lottieVC
            splitVC.showDetailViewController(newNavController, sender: nil)
            lottieVC.changeInterface(named: "wait")
        }
        print("Прошла минута без активности")
    }
    
    func fillArrButtoms() {
        arrButtoms.removeAll()
        let arr = [15,20,30,40]
        var t = 0
        for i in arr {
            let button = UIButton(type: .system)
            button.tag = t
            button.setTitle("\(i)", for: .normal)
            button.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
            button.layer.cornerRadius = 10
            button.setTitleColor(.systemBlue, for: .normal)
            button.addTarget(self, action: #selector(buttonAlertTap(sender:)), for: .touchUpInside)
            arrButtoms.append(button)
            t += 1
        }
    }
    
    @objc func buttonAlertTap(sender: UIButton) {
        for i in arrButtoms {
            i.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            i.setTitleColor(.systemBlue, for: .normal)
            i.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        }
        
        
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .normal)
        sender.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        
       
        selectedTimeforButText = "Время"
        textFieldORTimeButtonsTapped()
        
       
        let time = Date()

        
        
        let timeWithAddedMinutes = time.addingTimeInterval(TimeInterval(arrTextBut[sender.tag] * 60))

        // Создаем DateFormatter и устанавливаем нужный формат
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // Форматируем дату и выводим её
        let formattedTime = dateFormatter.string(from: timeWithAddedMinutes)
        selectTime = formattedTime
        formatTime(time: timeWithAddedMinutes)
        
        
        
    }
    
    @objc func noTimeButtonTapped() {
        selectedTimeforButText = "Сейчас"
        noTimeButton!.backgroundColor = .systemBlue
        noTimeButton!.setTitleColor(.white, for: .normal)
        noTimeButton!.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        for i in arrButtoms {
            i.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            i.setTitleColor(.systemBlue, for: .normal)
            i.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        }
        timeTextField?.text = "На Время"
        selectTime = nil
        timeTextField?.layer.borderColor = UIColor.clear.cgColor
        timeTextField?.layer.borderWidth = 0
        timeTextField?.resignFirstResponder()
    }
    
    
    func formatTime(time: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let formattedTime = dateFormatter.string(from: time)
        timeTextField?.text = formattedTime
    }
    
    
    func textFieldORTimeButtonsTapped() {
        noTimeButton?.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        noTimeButton?.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        noTimeButton!.setTitleColor(.systemBlue, for: .normal)
        timeTextField?.layer.borderColor = UIColor.systemBlue.cgColor
        timeTextField?.layer.borderWidth = 1
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isOpen = false
    }
    
    func setupRefreshControl() {
        mainView?.collectionView?.refreshControl = refreshControl
    }
    
    @objc func refreshData() {
        refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func newOrder() {
        
        if let existingDetailVC = navigationController?.viewControllers.first(where: { $0 is NewOrderViewController }) as? NewOrderViewController {
            if let indexToRemove = navigationController?.viewControllers.firstIndex(of: existingDetailVC) {
                navigationController?.viewControllers.remove(at: indexToRemove)
            }
        }
        
        
        let vc = NewOrderViewController()
        vc.isModal = true
        vc.delegate = self
       
        
        if let splitVC = self.splitViewController {
            menuItemsArr.removeAll()
            menuItemIndex.removeAll()
            adress = ""
            totalCoast = 0
            vc.isMediumPage = true
            let newNavController = UINavigationController(rootViewController: vc)
            splitVC.showDetailViewController(newNavController, sender: nil)
           
        } else {
            isLoad = true
            isOpen = true
            self.present(vc, animated: true)
        }

    }
    
    func stopAuthCheckTimer() {
        authCheckTimer?.invalidate()
        authCheckTimer = nil
    }
    
    func startAuthCheckTimer() {
        authCheckTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkAuthKey), userInfo: nil, repeats: true)
    }
    
    @objc func checkAuthKey() {
        if !authKey.isEmpty {
            stopAuthCheckTimer()
            reload()
            getDishes() {
                NotificationCenter.default.post(name: Notification.Name("dishLoadNotification"), object: nil)
                dishLoad = true
            }
        }
    }
    
    func reload() {
        self.mainView?.collectionView?.reloadData()
        regenerateTable() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.reload()
            }
        }
    }
    
    func getDishes(completion: @escaping () -> Void) {
        allDishes.removeAll()
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("application/json")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_dishes/?cafe_id=\(cafeID)", method: .get, headers: headers).responseData { response in
            
            switch response.result {
            case .success(_):
                if let data = response.data, let dishes = try? JSONDecoder().decode(DishesResponse.self, from: data) {
                    let dispatchGroup = DispatchGroup()
                    
                    for i in dishes.dishes {
                        dispatchGroup.enter()
                        self.getImage(d: i) {
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion()
                    }
                }
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }

    func getImage(d: Dish, completion: @escaping () -> Void) {
        if let url = d.img {
            
            KingfisherManager.shared.retrieveImage(with: URL(string: "http://arbamarket.ru\(url)")!) { response in
                switch response {
                case .success(let image):
                    allDishes.append((d, image.image))
                    print(d, "ok")
                case .failure(let error):
                    allDishes.append((d, imageSatandart ?? UIImage()))
                    print(d, "fail")
                }
                completion()
            }
        } else {
            completion()
        }
    }
    
    deinit {
        stopAuthCheckTimer()
    }
    
    
    
    
    
    
    
}

