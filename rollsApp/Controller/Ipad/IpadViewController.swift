//
//  IpadViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 13.07.2024.
//

import UIKit
import Lottie

class IpadViewController: UIViewController {
    
    var animationView: LottieAnimationView = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .BG
        createInterface()
    }
    
    func createInterface() {
        animationView.animation = LottieAnimation.named("wait")
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
        animationView.snp.makeConstraints({ make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(300)
        })
    }
    
    
    func changeInterface(named: String) {
        animationView.animation = LottieAnimation.named(named)
        animationView.loopMode = .playOnce
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.5) { [self] in
                self.animationView.animation = LottieAnimation.named("wait")
                animationView.loopMode = .loop
                animationView.play()
            }
        }
    }

}
