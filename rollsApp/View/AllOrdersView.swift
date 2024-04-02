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
    }
    
}


extension AllOrdersView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        //MARK: -UI
        
        let imageView: UIImageView = {
            let image: UIImage = .image //тут меняем картинку
            let imageView = UIImageView(image: image)
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
            label.text = "+798222524966"  //меняем
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.textColor = .black
            return label
        }()
        cell.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(viewInImageView.snp.right)
            make.top.equalTo(imageView.snp.top)
        }
        
        let adressLabel: UILabel = {
            let label = UILabel()
            label.text = "Ленина, 130, Терезе"     //меняем
            label.font = .systemFont(ofSize: 13.5, weight: .light)
            label.textColor = .black
            return label
        }()
        cell.addSubview(adressLabel)
        adressLabel.snp.makeConstraints { make in
            make.left.right.equalTo(phoneLabel)
            make.top.equalTo(phoneLabel.snp.bottom)
        }
        
        let statusLabel: UILabel = {
            let label = UILabel()
            label.text = "Готовится"     //меняем
            label.font = .systemFont(ofSize: 13.5, weight: .light)
            label.textColor = .black
            return label
        }()
        cell.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.left.right.equalTo(phoneLabel)
            make.top.equalTo(adressLabel.snp.bottom)
        }
        
        let inCellButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Вызвать", for: .normal) //меняем
            button.setTitleColor(UIColor(red: 85/255, green: 112/255, blue: 241/255, alpha: 1), for: .normal) //меняем
            button.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
            button.layer.cornerRadius = 10
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            return button
        }()
        cell.addSubview(inCellButton)
        inCellButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(14)
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(44)
            
        }
        
        let arrowImageView: UIImageView = {
            let image: UIImage = .arrow
            let imageView = UIImageView(image: image)
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
            label.text = "9:41 am"  //меняем
            label.font = .systemFont(ofSize: 15, weight: .regular)
            label.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.6)
            return label
        }()
        cell.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(arrowImageView.snp.left).inset(-8)
            make.centerY.equalTo(phoneLabel)
        }
       
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 85)
    }
    
    
}
