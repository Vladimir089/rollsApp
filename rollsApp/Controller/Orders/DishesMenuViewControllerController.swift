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
    var categoryStorage = [String]()
    var coast: SimilarAdressTable?
    var delegate: NewOrderViewProtocol?
    var delegateEdit: EditViewProtocol?
    var botView: UIView?
    var arrBot: [UIImage]?
    var oneViewForBot, twoViewForBot, threeViewForBot: UIImageView?
    var labelSumm: UILabel?
    
    var loadView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    var prorgessActivityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        return view
    }()

    
    //MARK: -viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createMenu()
        settingsView()
        if dishLoad == false {
            NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: Notification.Name("dishLoadNotification"), object: nil)
        } else {
            updateTable()
        }
        setBlurredBackground()
        
    }
    
    @objc func updateTable() {
        
        self.collectionView?.reloadData()
        self.prorgessActivityIndicator.stopAnimating()
        self.loadView.alpha = 0
        
    }
    
    //MARK: -create interface func
    
    
    func setBlurredBackground() {
        // Создание эффекта размытия
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // Устанавливаем размеры эффекта размытия на весь экран
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Добавляем эффект размытия на основной view
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
        
        // Устанавливаем белый фон с прозрачностью для основного view
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    }
    
    func createMenu() {

       
        
        let hideView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(red: 98/255, green: 119/255, blue: 128/255, alpha: 1)
            view.layer.cornerRadius = 1
            return view
        }()
        
        view.addSubview(hideView)
        hideView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.width.equalTo(55)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }
        
        collectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .clear
            collection.showsVerticalScrollIndicator = false
            collection.delegate = self
            collection.dataSource = self
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            collection.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
            collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0) // Добавляем пространство снизу
            return collection
        }()
        
        view.addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ make in
            make.left.right.bottom.equalToSuperview().inset(10)
            make.top.equalTo(hideView.snp.bottom).inset(-5)
        })
        
        botView = {
            let view = UIView()
            view.backgroundColor = UIColor(hex: "#C6C6C8")
            view.alpha = 0
            view.layer.cornerRadius = 30
            view.clipsToBounds = true
            return view
        }()
        view.addSubview(botView ?? UIView())
        botView?.snp.makeConstraints({ make in
            make.height.equalTo(60)
            make.width.equalTo(180)
            make.bottom.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
        })
        
        let gestureHideVC = UITapGestureRecognizer(target: self, action: #selector(hideVC))
        botView?.addGestureRecognizer(gestureHideVC)
        
        oneViewForBot = generateImageView()
        botView?.addSubview(oneViewForBot ?? UIView())
        oneViewForBot?.snp.makeConstraints({ make in
            make.height.width.equalTo(60)
            make.right.equalToSuperview().inset(1)
            make.centerY.equalToSuperview()
        })
        
        twoViewForBot = generateImageView()
        botView?.addSubview(twoViewForBot ?? UIView())
        twoViewForBot?.snp.makeConstraints({ make in
            make.height.width.equalTo(60)
            make.right.equalTo((oneViewForBot?.snp.left)!).inset(30)
            make.centerY.equalToSuperview()
        })
        
        threeViewForBot = generateImageView()
        botView?.addSubview(threeViewForBot ?? UIView())
        threeViewForBot?.snp.makeConstraints({ make in
            make.height.width.equalTo(60)
            make.right.equalTo((twoViewForBot?.snp.left)!).inset(30)
            make.centerY.equalToSuperview()
        })
        
        labelSumm = {
            let label = UILabel()
            var summ = 0
            for i in menuItemsArr {
                summ += i.1.1
                label.text = "\(summ) ₽"
            }
            label.font = .systemFont(ofSize: 26, weight: .bold)
            label.textColor = .black
            return label
        }()
        
        botView?.addSubview(labelSumm ?? UILabel())
        labelSumm?.snp.makeConstraints({ make in
            make.left.equalToSuperview().inset(25)
            make.centerY.equalToSuperview()
        })
        
        view.addSubview(loadView)
        loadView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        loadView.addSubview(prorgessActivityIndicator)
        prorgessActivityIndicator.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        prorgessActivityIndicator.startAnimating()
        
        settingsView()
    }
    
    func generateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }
    
    func settingsView() {
        var summ = 0
        for i in menuItemsArr {
            summ += i.1.1
            labelSumm?.text = "\(summ) ₽"
        }
        if !menuItemsArr.isEmpty {
            let index = menuItemsArr.count
            
            for i in 0..<allDishes.count {
                UIView.animate(withDuration: 0.5) { [self] in
                    
                    if menuItemsArr.count > 3 {
                        botView?.snp.updateConstraints({ make in
                            make.width.equalTo(240)
                        })
                        view.layoutIfNeeded()
                    }
                    
                    if menuItemsArr.count == 3  {
                        print(1123123)
                        botView?.alpha = 0.9
                        self.oneViewForBot?.alpha = 100
                        self.twoViewForBot?.alpha = 100
                        self.threeViewForBot?.alpha = 100
                        if allDishes[i].0.name == menuItemsArr[index - 3].0 {
                            self.oneViewForBot?.image = allDishes[i].1
                        }
                        if allDishes[i].0.name == menuItemsArr[index - 2].0 {
                            self.twoViewForBot?.image = allDishes[i].1
                        }
                        if allDishes[i].0.name == menuItemsArr[index - 1].0 {
                            self.threeViewForBot?.image = allDishes[i].1
                        }
                        botView?.snp.updateConstraints({ make in
                            make.width.equalTo(240)
                        })
                        view.layoutIfNeeded()
                        return
                    }
                    
                    if menuItemsArr.count == 2  {
                        botView?.alpha = 0.9
                        self.threeViewForBot?.alpha = 0
                        self.twoViewForBot?.alpha = 100
                        if allDishes[i].0.name == menuItemsArr[index - 2].0 {
                            self.oneViewForBot?.image = allDishes[i].1
                        }
                        if allDishes[i].0.name == menuItemsArr[menuItemsArr.count - 1].0 {
                            self.twoViewForBot?.image = allDishes[i].1
                        }
                        botView?.snp.updateConstraints({ make in
                            make.width.equalTo(210)
                        })
                        view.layoutIfNeeded()
                        return
                    }
                    
                    if menuItemsArr.count == 1  {
                        botView?.alpha = 0.9
                        
                        self.twoViewForBot?.alpha = 0
                        self.threeViewForBot?.alpha = 0
                        if allDishes[i].0.name == menuItemsArr[index - 1].0 {
                            self.oneViewForBot?.image = allDishes[i].1
                        }
                        
                        return
                    }
                    
                    if menuItemsArr.count > 0 {
                        
                        botView?.alpha = 0.9
                        if allDishes[i].0.name == menuItemsArr[menuItemsArr.count - 1].0 {
                            UIView.transition(with: threeViewForBot!, duration: 0.2, options: .transitionFlipFromRight, animations: {
                                self.threeViewForBot?.image = allDishes[i].1
                            }, completion: nil)
                        }
                        if allDishes[i].0.name == menuItemsArr[index - 2].0 {
                            UIView.transition(with: twoViewForBot!, duration: 0.2, options: .transitionFlipFromRight, animations: {
                                self.twoViewForBot?.image = allDishes[i].1
                            }, completion: nil)
                        }
                        if allDishes[i].0.name == menuItemsArr[index - 3].0 {
                            UIView.transition(with: oneViewForBot!, duration: 0.2, options: .transitionFlipFromRight, animations: {
                                self.oneViewForBot?.image = allDishes[i].1
                            }, completion: nil)
                        }
                    }
                    if menuItemsArr.count == 0 {
                        botView?.alpha = 0
                    }
                }
               
            }
        }
    }
    
    @objc func hideVC() {
        self.dismiss(animated: true)
    }
  
   
    
    //MARK: -start Timer
    
    func startTimerToUpdateMenu() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if allDishes.isEmpty {
                self.collectionView?.reloadData()
            } else {
                self.stopTimer()
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stopTimer() {
        print(234234235345)
        timer?.invalidate()
        timer = nil
        self.collectionView?.reloadData()
    }
    
    @objc func closeVC() {
        stopTimer()
    }
    
    deinit {
        closeVC()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("dishLoadNotification"), object: nil)
            
    }
}

extension DishesMenuViewControllerController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        for i in allDishes {
            let category = i.0.category
            // Проверяем, нет ли уже такой категории в массиве categoryStorage
            if !categoryStorage.contains(category) {
                // Если категории еще нет в массиве, добавляем ее
                categoryStorage.append(category)
            }
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
        cell.backgroundColor = .white.withAlphaComponent(0.1)
        cell.layer.cornerRadius = 12
        
        let categoryForSection = Array(categoryStorage)[indexPath.section]
        let filteredDishes = allDishes.filter { $0.0.category == categoryForSection }
        let dish = filteredDishes[indexPath.item]
        
        
        
        //MAIN
        
        let imageView: UIImageView = {
            let image = dish.1
            let imageView = UIImageView(image: image)
            imageView.layer.cornerRadius = 13
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = .clear
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
            if let itemIndex = menuItemsArr.firstIndex(where: { $0.0 == dish.0.name }) {
                let count = menuItemsArr[itemIndex].1.0
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
            let sortedCategories = Array(categoryStorage).sorted()
            let categoryForSection = sortedCategories[indexPath.section]
            headerView.titleLabel.text = categoryForSection
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = 15 * 5
        let availableWidth = collectionView.frame.width - CGFloat(paddingSpace)
        let widthPerItem = availableWidth / 4
        return CGSize(width: widthPerItem, height: 114)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        let categoryForSection = Array(categoryStorage)[indexPath.section]
        let filteredDishes = allDishes.filter { $0.0.category == categoryForSection }
        let dish = filteredDishes[indexPath.item].0
        
        if let itemIndex = menuItemsArr.firstIndex(where: { $0.0 == dish.name }) {
            var updatedMenuItem = menuItemsArr[itemIndex]
            updatedMenuItem.1.0 += 1
            updatedMenuItem.1.1 += dish.price
            menuItemsArr[itemIndex] = updatedMenuItem
        } else {
            menuItemsArr.append((dish.name, (1, dish.price)))
            
        }
        
        collectionView.reloadItems(at: [indexPath])
        settingsView()
        coast?.getCostAdress()
        delegate?.updateTable()
        delegateEdit?.updateTable()
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


