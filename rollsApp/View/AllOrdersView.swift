//
//  AllOrdersView.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit
import SnapKit
import Alamofire

class AllOrdersView: UIView {
    
    var addNewOrderButton: UIButton?
    var collectionView: UICollectionView?
    var delegate: OrderViewControllerDelegate?
    var isScroll = false
    var isLoad = false
    var newOrderStatus: [(Order, OrderStatusResponse)] = []
    var indexPathsToInsertt: [IndexPath] = []
    var indexPathsToUpdatee: [IndexPath] = []
    

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
            make.top.equalTo(orderLabel.snp.bottom).inset(-10)
        })

    }
    
    func autoincrement() {
        page += 1
    }
    
    
    


    

   
    
}


extension AllOrdersView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
   

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        
        if indexPath.row + 1 == orderStatus.count  {
            page += 1
            print("DKDJKDKDKKDKDDKDDDDD")
            
        } else if (indexPath.row % 12 == 0 && indexPath.row != 0) && (indexPath.row + 1 != orderStatus.count) {
            page -= 1
            print("IRIRIRRIIRIRIIRIRIRIIRIRI")
        }
        
       
    }

    
    
    
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
            
            return imageView
        }()
        let viewInImageView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: cell.bounds.height))
        cell.addSubview(viewInImageView)
        viewInImageView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().offset(-5)
        }
        //viewInImageView.backgroundColor = .red
        

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
            label.text = "+7\(orderStatus[indexPath.row].0.phone)"  //меняем
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
            label.text = "\(orderStatus[indexPath.row].0.address)"
            label.font = .systemFont(ofSize: 13.5, weight: .light)
            label.textColor = .black
            label.numberOfLines = 2
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
            label.text = "\(orderStatus[indexPath.row].0.status)"
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
            button.setTitle(orderStatus[indexPath.row].1.orderStatus, for: .normal) //меняем
            UIView.animate(withDuration: 0.5) {
                button.setTitleColor(UIColor(hex: orderStatus[indexPath.row].1.orderColor), for: .normal) //меняем
                button.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            }
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
            button.isUserInteractionEnabled = false
            button.layer.cornerRadius = 10
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            return button
        }()
        
        
        
       
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
        
        let timeLabel: UILabel = {
            let label = UILabel()
            let time = orderStatus[indexPath.row].0.formattedCreatedTime ?? "0:00"
            label.text = "\(time)"
            label.font = .systemFont(ofSize: 15, weight: .regular)
            label.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.6)
            return label
        }()
        cell.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(arrowImageView.snp.left).inset(-8)
            make.centerY.equalTo(phoneLabel)
        }
        
        if inCellButton.titleLabel?.text == "Вызвать" {
            inCellButton.isHidden = false
            inCellButton.isUserInteractionEnabled = true
            inCellButton.tag = indexPath.row
            inCellButton.addTarget(self, action: #selector(goCourier(sender:)), for: .touchUpInside)
        }
        
        if inCellButton.titleLabel?.text == "Заказ отменен" || inCellButton.titleLabel?.text == "Заказ выполнен" || inCellButton.titleLabel?.text == "Отклонен" || inCellButton.titleLabel?.text == "Завершен" {
            inCellButton.setTitleColor(.clear, for: .normal)
            inCellButton.backgroundColor = UIColor.clear
        }
       
        
       
       
        if isFirstLoadApp > 1 , indexPathsToInsert.contains(indexPath) {
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
        if inCellButton.titleLabel?.text == "Заказ отменен" || inCellButton.titleLabel?.text == "Отклонен" || inCellButton.titleLabel?.text == "Завершен" || inCellButton.titleLabel?.text == "Заказ выполнен" {
            UIView.animate(withDuration: 0.2) {
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
                        inCellButton.alpha = 0.5
            }
        }
        

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.detailVC(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 85)
    }
    
    

    

    
    @objc func goCourier(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        delegate?.createButtonGo(index: indexPath.row)
        
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


// Преобразование hex-кода в UIColor
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



