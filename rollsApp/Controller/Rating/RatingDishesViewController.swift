//
//  RatingDishesViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 24.04.2024.
//

import UIKit
import Alamofire

class RatingDishesViewController: UIViewController {
    
    var dishArr: [(UIImage, String, Int)] = []
    var arrRatingDishesResponse: [RatingDish] = []
    var page = 1
    var period = "per_day"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = .red
        getRate {
            self.checkDishes()
        }
        hidesBottomBarWhenPushed = false
        view.backgroundColor = .settingBG
        createInterface()
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .rating
        table.showsVerticalScrollIndicator = false
        table.layer.cornerRadius = 10
        table.register(UITableViewCell.self, forCellReuseIdentifier: "1")
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        return table
    }()
   
    let segmentedControl: UISegmentedControl = {
        let items = ["За сегодня", "Этот месяц", "Все время"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 230/255, alpha: 1)
        segmentedControl.selectedSegmentTintColor = .white
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    @objc func segmentedControlValueChanged() {
        page = 1
        if segmentedControl.selectedSegmentIndex == 1 {
            period = "per_month"
        } else if segmentedControl.selectedSegmentIndex == 0 {
            period = "per_day"
        } else if segmentedControl.selectedSegmentIndex == 2  {
            period = "all_time"
        }
        getRate {
            self.checkDishes()
        }
    }
    
    func createInterface() {
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = .clear
            button.setTitle("  Рейтинг блюд", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 30, weight: .semibold)
            button.setTitleColor(.TC, for: .normal)
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
        whiteView.backgroundColor = .rating
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
        dishArr.removeAll()
        arrRatingDishesResponse.removeAll()
        
        let headers: HTTPHeaders = [
            HTTPHeader.authorization(bearerToken: authKey),
            HTTPHeader.accept("*/*")
        ]
        
        AF.request("http://arbamarket.ru/api/v1/main/get_rating_dishes/?cafe_id=\(cafeID)&period=\(period)&page_size=20&page=\(page)", method: .get, headers: headers).response { response in
            switch response.result {
            case .success(_):
                if let data = response.data, let dish = try? JSONDecoder().decode(RatingDishesResponse.self, from: data) {
                    self.arrRatingDishesResponse = dish.dishes
                    self.arrRatingDishesResponse.sort(by: { $0.quantity > $1.quantity})
                }
                completion()
            case .failure(_):
                print(1)
            }
        }
    }

    func checkDishes() {
        guard !allDishes.isEmpty else {
            getRate {
                self.checkDishes()
            }
            return
        }
        for ratingDish in arrRatingDishesResponse {
            if !dishArr.contains(where: { $0.1 == ratingDish.name }) {
                if let foundDish = allDishes.first(where: { $0.0.name == ratingDish.name }) {
                    let dishImage = foundDish.1
                    dishArr.append((dishImage, ratingDish.name, ratingDish.quantity))
                    
                } else {
                    print("нет картинки \(ratingDish.name)")
                }
            }
        }
        print(allDishes)
        dishArr.sort(by: {$0.2 > $1.2})
        tableView.reloadData()
    }
    
    @objc func goBack() {
        print(1)
        navigationController?.popViewController(animated: true)
    }
}
 
extension RatingDishesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        guard indexPath.row < dishArr.count else {
               return cell
           }
        
        cell.separatorInset = .zero
        var image = UIImage()
        image = dishArr[indexPath.row].0
        let imageView = UIImageView(image: image)
        cell.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(25)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }
        imageView.layer.cornerRadius = 5
        
        let labelName = UILabel()
        labelName.text = dishArr[indexPath.row].1
        labelName.textColor = .TC
        labelName.font = .systemFont(ofSize: 18, weight: .regular)
        cell.addSubview(labelName)
        labelName.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-10)
            make.centerY.equalToSuperview()
        }
        
        let labelCount = UILabel()
        labelCount.text = "\(dishArr[indexPath.row].2) шт"
        labelCount.textColor = .TC
        labelCount.font = .systemFont(ofSize: 18, weight: .regular)
        cell.addSubview(labelCount)
        labelCount.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dishArr.count - 5 {
            page += 1
            getRate {
                self.checkDishes()
            }
        }
    }
}
