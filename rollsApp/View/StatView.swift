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
            make.height.equalTo(168)
        }
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
        // Предположим, что у вас есть массив orderStatistics типа [(count: Int, dateString: String)]
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
        diagramView.subviews.forEach { $0.removeFromSuperview() }

        let columnWidth: CGFloat = 42
        let spacing: CGFloat = 2
        let maxCount = diagrammArr.max { $0.0 < $1.0 }?.0 ?? 0
        let maxHeight: CGFloat = 78 // Максимальная высота
        let minColumnHeight: CGFloat = 1 // Минимальная высота столбца
        
        var xPosition: CGFloat = 5
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


    
    
    func createView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#CECDFF")
        return view
    }
}


