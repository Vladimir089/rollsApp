//
//  StatViewController.swift
//  rollsApp
//
//  Created by Владимир Кацап on 23.04.2024.
//

import UIKit

import Charts

protocol StatViewControllerDelegate: AnyObject {
    func showDishesRating()
    func showClientRating()
}

class StatViewController: UIViewController {
    var mainView: StatView?
    var authCheckTimer: Timer?
    var loadTimer: Timer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView = StatView()
        mainView?.delegate = self
        self.view = mainView
        startAuthCheckTimer()
        mainView?.showDiagram()
    }
    
    func startAuthCheckTimer() {
        authCheckTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkAuthKey), userInfo: nil, repeats: true)
    }
    
    func stopAuthCheckTimer() {
        authCheckTimer?.invalidate()
        authCheckTimer = nil
    }
    
    @objc func checkAuthKey() {
        if !authKey.isEmpty {
            stopAuthCheckTimer()
            print(authKey)
            getStatisticAll {
                self.mainView?.loadStat()
                self.startLoadTimer()
            }
        }
    }
    
    func startLoadTimer() {
        loadTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
    
    @objc func loadData() {
        getStatisticAll {
            self.mainView?.diagramView.subviews.forEach { $0.removeFromSuperview() }
            self.mainView?.loadStat()
        }
    }
    
    deinit {
        stopAuthCheckTimer()
    }
}

extension StatViewController: StatViewControllerDelegate {
    func showDishesRating() {
        let vc = RatingDishesViewController()
        vc.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func showClientRating() {
        let vc = RatingClientViewController()
        vc.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


