import SwiftUI
import Combine

final class AlarmsVM: ObservableObject, Identifiable, Equatable, Hashable {
    
    // MARK: Identifiable, Equatable, Hashable
    private (set) var id = UUID()
    
    static func == (lhs: AlarmsVM, rhs: AlarmsVM) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
         hasher.combine(id)
    }
    
    private var model: AlarmsModel
    
    init(model: AlarmsModel) {
        self.model = model

        self.model.$alarmTime
            .receive(on: DispatchQueue.main)
            .assign(to: &$alarmTime)
        
        self.model.$alarmPeriod
            .receive(on: DispatchQueue.main)
            .assign(to: &$alarmPeriod)
        
        self.model.$permission
            .receive(on: DispatchQueue.main)
            .assign(to: &$permission)
    }
    
    @Published var permission: Bool?
    
    @Published var alarmTime: TimeInterval?
    @Published var alarmPeriod: TimeInterval?
    
    func saveAlarm(_ alarm: TimeInterval, kind: AlarmsModel.Kind) {
        model.saveAlarm(alarm, kind: kind)
    }
    func removeAlarm(_ kind: AlarmsModel.Kind) {
        model.saveAlarm(nil, kind: kind)
    }
    
    func requestPermission() {
        model.requestPermission()
    }
}
