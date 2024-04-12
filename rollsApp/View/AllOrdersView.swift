//
//  AllOrdersView.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit
import SnapKit

class AllOrdersView: UIView {
    
    var addNewOrderButton: UIButton?
    var collectionView: UICollectionView?
    var delegate: OrderViewControllerDelegate?
    var greatView: UIView?


    override init(frame: CGRect) {
        super .init(frame: frame)
        createInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createInterface() {
        backgroundColor = .white
       
        let orderLabel: UILabel = {
            let label = UILabel()
            label.text = "Заказы"
            label.font = .systemFont(ofSize: 41, weight: .bold)
            label.textColor = .black
            return label
        }()
        addSubview(orderLabel)
        orderLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(75)
        }
        
        addNewOrderButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 1)
            button.layer.cornerRadius = 10
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.tintColor = .white
            return button
        }()
        addSubview(addNewOrderButton!)
        addNewOrderButton?.snp.makeConstraints({ make in
            make.height.width.equalTo(35)
            make.centerY.equalTo(orderLabel.snp.centerY)
            make.right.equalToSuperview().inset(15)
        })
        
        collectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collection = UICollectionView(frame: frame, collectionViewLayout: layout)
            layout.minimumLineSpacing = 0
            collection.delegate = self
            collection.showsVerticalScrollIndicator = false
            collection.dataSource = self
            collection.backgroundColor = .white
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            return collection
        }()
        addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.top.equalTo((addNewOrderButton?.snp.bottom)!).inset(-40)
        })
        
        greatView = {
            let view = UIView()
            view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            view.alpha = 0
            view.layer.cornerRadius = 20
            return view
        }()
        addSubview(greatView!)
        greatView!.snp.makeConstraints { make in
            make.height.width.equalTo(200)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let image: UIImage = .ok
        let imageView = UIImageView(image: image)
        greatView!.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(120)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }
        
        let label = UILabel()
        label.text = "Заказ добавлен"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        greatView?.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(imageView.snp.bottom).inset(-10)
        }
        
    }
    
    
    func succes() {
        UIView.animate(withDuration: 0.8) {
            self.greatView?.alpha = 100
        }
        
        UIView.animate(withDuration: 0.5, delay: 2.0, options: [], animations: {
            self.greatView?.alpha = 0
        }, completion: nil)
        


    }
    
    
    
}


extension AllOrdersView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderStatus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        //MARK: -UI
        
        let imageView: UIImageView = {
            let image: UIImage = .image //тут меняем картинку
            let imageView = UIImageView(image: image)
            imageView.alpha = 0
            return imageView
        }()
        let viewInImageView = UIView(frame: CGRect(x: 0, y: 0, width: 78, height: cell.bounds.height))
        //viewInImageView.backgroundColor = .red
        cell.addSubview(viewInImageView)
        viewInImageView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().offset(-5)
        }
        
        
        let separatorView: UIView = {
            let view = UIView()
            view.backgroundColor = .separator
            view.alpha = 0
            return view
        }()
        cell.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalTo(viewInImageView.snp.right)
        }
        
        //labels
        
        let phoneLabel: UILabel = {
            let label = UILabel()
            label.text = "\(orderStatus[indexPath.row].0.phone)"  //меняем
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.textColor = .black
            label.alpha = 0
            return label
        }()
        cell.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(viewInImageView.snp.right)
            make.top.equalTo(imageView.snp.top)
        }

        let adressLabel: UILabel = {
            let label = UILabel()
            label.text = "\(orderStatus[indexPath.row].0.address)"     //меняем
            label.font = .systemFont(ofSize: 13.5, weight: .light)
            label.textColor = .black
            label.alpha = 0
            return label
        }()
        
        cell.addSubview(adressLabel)
        adressLabel.snp.makeConstraints { make in
            make.left.equalTo(phoneLabel)
            make.right.equalToSuperview().inset(113)
            make.top.equalTo(phoneLabel.snp.bottom)
        }
        
        let statusLabel: UILabel = {
            let label = UILabel()
            label.text = "\(orderStatus[indexPath.row].0.status)"     //меняем
            label.font = .systemFont(ofSize: 13.5, weight: .light)
            label.textColor = .black
            label.alpha = 0
            return label
        }()
        cell.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.left.right.equalTo(phoneLabel)
            make.top.equalTo(adressLabel.snp.bottom)
        }
        
        let inCellButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle(orderStatus[indexPath.row].1, for: .normal) //меняем
            button.setTitleColor(UIColor(red: 85/255, green: 112/255, blue: 241/255, alpha: 1), for: .normal) //меняем
            button.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
            button.isUserInteractionEnabled = false
            button.layer.cornerRadius = 10
            button.alpha = 0
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            return button
        }()
       
        switch inCellButton.titleLabel?.text {
        case "Вызвать":
            inCellButton.isHidden = false
            inCellButton.isUserInteractionEnabled = true
            inCellButton.setTitleColor(UIColor(red: 85/255, green: 112/255, blue: 241/255, alpha: 1), for: .normal)
            
            inCellButton.tag = indexPath.row
            inCellButton.addTarget(self, action: #selector(goCourier(sender:)), for: .touchUpInside)
        case "В пути":
            inCellButton.isHidden = false
            inCellButton.isUserInteractionEnabled = false
            inCellButton.setTitleColor(UIColor(red: 165/255, green: 179/255, blue: 7/255, alpha: 1), for: .normal)
        case "Подъехал":
            inCellButton.isHidden = false
            inCellButton.isUserInteractionEnabled = false
            inCellButton.setTitleColor(UIColor(red: 250/255, green: 0/255, blue: 2/255, alpha: 1), for: .normal)
        case .none:
            break
        case .some(_):
            break
        }
        cell.addSubview(inCellButton)
        inCellButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(14)
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(44)
            
        }
        
        
        
        let arrowImageView: UIImageView = {
            let image: UIImage = .arrow
            let imageView = UIImageView(image: image)
            imageView.alpha = 0
            return imageView
        }()
        cell.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.width.equalTo(10)
            make.right.equalTo(inCellButton.snp.right)
            make.centerY.equalTo(phoneLabel)
        }
        
        let timeLabel: UILabel = {
            let label = UILabel()
            let time = orderStatus[indexPath.row].0.formattedCreatedTime ?? "0:00"
            label.text = "\(time)"
            label.font = .systemFont(ofSize: 15, weight: .regular)
            label.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.6)
            label.alpha = 0
            return label
        }()
        cell.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(arrowImageView.snp.left).inset(-8)
            make.centerY.equalTo(phoneLabel)
        }
        UIView.animate(withDuration: 0.5) {
            imageView.alpha = 100
            separatorView.alpha = 100
            phoneLabel.alpha = 100
            adressLabel.alpha = 100
            
        }
        UIView.animate(withDuration: 0.3) {
            
            statusLabel.alpha = 100
            inCellButton.alpha = 100
            arrowImageView.alpha = 100
            timeLabel.alpha = 100
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 85)
    }
    
    @objc func goCourier(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        delegate?.createButtonGo(index: indexPath.row)
    }
    
    
}
