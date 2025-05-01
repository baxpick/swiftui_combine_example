import SwiftUI

struct ParametersView: View {
    
    @EnvironmentObject private var appDelegate: AppDelegate
    @EnvironmentObject private var coordinator: AlarmCoordinator
    
    var body: some View {
        #if DEBUG1
        let _ = Self._printChanges()
        #endif
        
        VStack {
            Text("XXX")
            Spacer()
            buttonDismiss()
        }
        .modifier(VStackModifier())
        .onAppear {
            appDelegate.showParameters = false
        }
    }
    
    private func buttonDismiss() -> some View {
        Button(action: {
            if coordinator.isNavigationOrModal {
                return
            }
            coordinator.show(.none)
        }) {
            Text("Dismiss")
                .modifier(ButttonTextModifier())
        }
        .modifier(ButtonModifier())
    }
}

#Preview {
    ParametersView()
        .environmentObject(AlarmCoordinator(isNavigationOrModal: false))
}
