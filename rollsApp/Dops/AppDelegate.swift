//
//  AppDelegate.swift
//  rollsApp
//
//  Created by Владимир Кацап on 02.04.2024.
//

import UIKit



@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Запрашиваем разрешения на уведомления
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            }
        UNUserNotificationCenter.current().delegate = self
            return true
        }
        
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
            print("Device Token: \(tokenString)")
        }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error.localizedDescription)")
    }

        // MARK: UISceneSession Lifecycle

        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    
    
    // MARK: UISceneSession Lifecycle
    
    
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Метод вызывается, когда уведомление доставляется на устройство, находящееся в фокусе
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Показывать уведомление даже если приложение в фокусе
        completionHandler([.alert, .badge, .sound])
    }
    
    // Метод вызывается, когда пользователь взаимодействует с уведомлением (например, нажимает на него)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Обработайте действие пользователя с уведомлением
        let userInfo = response.notification.request.content.userInfo
        print("User Info: \(userInfo)")
        
        // Вызовите completionHandler
        completionHandler()
    }
}
