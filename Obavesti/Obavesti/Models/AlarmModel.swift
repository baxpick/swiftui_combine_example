import Foundation
import UserNotifications

final class AlarmsModel {
    
    enum Kind {
        case time
        case period
    }
    
    init(with alarms: (() -> (TimeInterval?, TimeInterval?))? = nil) {
        
        if let alarms = alarms {
            saveAlarm(alarms().0, kind: .time)
            saveAlarm(alarms().1, kind: .period)
        }
        else {
            if let alarmTime = loadAlarm(.time) {
                if alarmTime < Date().timeIntervalSince1970 {
                    saveAlarm(nil, kind: .time)
                }
                else {
                    saveAlarm(alarmTime, kind: .time)
                }
            }
            
            if let alarmPeriod = loadAlarm(.period) {
                saveAlarm(alarmPeriod, kind: .period)
            }
        }
    }
    
    @Published var permission: Bool?
    
    @Published var alarmTime: TimeInterval?
    @Published var alarmPeriod: TimeInterval?
    
    // ---
    
    private func createContentFor(_ kind: Kind, parameterName: String, parameterValueLast: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Alarm \(String(describing: kind))"
        content.body = "Open app to check"
        content.sound = UNNotificationSound.default
        content.threadIdentifier = Constants.alarmThread
        content.userInfo[Constants.keyAlarmParameterName] = parameterName //"Air Quality"
        content.userInfo[Constants.keyAlarmParameterValueLast] = parameterValueLast //"5/10"

        return content
    }
    
    private func createTriggerFor(_ kind: Kind, alarm: TimeInterval) -> UNNotificationTrigger? {
        if kind == .time {
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: Date(timeIntervalSince1970: alarm)
            )
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        }
        else if kind == .period {
            return UNTimeIntervalNotificationTrigger(timeInterval: alarm, repeats: true)
        }
        return nil
    }
    
    private func registerAlarmFor(_ kind: Kind, alarm: TimeInterval) {
        let content = createContentFor(kind, parameterName: "Air Quality", parameterValueLast: "5/10")
        let trigger = createTriggerFor(kind, alarm: alarm)
        let request = UNNotificationRequest(identifier: String(alarm), content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let _ = error {
                // FIXXXME: Handle error
            }
        }
    }
    
    private func loadAlarm(_ kind: Kind) -> TimeInterval? {
        if kind == .time {
            return Constants.storage.value(forKey: Constants.storageAlarmTime) as? TimeInterval
        }
        else if kind == .period {
            return Constants.storage.value(forKey: Constants.storageAlarmPeriod) as? TimeInterval
        }
        return nil
    }
    
    func saveAlarm(_ alarm: TimeInterval?, kind: Kind) {
        
        let type = String(describing: kind)
        
        // ---
        
        let savedAlarm = loadAlarm(kind)
        
        // remove old?
        if let savedAlarm = savedAlarm, savedAlarm != alarm {
            if kind == .time {
                let time = Date(timeIntervalSince1970: savedAlarm).stringValue()
                print("🔖 Alarm [\(type)] remove old: \(time)")
            }
            else if kind == .period {
                let time = savedAlarm.stringValue(.hours)
                print("🔖 Alarm [\(type)] remove old: \(time) hours")
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(savedAlarm)])
        }
        
        // add new?
        if let alarm = alarm, savedAlarm != alarm {
            if kind == .time {
                let time = Date(timeIntervalSince1970: alarm).stringValue()
                print("🔖 Alarm [\(type)] add new: \(time)")
            }
            else if kind == .period {
                let time = alarm.stringValue(.hours)
                print("🔖 Alarm [\(type)] add new: \(time)")
            }
            
            registerAlarmFor(kind, alarm: alarm)
        }
        
        // update storage
        if kind == .time {
            self.alarmTime = alarm
            Constants.storage.set(alarmTime, forKey: Constants.storageAlarmTime)
        }
        else if kind == .period {
            self.alarmPeriod = alarm
            Constants.storage.set(alarmPeriod, forKey: Constants.storageAlarmPeriod)
        }
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                self.permission = true
            }
            else {
                if let _ = error {
                    // FIXXXME: handle error
                    self.permission = nil
                }
                else {
                    self.permission = false
                }
            }
        }
    }
}
