//
//  StatView.swift
//  rollsApp
//
//  Created by Владимир Кацап on 23.04.2024.
//

import UIKit


class StatView: UIView {
    
    var winnerLabel: UILabel?
    var diagramView = UIView()
    weak var delegate: StatViewControllerDelegate?
    var labelCashh, labelPerevod, labelCourier, labelSumm: UILabel?

    
    var diagrammArr: [(Int, Date)] = []
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        createInterface()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func createInterface() {
        backgroundColor = .white
        let imageView: UIImageView = {
            let image: UIImage = .imageDishes
            let imageView = UIImageView(image: image)
            return imageView
        }()
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(90)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(75)
        }
        
        let nameLabel = generateLaels(text: "Суши Байрам", fonc: .systemFont(ofSize: 28, weight: .semibold), textColor: .black)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(-15)
        }
        
        winnerLabel = generateLaels(text: "🏆 - 1 место в Учкекене", fonc: .systemFont(ofSize: 14, weight: .regular), textColor: .black)
        addSubview(winnerLabel ?? UILabel())
        winnerLabel?.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).inset(-15)
        }
        
      
        addSubview(diagramView)
        diagramView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo((winnerLabel?.snp.bottom)!).inset(-15)
            make.height.equalTo(148)
        }
        showDiagram()
        
        let centerView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(hex: "#F2F2F7")
            view.layer.cornerRadius = 10
            return view
        }()
        addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(diagramView.snp.bottom).inset(-10)
            make.height.equalTo(178)
        }
        
        let labelCash = generateLaels(text: "Касса", fonc: .systemFont(ofSize: 18, weight: .regular), textColor: .black)
        centerView.addSubview(labelCash)
        labelCash.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(15)
        }
        
        let perevodlCash = generateLaels(text: "Переводы", fonc: .systemFont(ofSize: 18, weight: .regular), textColor: .black)
        centerView.addSubview(perevodlCash)
        perevodlCash.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.top.equalTo(labelCash.snp.bottom).inset(-20)
        }
        
        let courerCash = generateLaels(text: "Курьеру", fonc: .systemFont(ofSize: 18, weight: .regular), textColor: .black)
        centerView.addSubview(courerCash)
        courerCash.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.top.equalTo(perevodlCash.snp.bottom).inset(-20)
        }
        
        let summCash = generateLaels(text: "Итого", fonc: .systemFont(ofSize: 18, weight: .semibold), textColor: .black)
        centerView.addSubview(summCash)
        summCash.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.top.equalTo(courerCash.snp.bottom).inset(-23)
        }
        
        labelCashh = {
            let label = UILabel()
            label.text = "0 ₽"
            label.font = .systemFont(ofSize: 18, weight: .regular)
            label.textColor = .black
            return label
        }()
        centerView.addSubview(labelCashh ?? UILabel())
        labelCashh?.snp.makeConstraints({ make in
            make.centerY.equalTo(labelCash.snp.centerY)
            make.right.equalToSuperview().inset(10)
        })
        
        
        labelPerevod = {
            let label = UILabel()
            label.text = "0 ₽"
            label.font = .systemFont(ofSize: 18, weight: .regular)
            label.textColor = .black
            return label
        }()
        centerView.addSubview(labelPerevod ?? UILabel())
        labelPerevod?.snp.makeConstraints({ make in
            make.centerY.equalTo(perevodlCash.snp.centerY)
            make.right.equalToSuperview().inset(10)
        })
        
        
        labelCourier = {
            let label = UILabel()
            label.text = "0 ₽"
            label.font = .systemFont(ofSize: 18, weight: .regular)
            label.textColor = .black
            return label
        }()
        centerView.addSubview(labelCourier ?? UILabel())
        labelCourier?.snp.makeConstraints({ make in
            make.centerY.equalTo(courerCash.snp.centerY)
            make.right.equalToSuperview().inset(10)
        })

        labelSumm = {
            let label = UILabel()
            label.text = "0 ₽"
            label.font = .systemFont(ofSize: 18, weight: .semibold)
            label.textColor = .black
            return label
        }()
        centerView.addSubview(labelSumm ?? UILabel())
        labelSumm?.snp.makeConstraints({ make in
            make.centerY.equalTo(summCash.snp.centerY)
            make.right.equalToSuperview().inset(10)
        })
        
        let separatorView = UIView()
        separatorView.backgroundColor = .separator
        centerView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.left.equalTo(courerCash.snp.left)
            make.right.equalTo((labelCourier?.snp.right)!)
            make.height.equalTo(1)
            make.top.equalTo(courerCash.snp.bottom).inset(-10)
        }
        
        let secondView = UIView()
        secondView.backgroundColor = UIColor(hex: "#F2F2F7")
        secondView.layer.cornerRadius = 10
        addSubview(secondView)
        secondView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(centerView.snp.bottom).inset(-15)
            make.height.equalTo(88)
        }
        
        let rateDishesView: UIView = {
            let view = UIView()
            let gesture = UITapGestureRecognizer(target: self, action: #selector(showRatingDishes))
            view.addGestureRecognizer(gesture)
            view.backgroundColor = .clear
            return view
        }()
        secondView.addSubview(rateDishesView)
        rateDishesView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let imageViewColocol: UIImageView = {
            let image: UIImage = .colocol
            let imageView = UIImageView(image: image)
            return imageView
        }()
        rateDishesView.addSubview(imageViewColocol)
        imageViewColocol.snp.makeConstraints { make in
            make.height.width.equalTo(29)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }
        let labelRatingDishes = generateLaels(text: "Рейтинг блюд", fonc: .systemFont(ofSize: 18, weight: .regular), textColor: .black)
        rateDishesView.addSubview(labelRatingDishes)
        labelRatingDishes.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageViewColocol.snp.right).inset(-10)
        }
        
        let imageViewTopArrow: UIImageView = {
            let image: UIImage = .arrow
            let imageView = UIImageView(image: image)
            return imageView
        }()
        rateDishesView.addSubview(imageViewTopArrow)
        imageViewTopArrow.snp.makeConstraints { make in
            make.width.equalTo(10)
            make.height.equalTo(18)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
        }
        
        let secondSeparatorView = UIView()
        secondSeparatorView.backgroundColor = .separator
        rateDishesView.addSubview(secondSeparatorView)
        secondSeparatorView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
            make.left.equalTo(labelRatingDishes.snp.left)
            make.right.equalTo(imageViewTopArrow.snp.left).inset(-15)
        }
        
        //MARK: -Second
        
        let rateClientView: UIView = {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }()
        secondView.addSubview(rateClientView)
        rateClientView.snp.makeConstraints { make in
            make.top.equalTo(rateDishesView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let imageViewTime: UIImageView = {
            let image: UIImage = .time
            let imageView = UIImageView(image: image)
            return imageView
        }()
        rateClientView.addSubview(imageViewTime)
        imageViewTime.snp.makeConstraints { make in
            make.height.width.equalTo(29)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }
        let labelRatingClient = generateLaels(text: "Рейтинг клиентов", fonc: .systemFont(ofSize: 18, weight: .regular), textColor: .black)
        rateClientView.addSubview(labelRatingClient)
        labelRatingClient.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageViewColocol.snp.right).inset(-10)
        }
        
        let imageViewBotArrow: UIImageView = {
            let image: UIImage = .arrow
            let imageView = UIImageView(image: image)
            return imageView
        }()
        rateClientView.addSubview(imageViewBotArrow)
        imageViewBotArrow.snp.makeConstraints { make in
            make.width.equalTo(10)
            make.height.equalTo(18)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
        }
        
    }
    
    @objc func showRatingDishes() {
        delegate?.showDishesRating()
    }
    
    func generateLaels(text: String,fonc: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = fonc
        label.textColor = textColor
        return label
    }
    
    
    
    func loadStat() {
        diagrammArr.removeAll()
        if let orderStatistics = stat?.orderStatistics {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            for (index, statistic) in orderStatistics.enumerated() {
                if index != 0 { // Пропускаем первый элемент массива
                    if let date = dateFormatter.date(from: statistic.date) {
                        diagrammArr.append((statistic.count, date))
                    }
                }
            }
            showDiagram()
        }
    }

    
    func showDiagram() {
        print(stat)
        if stat != nil, let a = stat?.earningsStatistics.cash, let b = stat?.earningsStatistics.remittance, let c = stat?.earningsStatistics.toCourier, let d = stat?.earningsStatistics.total{
            labelCashh?.text = "\((a) ) ₽"
            labelPerevod?.text = "\(b) ₽"
            labelCourier?.text = "\(c) ₽"
            labelSumm?.text = "\(d) ₽"
        }
        
        diagramView.subviews.forEach { $0.removeFromSuperview() }
        
        let columnWidth: CGFloat = 42
        let spacing: CGFloat = 2
        let maxCount = diagrammArr.max { $0.0 < $1.0 }?.0 ?? 0
        let maxHeight: CGFloat = 78 // Максимальная высота
        let minColumnHeight: CGFloat = 5 // Минимальная высота столбца
        
        let totalWidth = CGFloat(diagrammArr.count) * (columnWidth + spacing) - spacing
        let sidePadding = (diagramView.frame.width - totalWidth) / 2 // Определяем необходимый отступ с обеих сторон
        
        var xPosition: CGFloat = sidePadding // Инициализируем xPosition с учетом отступа
        
        for (index, data) in diagrammArr.enumerated() {
            let columnHeight = CGFloat(data.0) / CGFloat(maxCount) * maxHeight // Нормализация высоты столбца
            let clampedHeight = max(columnHeight, minColumnHeight) // Установка минимальной высоты
            
            let columnView = UIView()
            columnView.backgroundColor = .blue // Цвет столбца
            
            let topView = UIView()
            topView.backgroundColor = UIColor(hex: "#5350E5")
            columnView.addSubview(topView)
            topView.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(5)
            }
            columnView.clipsToBounds = true
            diagramView.addSubview(columnView)
            columnView.backgroundColor = UIColor(hex: "#CECDFF")
            
            columnView.snp.makeConstraints { make in
                make.width.equalTo(columnWidth)
                make.height.equalTo(clampedHeight)
                make.left.equalToSuperview().offset(xPosition)
                make.bottom.equalToSuperview().inset(50)
            }
            
            // Добавляем подпись к столбцу с числовым значением
            let label = UILabel()
            label.text = "\(data.0)"
            label.numberOfLines = 2
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.textColor = UIColor(hex: "#9E9C9B")
            diagramView.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerX.equalTo(columnView)
                make.bottom.equalTo(columnView.snp.top).offset(-2)
            }
            
            let labelBoat = UILabel()
            labelBoat.numberOfLines = 2
            diagramView.addSubview(labelBoat)
            labelBoat.font = .systemFont(ofSize: 20, weight: .semibold)
            labelBoat.textColor = UIColor(hex: "#9E9C9B")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            
            let currentDate = data.1
            
            let dateFormatterDate = DateFormatter()
            dateFormatterDate.locale = Locale(identifier: "ru_RU")
            dateFormatterDate.dateFormat = "E"
            
            labelBoat.text = "\(dateFormatterDate.string(from: currentDate).lowercased())"
            
            labelBoat.snp.makeConstraints { make in
                make.centerX.equalTo(columnView)
                make.top.equalTo(columnView.snp.bottom).inset(2)
            }
            
            let labelDate: UILabel = {
                let label = UILabel()
                label.text = dateFormatter.string(from: currentDate)
                label.textColor = UIColor(hex: "#9E9C9B")
                label.font = .systemFont(ofSize: 22, weight: .regular)
                return label
            }()
            diagramView.addSubview(labelDate)
            labelDate.snp.makeConstraints { make in
                make.top.equalTo(labelBoat.snp.bottom).inset(2)
                make.centerX.equalTo(columnView)
            }
            
            xPosition += columnWidth + spacing
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        showDiagram()
    }

    
    
    func createView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#CECDFF")
        return view
    }
}


