//
//  SettingsViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 24.04.2024.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let alertContoller = UIAlertController(title: "Внимание", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
    var tapOnEasterEgg = 0
    var emojiEmitter: CAEmitterLayer!
    
    let nameView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.backgroundColor = .white
        return view
    }()
    
    //MARK: -viewDidLoad()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F2F2F7")
        settingsAlert()
        settingsView()
    }
    
    let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выйти", for: .normal)
        button.tintColor = .systemRed
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        button.backgroundColor = .white
        return button
    }()

    //MARK: -create interface
    
    func settingsView() {
        exitButton.addTarget(self, action: #selector(closeApp), for: .touchUpInside)
        let orderLabel: UILabel = {
            let label = UILabel()
            label.text = "Настройки"
            label.font = .systemFont(ofSize: 41, weight: .bold)
            label.textColor = .black
            return label
        }()
        view.addSubview(orderLabel)
        orderLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(75)
        }
        
        let gesure = UITapGestureRecognizer(target: self, action: #selector(showEasterEgg))
        nameView.addGestureRecognizer(gesure)
        view.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(70)
            make.top.equalTo(orderLabel.snp.bottom).inset(-20)
        }
        let cafeImageView: UIImageView = {
            let image:UIImage = .image
            let imageView = UIImageView(image: image)
            return imageView
        }()
        nameView.addSubview(cafeImageView)
        cafeImageView.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        let cafeNameLabel: UILabel = {
            let label = UILabel()
            label.text = "Байрам"
            label.font = .systemFont(ofSize: 23, weight: .bold)
            label.textColor = .black
            return label
        }()
        nameView.addSubview(cafeNameLabel)
        cafeNameLabel.snp.makeConstraints { make in
            make.left.equalTo(cafeImageView.snp.right).inset(-15)
            make.bottom.equalTo(cafeImageView.snp.centerY).offset(3)
        }
        
        let cafeAdressLabel: UILabel = {
            let label = UILabel()
            label.text = "Ленина, 49, Учкекен"
            label.font = .systemFont(ofSize: 15, weight: .regular)
            label.textColor = .black
            return label
        }()
        nameView.addSubview(cafeAdressLabel)
        cafeAdressLabel.snp.makeConstraints { make in
            make.left.equalTo(cafeImageView.snp.right).inset(-15)
            make.top.equalTo(cafeImageView.snp.centerY)
        }
        
        view.addSubview(exitButton)
        exitButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(nameView.snp.bottom).inset(-30)
        }
    }
    
    
    func settingsAlert() {
        let yesAction = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            UserDefaults.standard.removeObject(forKey: "authKey")
            authKey = ""
            self.navigationController?.setViewControllers([LoginViewController()], animated: false)
        }
        alertContoller.addAction(yesAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertContoller.addAction(cancelAction)
    }
    
    //MARK: -create emoji shower
    
    func createEmojiShower() {
          emojiEmitter = CAEmitterLayer()
        emojiEmitter.emitterPosition = CGPoint(x: 10, y: 0)
        emojiEmitter.emitterShape = .line
          emojiEmitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
          
          let emojis = ["🎊", "😍", "🥤", "🥳", "🎉", "🤩", "🍱", "🍣", "🍔", "🫔"] // List of emojis to use
          
          var emojiCells = [CAEmitterCell]()
          
          // Create emitter cells for each emoji
          for emoji in emojis {
              let cell = makeEmojiEmitterCell(emoji: emoji)
              emojiCells.append(cell)
          }
          
          // Set the emitter cells for the emoji emitter
          emojiEmitter.emitterCells = emojiCells
          
          // Add the emoji emitter to the view's layer
          view.layer.addSublayer(emojiEmitter)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.emojiEmitter.birthRate = 0
            self?.tapOnEasterEgg = 0
        }
      }
      
      // Function to create an emitter cell for a specific emoji
      func makeEmojiEmitterCell(emoji: String) -> CAEmitterCell {
          let cell = CAEmitterCell()
          
          // Set the birth rate (how frequently emojis appear) and lifetime (how long they last)
          cell.birthRate = 3
          cell.lifetime = Float.random(in: 50.0...70.0)
          cell.lifetimeRange = 0
          
          // Set the initial velocity and velocity range for the emojis
          cell.velocity = CGFloat.random(in: 100...200)
          cell.velocityRange = 50
          
          // Configure the direction and range of emoji emission
          cell.emissionLongitude = -CGFloat.pi  * (-0.85)
          cell.emissionRange = CGFloat.pi / 4
          
          // Set rotation and scale properties for emojis
          cell.spin = 2
          cell.spinRange = 3
          cell.scaleRange = 0.5
          cell.scaleSpeed = -0.05
          
          // Create the emoji image from the text
          if let emojiImage = imageFrom(emoji: emoji) {
              cell.contents = emojiImage.cgImage
          }
          
          return cell
      }
      
      // Function to create an image from emoji text
      func imageFrom(emoji: String) -> UIImage? {
          let label = UILabel()
          label.text = emoji
          label.font = UIFont.systemFont(ofSize: 30)
          label.sizeToFit()
          
          UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, UIScreen.main.scale)
          
          if let context = UIGraphicsGetCurrentContext() {
              label.layer.render(in: context)
              let image = UIGraphicsGetImageFromCurrentImageContext()
              UIGraphicsEndImageContext()
              return image
          }
          
          return nil
      }

    @objc func closeApp() {
        present(alertContoller, animated: true, completion: nil)
    }
    
    @objc func showEasterEgg() {
        tapOnEasterEgg += 1
        if tapOnEasterEgg == 15 {
            createEmojiShower()
        }
    }
}
