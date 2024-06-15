//
//  SceneDelegate.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit
import AlamofireImage
import Alamofire

var imageSatandart: UIImage?

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let navController = UINavigationController(rootViewController: LoginViewController())
    let splitVC = UISplitViewController(style:  .doubleColumn)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        loadCafeInfo()
        self.window = window
    }
    
    func loadCafeInfo() {
        if let savedData = UserDefaults.standard.data(forKey: "info") {
            let decoder = JSONDecoder()
            if let cafe = try? decoder.decode(Cafe.self, from: savedData) {
                cafeID = cafe.id
                nameCafe = cafe.title
                adresCafe = cafe.address
                loadStandartImage(url: cafe.img)
            }
        }
    }
    
    func loadStandartImage(url: String) {
        
        AF.request("http://arbamarket.ru\(url)").responseImage { response in
            switch response.result {
            case .success(let image):
                imageSatandart = image
            case .failure(_):
                imageSatandart = UIImage(named: "standart")
            }
            
        }
        
    }
    
   
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

