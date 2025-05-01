import SwiftUI

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, ObservableObject {
    
    @Published var showParameters = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // REMARK: when app started by clicking on banner (while in background or not running at all)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            let userInfo = response.notification.request.content.userInfo
            if let parameterName = userInfo[Constants.keyAlarmParameterName], let parameterValueLast = userInfo[Constants.keyAlarmParameterValueLast] {
                print("🔴 \(parameterName) last value was \(parameterValueLast)")
                showParameters = true
            }
        }
        
        completionHandler()
    }
    
    // REMARK: when notification is received while in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let applicationState = UIApplication.shared.applicationState
        
        if applicationState == .active {
            
            if let userInfo = notification.request.content.userInfo as? [String: Any],
               let parameterName = userInfo[Constants.keyAlarmParameterName],
               let parameterValueLast = userInfo[Constants.keyAlarmParameterValueLast] {
                
                print("🔴 \(parameterName) last value was \(parameterValueLast)")
                showParameters = true
            }
            
            completionHandler([])
            return
        }
        
        completionHandler([.banner, .sound])
    }
}

@main
struct ObavestiApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AlarmCoordinatorView()
                .environmentObject(appDelegate)
        }
    }
}
