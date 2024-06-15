//
//  RatingClientViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 25.04.2024.
//

import UIKit
import Alamofire

class RatingClientViewController: UIViewController {

    var clientArr: [(UIImage, String, Int)] = []
    var arrRatingClientResponse: [RatingClient] = []
    var page = 1
    var period = "per_month"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = .red
        getRate {
            self.checkCleints()
        }
        hidesBottomBarWhenPushed = false
        view.backgroundColor = UIColor(hex: "#F2F2F7")
        createInterface()
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.showsVerticalScrollIndicator = false
        table.layer.cornerRadius = 10
        table.register(UITableViewCell.self, forCellReuseIdentifier: "1")
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        return table
    }()
   
    let segmentedControl: UISegmentedControl = {
        let items = ["Этот месяц", "Все время"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 230/255, alpha: 1)
        segmentedControl.selectedSegmentTintColor = .white
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    @objc func segmentedControlValueChanged() {
        clientArr.removeAll()
        arrRatingClientResponse.removeAll()
        page = 1
        if segmentedControl.selectedSegmentIndex == 1 {
            period = "all_time"
        } else {
            period = "per_month"
        }
        getRate {
            self.checkCleints()
        }
    }
    
    func createInterface() {
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = .clear
            button.setTitle("  Рейтинг клиентов", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 30, weight: .semibold)
            button.setTitleColor(.black, for: .normal)
            let image: UIImage = .back
            button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
            button.setImage(image, for: .normal)
            return button
        }()
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.height.equalTo(41)
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(backButton.snp.bottom).inset(-20)
            make.height.equalTo(44)
        }
        
        let whiteView = UIView()
        whiteView.backgroundColor = .white
        view.addSubview(whiteView)
        whiteView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(50)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(segmentedControl.snp.bottom).inset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    
    func getRate(completion: @escaping () -> Void) {
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_rating_clients/?cafe_id=\(cafeID)&period=\(period)&page_size=20&page=\(page)", method: .get, headers: headers).response { response in
            debugPrint(response)
            switch response.result {
            case .success(_):
                do {
                    if let data = response.data {
                        let client = try JSONDecoder().decode(RatingCleintResponse.self, from: data)
                        self.arrRatingClientResponse = client.orders
                    }
                } catch {
                    print("Error decoding JSON:", error)
                }
                completion()
            case .failure(let error):
                print("Request failed with error:", error)
            }
        }
    }


    func checkCleints() {
        guard !allDishes.isEmpty else {
            getRate {
                self.checkCleints()
            }
            return
        }
        for ratingClient in arrRatingClientResponse {
            if !clientArr.contains(where: { $0.1 == ratingClient.phone }) {
                let dishImage: UIImage = imageSatandart ?? UIImage()
                clientArr.append((dishImage, ratingClient.phone, ratingClient.orderCount))
            } else {
                print("Изображение для  '\(ratingClient.phone)' не найдено.")
            }
        }
        tableView.reloadData()
    }

    @objc func goBack() {
        print(1)
        navigationController?.popViewController(animated: true)
    }
    

    
}
 
extension RatingClientViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(clientArr.count, 32423423)
        return clientArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        guard indexPath.row < clientArr.count else {
               return cell // Возвращаем пустую ячейку, если индекс выходит за пределы массива
           }
        cell.separatorInset = .zero
        var image = UIImage()
        image = clientArr[indexPath.row].0
        let imageView = UIImageView(image: image)
        cell.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.width.equalTo(23)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }
        imageView.layer.cornerRadius = 5
        
        let labelName = UILabel()
        labelName.text = "+7\(clientArr[indexPath.row].1)"
        labelName.textColor = .black
        labelName.font = .systemFont(ofSize: 18, weight: .regular)
        cell.addSubview(labelName)
        labelName.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-10)
            make.centerY.equalToSuperview()
        }
        
        let labelCount = UILabel()
        labelCount.text = "\(clientArr[indexPath.row].2) шт"
        labelCount.textColor = .black
        labelCount.font = .systemFont(ofSize: 18, weight: .regular)
        cell.addSubview(labelCount)
        labelCount.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == clientArr.count - 5 {
            page += 1
            getRate {
                self.checkCleints()
            }
        }
    }
}
