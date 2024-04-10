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
    
    var tableView: UITableView?
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        create()
    }
    
    
    
    func reload(address: String) {
        let headers: HTTPHeaders = [.accept("application/json")]
        adressArr.removeAll()
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
        AF.request("http://arbamarket.ru/api/v1/main/get_total_cost/?menu=1&address=\(adress)", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let totalCost = json["address_cost"] as? Double {
                    print(totalCost)
                    self.delelagate?.fillTextField(adress: adress, cost: "\(totalCost)")
                }
            case .failure(let error):
                print("Request failed with error:", error)
            }
        }
    }
    
    
    @objc func cellTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? UITableViewCell else {
            return
        }
        print(1)
        let indexPath = IndexPath(row: cell.tag, section: 0)
        print("vfcc \(adressArr)")
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
        print(1)
        getCostAdress()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        adress = adressArr[indexPath.row]
        print(1)
        getCostAdress()
        return indexPath
    }
}
