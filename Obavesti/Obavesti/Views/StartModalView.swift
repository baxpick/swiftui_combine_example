import SwiftUI

struct StartModalView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appDelegate: AppDelegate
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
        .onAppear {
            if appDelegate.showParameters { coordinator.show(.parameters) }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // App will go into the background
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // App will go into the foreground
        }
        .onChange(of: scenePhase) { old, new in
            switch new {
            case .active:
                if appDelegate.showParameters { coordinator.show(.parameters) }
                break
            case .inactive:
                break
            case .background:
                break
            @unknown default:
                break
            }
        }
        .onChange(of: appDelegate.showParameters) { old, new in
            if appDelegate.showParameters { coordinator.show(.parameters) }
        }
    }
    
    private func buttonAlarms() -> some View {
        Button(action: {
            let vm = AlarmsVM(model: AlarmsModel())
            coordinator.show(.alarms(vm: vm))
        }) {
            Text("Alarms") // Modal
                .modifier(ButttonTextModifier())
        }
        .modifier(ButtonModifier())
    }
}

#Preview {
    StartModalView()
        .environmentObject(AlarmCoordinator(isNavigationOrModal: false))
}
