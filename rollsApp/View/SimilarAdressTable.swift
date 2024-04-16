//
//  SimilarAdressTable.swift
//  rollsApp
//
//  Created by Владимир Кацап on 10.04.2024.
//

import UIKit
import SnapKit
import Alamofire

class SimilarAdressTable: UIView {
    
    var delelagate: NewOrderViewProtocol?
    var adressArr = [String]()
    var secondDelegate: AdressViewControllerDelegate?
    var editDelegate: EditViewProtocol?
    
    
    var tableView: UITableView?
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        create()
    }
    
    
    
    func reload(address: String) {
        let headers: HTTPHeaders = [.accept("application/json")]

        AF.request("http://arbamarket.ru/api/v1/main/get_similar_addresses/?value=\(address)", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                guard let json = value as? [String: Any] else {
                    print("Invalid JSON format")
                    return
                }
                
                if let value = json["value"] as? String {
                    print("Value:", value)
                } else {
                    print("Value not found")
                }
                
                if let fullAddresses = json["full_addresses"] as? [String] {
                    print("Full addresses:")
                    
                    print(fullAddresses)
                    self.adressArr.removeAll()
                    self.adressArr = fullAddresses
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                    
                } else {
                    print("Full addresses not found")
                }
                
            case .failure(let error):
                print("Request failed with error:", error)
            }
        }
    }
    
    func getCostAdress() {
        let headers: HTTPHeaders = [.accept("application/json")]
        
        var menu = ""

        for (index, (key, value)) in menuItemsArr.enumerated() {
            let count = value.0 // Получаем первое значение типа Int из кортежа
            
            menu.append("\(key) - \(count)")
            
            if index != menuItemsArr.count - 1 {
                menu.append(", ")
            }
        }
        
        AF.request("http://arbamarket.ru/api/v1/main/get_total_cost/?menu=\(menu)&address=\(adress)", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    if let totalCost = json["total_cost"] as? Int,
                       let addressCost = json["address_cost"] as? Int {
                        print("Total cost:", totalCost)
                        print("Address cost:", addressCost)
                        
                        print(adress)
                        DispatchQueue.main.async {
                            self.delelagate?.fillTextField(adress: adress, cost: "\(addressCost)")
                            self.delelagate?.fillButton(coast: "\(totalCost)")
                            
                            self.secondDelegate?.fillTextField(adress: adress)
                            
                            self.delelagate?.updateTable()
                            
                            self.editDelegate?.fillButton(coast: "\(totalCost)")
                            self.editDelegate?.fillTextField(adress: adress, cost: "\(addressCost)")
                            self.editDelegate?.updateTable()
                        }
                    }
                } else {
                    print("Invalid JSON format")
                }
                
            case .failure(let error):
                print("Request failed with error:", error)
            }
        }
    

    }
    
    deinit {
        print("пока%(")
    }
    
    
    @objc func cellTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? UITableViewCell else {
            return
        }
        let indexPath = IndexPath(row: cell.tag, section: 0)
        adress = adressArr[indexPath.row]
        getCostAdress()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func create() {
        layer.cornerRadius = 10
        clipsToBounds = true
        tableView = {
            let table = UITableView()
            table.backgroundColor = .white
            table.dataSource = self
            table.isUserInteractionEnabled = true
            table.delegate = self
            table.register(UITableViewCell.self, forCellReuseIdentifier: "1")
            return table
        }()
        addSubview(tableView!)
        tableView?.snp.makeConstraints({ make in
            make.top.bottom.left.right.equalToSuperview()
        })
        
    }
    
}

extension SimilarAdressTable: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adressArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = adressArr[indexPath.row]
        label.textColor = .black
        cell.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 185/255, green: 185/255, blue: 187/255, alpha: 1)
        cell.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        cell.addGestureRecognizer(tapGestureRecognizer)
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        adress = adressArr[indexPath.row]
        getCostAdress()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        adress = adressArr[indexPath.row]
        getCostAdress()
        return indexPath
    }
}
