import SwiftUI

struct StartNavigationView: View {
    
    @EnvironmentObject private var coordinator: AlarmCoordinator
    
    var body: some View {
        #if DEBUG1
        let _ = Self._printChanges()
        #endif
        
        VStack {
            Spacer()
            buttonAlarms()
        }
        .modifier(VStackModifier())
    }
    
    private func buttonAlarms() -> some View {
        Button(action: {
            let vm = AlarmsVM(model: AlarmsModel())
            coordinator.show(.alarms(vm: vm))
        }) {
            Text("Alarms") // Navigation
                .modifier(ButttonTextModifier())
        }
        .modifier(ButtonModifier())
    }
}

#Preview {
    StartNavigationView()
        .environmentObject(AlarmCoordinator(isNavigationOrModal: false))
        
}
