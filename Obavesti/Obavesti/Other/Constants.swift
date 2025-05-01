import Foundation

struct Constants {
    static let alarmPeriodMin = 1
    static let alarmPeriodMax = 100

    static let storage = UserDefaults.standard
    static let storageRoot = "com.osmobit.obavesti"
    static let storageAlarmTime = "\(Constants.storageRoot)/alarmTime"
    static let storageAlarmPeriod = "\(Constants.storageRoot)/alarmPeriod"
    
    static let alarmThread = "com.osmobit.obavesti.alarmThread"
    
    static let keyAlarmParameterName = "keyAlarmParameterName"
    static let keyAlarmParameterValueLast = "keyAlarmParameterValueLast"
}
