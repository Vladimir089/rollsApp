//
//  DishesMenuViewControllerController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 09.04.2024.
//

import UIKit


class DishesMenuViewControllerController: UIViewController {
    var timer: Timer?
    var closeButton: UIButton?
    var collectionView: UICollectionView?
    var categoryStorage = Set<String>()
    var coast: SimilarAdressTable?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createMenu()
        startTimerToUpdateMenu()
        
    }
    
    
    func createMenu() {
        view.backgroundColor = .white
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        
        closeButton = {
            let button = UIButton()
            button.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
            button.setImage(UIImage(systemName: "xmark"), for: .normal)
            button.tintColor = UIColor(red: 133/255, green: 133/255, blue: 139/255, alpha: 1)
            button.layer.cornerRadius = 12.5
            button.isHidden = true //кнопка закрытия
            button.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
            return button
        }()
        view.addSubview(closeButton!)
        closeButton?.snp.makeConstraints({ make in
            make.height.width.equalTo(25)
            make.right.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(50)
        })
        
        collectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .white
            collection.delegate = self
            collection.dataSource = self
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            collection.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
            return collection
        }()
        view.addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ make in
            make.left.right.bottom.equalToSuperview().inset(10)
            make.top.equalTo(closeButton!.snp.bottom).inset(-5)
        })
        
        
    }
    
    func startTimerToUpdateMenu() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if allDishes.isEmpty {
                self.collectionView?.reloadData()
            } else {
                self.stopTimer()
                self.collectionView?.reloadData()
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func closeVC() {
        stopTimer()
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            closeVC()
        }
    }  
}


extension DishesMenuViewControllerController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        for i in allDishes {
            categoryStorage.insert(i.0.category)
        }

        
        return categoryStorage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let categoryForSection = Array(categoryStorage)[section]
        let filteredDishes = allDishes.filter { $0.0.category == categoryForSection }
        return filteredDishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .white
        
        let categoryForSection = Array(categoryStorage)[indexPath.section]
        let filteredDishes = allDishes.filter { $0.0.category == categoryForSection }
        let dish = filteredDishes[indexPath.item]
        print(dish.0.category)
        
        //MAIN
        
        let imageView: UIImageView = {
            let image = dish.1
            let imageView = UIImageView(image: image)
            imageView.layer.cornerRadius = 13
            return imageView
        }()
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
        }
        let nameLabel: UILabel = {
            let label = UILabel()
            label.text = dish.0.name
            label.font = .systemFont(ofSize: 12, weight: .regular)
            label.numberOfLines = 2
            label.textColor = .black
            label.textAlignment = .center
            return label
        }()
        cell.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(-2)
        }
        
        
        
        
        let countLabel: UIButton = {
            let button = UIButton()
            if let count = menuItemsArr[dish.0.name]?.0 {
                button.setTitle("\(count)", for: .normal)
                button.isHidden = false
            } else {
                button.isHidden = true
            }

            button.backgroundColor = .systemRed
            button.tintColor = .black
            button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
            button.layer.cornerRadius = 11
            return button
        }()
        cell.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.height.equalTo(22)
            make.width.equalTo(22)
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderView
            let categoryForSection = Array(categoryStorage)[indexPath.section]
            headerView.titleLabel.text = categoryForSection
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30 //вертикальный отступ
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = 15 * 5
        let availableWidth = collectionView.frame.width - CGFloat(paddingSpace)
        let widthPerItem = availableWidth / 4
        return CGSize(width: widthPerItem, height: 114)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Создаем генератор тактильного отклика
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        
        let categoryForSection = Array(categoryStorage)[indexPath.section]
        let filteredDishes = allDishes.filter { $0.0.category == categoryForSection }
        let dish = filteredDishes[indexPath.item].0

        if var menuItem = menuItemsArr[dish.name] {
            menuItem.0 += 1
            menuItem.1 += dish.price
            menuItemsArr[dish.name] = menuItem
        } else {
            menuItemsArr[dish.name] = (1, dish.price)
        }

        collectionView.reloadItems(at: [indexPath])
        
        coast?.getCostAdress()
    }

    
}



class SectionHeaderView: UICollectionReusableView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 133/255, green: 133/255, blue: 139/255, alpha: 1)
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


