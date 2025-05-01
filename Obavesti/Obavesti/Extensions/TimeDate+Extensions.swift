import Foundation

extension Date {
    func stringValue() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale.current
        
        return formatter.string(from: self)
    }
}

extension TimeInterval {
    func stringValue(_ type: AlarmPeriodType) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.zeroFormattingBehavior = .default
        formatter.unitsStyle = .brief

        return formatter.string(from: self) ?? ""
    }
}
