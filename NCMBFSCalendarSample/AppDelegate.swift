//
//  AppDelegate.swift
//  NCMBFSCalendarSample
//
//  Created by 清水智貴 on 2021/07/04.
//

import UIKit
import NCMB

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let applicationKey = "775bcceb7065d070ed6350ddd7f3135c5a48b409552801becb8b8345898986cc"
        let clientkey = "cf537c02c5aecd6a8a6b817003448bdf94a8441ff677b2bc6688f7769040611d"
        NCMB.initialize(applicationKey: applicationKey, clientKey: clientkey)
        
        // userdefaultsを用いて，匿名ログイン時のuserIdを保存.また全てのユーザーに対してデータのアクセス権を与えるACLを設定
        if UserDefaults.standard.object(forKey: "userId") == nil {
            NCMBUser.enableAutomaticUser()
            // 匿名ユーザーでのログイン
            NCMBUser.automaticCurrentUserInBackground(callback: { result in
                switch result {
                case .success:
                    // ログインに成功した場合の処理
                    if let user = NCMBUser.currentUser {
                        UserDefaults.standard.set(user.objectId, forKey: "userId")
                    }
                case let .failure(error):
                    print("ログインに失敗しました: \(error)")
                }
            })
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

