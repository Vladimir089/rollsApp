//
//  RatingDishesViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 24.04.2024.
//

import UIKit

class RatingDishesViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.layer.cornerRadius = 20
        table.register(UITableViewCell.self, forCellReuseIdentifier: "1")
        table.delegate = self
        table.dataSource = self
        return table
    }()
   
    let segmentedControl: UISegmentedControl = {
        let items = ["Этот месяц", "Все время"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 230/255, alpha: 1)
        segmentedControl.selectedSegmentTintColor = .white
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segmentedControl.selectedSegmentIndex = 0
        //segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()

    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRate()
        hidesBottomBarWhenPushed = false
        view.backgroundColor = UIColor(hex: "#F2F2F7")
        createInterface()
        
    }
    
    func createInterface() {
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(100)
            make.height.equalTo(44)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(segmentedControl.snp.bottom).inset(-20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    func getRate() {
        
    }
    

    
}
 
extension RatingDishesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "1", for: indexPath)
        cell.textLabel?.text = "21323"
        return cell
    }
    
    
}
