//
//  AllOrdersView.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit
import SnapKit
import Alamofire

var selectedParam = "all"

class AllOrdersView: UIView {
    
    var addNewOrderButton: UIButton?
    var collectionView: UICollectionView?
    var delegate: OrderViewControllerDelegate?
    var isScroll = false
    var isLoad = false
    var newOrderStatus: [(Order, OrderStatusResponse)] = []
    var indexPathsToInsertt: [IndexPath] = []
    var indexPathsToUpdatee: [IndexPath] = []
    var previousIndexPath: IndexPath?
    
    var previousScrollOffset: CGFloat = 0
    
    var parametrsCollectionView: UICollectionView?
    let paramArr = [["Все", "all"], ["Активные", "active"] , ["Оплаченные", "paid"],  ["Не оплаченные", "not_paid"], ["Завершенные", "completed"]]

    
    //MARK: -init
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        createInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -func create interface
    
    func createInterface() {
        backgroundColor = .BG
       
        let orderLabel = generateLaels(text: "Заказы", fonc: .systemFont(ofSize: 41, weight: .bold), textColor: .TC)
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
        
        parametrsCollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .BG
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "3")
            collection.delegate = self
            collection.dataSource = self
            collection.showsHorizontalScrollIndicator = false
            collection.layer.cornerRadius = 15
            return collection
        }()
        
        addSubview(parametrsCollectionView!)
        parametrsCollectionView?.snp.makeConstraints({ make in
            make.height.equalTo(30)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(orderLabel.snp.bottom).inset(-10)
        })
        
        collectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collection = UICollectionView(frame: frame, collectionViewLayout: layout)
            layout.minimumLineSpacing = 0
            collection.delegate = self
            collection.showsVerticalScrollIndicator = false
            collection.dataSource = self
            collection.backgroundColor = .BG
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")

            return collection
        }()
        addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.top.equalTo(parametrsCollectionView!.snp.bottom).inset(-10)
        })
    }
    
    func generateLaels(text: String,fonc: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = fonc
        label.textColor = textColor
        return label
    }
}


extension AllOrdersView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

//
//
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return orderStatus.count
        } else {
            return paramArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            
            //MARK: -UI
            
            let imageView: UIImageView = {

                let imageView = UIImageView(image: imageSatandart)
                
                return imageView
            }()
            let viewInImageView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: cell.bounds.height))
            cell.addSubview(viewInImageView)
            viewInImageView.addSubview(imageView)
            imageView.layer.cornerRadius = 25
            imageView.clipsToBounds = true
            
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
            
           
            //MARK: -Labels
            
            let phoneLabel = generateLaels(text: "\(orderStatus[indexPath.row].phone)", fonc: .systemFont(ofSize: 17, weight: .semibold), textColor: .TC)
            cell.addSubview(phoneLabel)
            phoneLabel.snp.makeConstraints { make in
                make.left.equalTo(viewInImageView.snp.right)
                make.top.equalTo(imageView.snp.top)
            }

            let adressLabel = generateLaels(text: "\(orderStatus[indexPath.row].address)", fonc: .systemFont(ofSize: 13.5, weight: .light), textColor: .TC)
            adressLabel.numberOfLines = 2
            
            cell.addSubview(adressLabel)
            adressLabel.snp.makeConstraints { make in
                make.left.equalTo(phoneLabel)
                make.right.equalToSuperview().inset(113)
                make.top.equalTo(phoneLabel.snp.bottom)
            }
            
            let statusLabel = generateLaels(text: "#\(orderStatus[indexPath.row].id)", fonc: .systemFont(ofSize: 13.5, weight: .light), textColor: .TC)
            cell.addSubview(statusLabel)
            statusLabel.snp.makeConstraints { make in
                make.left.equalTo(phoneLabel)
                make.top.equalTo(adressLabel.snp.bottom)
            }
            
            //MARK: -Other elements
            
            let statusImageView: UIImageView = {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFit

                imageView.image = UIImage.backs
                return imageView
            }()
            cell.addSubview(statusImageView)
            statusImageView.snp.makeConstraints { make in
                make.height.equalTo(10)
                make.width.equalTo(16)
                make.centerY.equalTo(statusLabel.snp.centerY)
                make.left.equalTo(statusLabel.snp.right).inset(-5)
            }
            
            
           
           
            
            
            
            
            let inCellButton: UIButton = {
                let button = UIButton(type: .system)
                button.setTitle(orderStatus[indexPath.row].orderForCourierStatus, for: .normal) //меняем
                UIView.animate(withDuration: 0.5) {
                    button.setTitleColor(.systemBlue, for: .normal) //меняем
                    button.backgroundColor = .gray.withAlphaComponent(0.5)

                }
                button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
                button.isUserInteractionEnabled = false
                button.layer.cornerRadius = 10
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
                return button
            }()
            
            
            if orderStatus[indexPath.row].paymentStatus != "Оплачено" /*&& orderStatus[indexPath.row].status != "Готово"*/ {
                statusImageView.image = UIImage.backs
            }
            
            if orderStatus[indexPath.row].paymentStatus == "Оплачено"/* && orderStatus[indexPath.row].status != "Готово"*/ {
                statusImageView.image = UIImage.fillBakc
                
            }
            
            if orderStatus[indexPath.row].status == "Готово" {
                inCellButton.backgroundColor = .systemBlue
                animateButtonWave(for: inCellButton)
                inCellButton.setTitleColor(.white, for: .normal)
            }
            
            if orderStatus[indexPath.row].orderForCourierStatus == nil && (orderStatus[indexPath.row].address != adresCafe && orderStatus[indexPath.row].address != "С собой, 0, самовывоз") && orderStatus[indexPath.row].issued == false {
                inCellButton.setTitle("Вызвать", for: .normal)
            }
            
            if orderStatus[indexPath.row].issued == false && orderStatus[indexPath.row].address == "С собой, 0, Самовывоз" {
                inCellButton.removeTarget(nil, action: nil, for: .allEvents)
                inCellButton.setTitle("Выдать", for: .normal)
                inCellButton.isHidden = false
                inCellButton.isUserInteractionEnabled = true
                inCellButton.tag = indexPath.row
                inCellButton.backgroundColor = UIColor(hex: "#F7F7F7")
                inCellButton.addTarget(self, action: #selector(issued), for: .touchUpInside)
            }
            
            
            
            cell.addSubview(inCellButton)
            inCellButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview().offset(14)
                make.right.equalToSuperview()
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
            let time = orderStatus[indexPath.row].formattedCreatedTime ?? "0:00"
            let timeLabel = generateLaels(text: "\(time)", fonc: .systemFont(ofSize: 15, weight: .regular), textColor: .time)
            
            cell.addSubview(timeLabel)
            timeLabel.snp.makeConstraints { make in
                make.right.equalTo(arrowImageView.snp.left).inset(-8)
                make.centerY.equalTo(phoneLabel)
            }
            
            if inCellButton.titleLabel?.text == "Заказ отменен" || inCellButton.titleLabel?.text == "Отклонен" || inCellButton.titleLabel?.text == "Завершен" || inCellButton.titleLabel?.text == "Заказ выполнен" || orderStatus[indexPath.row].issued == true {
               
                    let filter = CIFilter(name: "CIColorControls")
                    filter?.setValue(CIImage(image: imageView.image!), forKey: kCIInputImageKey)
                    filter?.setValue(0.0, forKey: kCIInputSaturationKey) // Установка насыщенности цвета в ноль
                    let context = CIContext(options: nil)
                    let cgImage = context.createCGImage((filter?.outputImage)!, from: (filter?.outputImage!.extent)!)
                    imageView.image = UIImage(cgImage: cgImage!)
                    phoneLabel.alpha = 0.5
                    adressLabel.alpha = 0.5
                    statusLabel.alpha = 0.5
                    arrowImageView.alpha = 0.5
                    timeLabel.alpha = 0.5
                    inCellButton.alpha = 0
                
            }
            
            
            if inCellButton.titleLabel?.text == "Вызвать" {
                inCellButton.isHidden = false
                inCellButton.isUserInteractionEnabled = true
                inCellButton.tag = indexPath.row
                inCellButton.backgroundColor = UIColor(hex: "#F7F7F7")
                inCellButton.addTarget(self, action: #selector(goCourier(sender:)), for: .touchUpInside)
            }
            
            if inCellButton.titleLabel?.text == "Заказ отменен" || inCellButton.titleLabel?.text == "Заказ выполнен" || inCellButton.titleLabel?.text == "Отклонен" || inCellButton.titleLabel?.text == "Завершен" {
                inCellButton.setTitleColor(.clear, for: .normal)
                inCellButton.backgroundColor = UIColor.clear
                inCellButton.layer.removeAnimation(forKey: "backgroundColorAnimation")
            }
            
           
            
            switch inCellButton.titleLabel?.text {
            case "Ищем курьера":
                inCellButton.isHidden = false
                inCellButton.isUserInteractionEnabled = false
                inCellButton.backgroundColor = UIColor(hex: "#ffff00")
                inCellButton.layer.removeAnimation(forKey: "backgroundColorAnimation")
            case "Курьер назначен":
                inCellButton.isHidden = false
                inCellButton.isUserInteractionEnabled = false
                inCellButton.backgroundColor = UIColor(hex: "#ffb7b7")
                inCellButton.layer.removeAnimation(forKey: "backgroundColorAnimation")
            case "Курьер подъехал":
                inCellButton.isHidden = false
                inCellButton.isUserInteractionEnabled = false
                inCellButton.backgroundColor = UIColor(hex: "#fa00a3")
                inCellButton.layer.removeAnimation(forKey: "backgroundColorAnimation")
            case "В исполнении":
                inCellButton.isHidden = false
                inCellButton.isUserInteractionEnabled = false
                inCellButton.backgroundColor = UIColor(hex: "#a5b307")
                inCellButton.layer.removeAnimation(forKey: "backgroundColorAnimation")
            case .none:
                break
            case .some(_):
                break
            }
            
            if orderStatus[indexPath.row].issued == true {
                inCellButton.isHidden = true
                inCellButton.isUserInteractionEnabled = false
            }
            
           
            
            
           
            if isFirstLoadApp > 1 , indexPathsToInsert.contains(indexPath), page == 1 {
                print(isFirstLoadApp)
                    let greenDot = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
                    greenDot.backgroundColor = .systemGreen
                    greenDot.alpha = 0
                    greenDot.layer.cornerRadius = 7
                    cell.addSubview(greenDot)
                    let newLabel = UILabel()
                    newLabel.text = "new"
                    newLabel.font = .systemFont(ofSize: 11, weight: .regular)
                    newLabel.textColor = .white
                    greenDot.addSubview(newLabel)
                    newLabel.snp.makeConstraints { make in
                        make.centerY.equalToSuperview()
                        make.centerX.equalToSuperview()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        UIView.animate(withDuration: 0.5) {
                                greenDot.alpha = 1
                        }
                    }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    UIView.animate(withDuration: 0.5) {
                        greenDot.alpha = 0
                    }
                }
            }
            
            if indexPathsToUpdate.contains(indexPath) {
                print(isFirstLoadApp)
                let orangeDot = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
                orangeDot.backgroundColor = .systemOrange
                orangeDot.alpha = 0
                orangeDot.layer.cornerRadius = 7
                cell.addSubview(orangeDot)
                let newLabel = UILabel()
                newLabel.text = "edit"
                newLabel.font = .systemFont(ofSize: 11, weight: .regular)
                newLabel.textColor = .white
                orangeDot.addSubview(newLabel)
                newLabel.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.centerX.equalToSuperview()
                }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    UIView.animate(withDuration: 0.5) {
                        orangeDot.alpha = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    UIView.animate(withDuration: 0.5) {
                        orangeDot.alpha = 0
                    }
                }
            }
            
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "3", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.layer.cornerRadius = 15
            cell.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
            
            let label = UILabel()
            label.text = paramArr[indexPath.row][0]
            label.font = .systemFont(ofSize: 15, weight: .regular)
            label.textColor = .black
            cell.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerY.centerX.equalToSuperview()
            }
            
            if selectedParam == paramArr[indexPath.row][1] {
                cell.backgroundColor = .systemBlue
                label.textColor = .white
            } else {
                cell.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
                label.textColor = .black
            }
            
            
//            if selectedParam == i[1] {
//                print(i[1])
//                cell.backgroundColor = .systemBlue
//                label.textColor = .white
//            } else {
//                cell.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
//                label.textColor = .black
//            }
            
            return cell
        }
       
    }
    
   

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Создаем генератор вибрационного отклика
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        if collectionView == self.collectionView {
            delegate?.detailVC(index: indexPath.row)
        } else {
            selectedParam = paramArr[indexPath.row][1]
            print(selectedParam)
            parametrsCollectionView?.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: collectionView.bounds.width, height: 85)
        } else {
            switch indexPath.row {
            case 0:
                return CGSize(width: 50, height: 30)
            case 1:
                return CGSize(width: 92, height: 30)
            case 2:
                return CGSize(width: 121, height: 30)
            case 3:
                return CGSize(width: 131, height: 30)
            case 4:
                return CGSize(width: 131, height: 30)
            default:
                return CGSize(width: 92, height: 30)
            }
        }
        
    }
    
    

    
    func animateButtonWave(for button: UIButton) {
        // Создаем анимацию изменения прозрачности
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = UIColor.systemBlue.withAlphaComponent(0.7).cgColor
        animation.toValue = UIColor.blue.withAlphaComponent(0.2).cgColor
        animation.duration = 1
        animation.autoreverses = true // Позволяет анимации возвращаться к начальному состоянию
        animation.repeatCount = .infinity // Бесконечное повторение

        // Добавляем анимацию на слой кнопки
        button.layer.add(animation, forKey: "backgroundColorAnimation")
    }
    
    //MARK: -change ststus
    
    @objc func goCourier(sender: UIButton) {
       
        let indexPath = IndexPath(row: sender.tag, section: 0)
        print(orderStatus[indexPath.row].id)
        delegate?.createButtonGo(index: indexPath.row) {
            
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
            
            sender.isUserInteractionEnabled = false
            sender.setTitle("Заказ создан", for: .normal)
            UIView.animate(withDuration: 0.2, animations: {
                sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    sender.transform = .identity
                }
            }
            
            
            let originalBackgroundColor = sender.backgroundColor
            sender.backgroundColor = .systemGreen
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.animate(withDuration: 0.5) {
                    sender.backgroundColor = originalBackgroundColor
                }
            }
        } 
    }
    
    
    @objc func issued(sender: UIButton) {
       
        let indexPath = IndexPath(row: sender.tag, section: 0)
        print(orderStatus[indexPath.row].id)
        delegate?.issued(index: indexPath.row) {
            
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
            
            sender.isUserInteractionEnabled = false
            sender.setTitle("Заказ выдан", for: .normal)

        }
    }

    
    
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}



