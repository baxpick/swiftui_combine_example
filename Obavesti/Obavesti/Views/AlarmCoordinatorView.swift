import SwiftUI

struct AlarmCoordinatorView: View {
    
    @EnvironmentObject private var appDelegate: AppDelegate
    @StateObject private var coordinator: AlarmCoordinator
        
    init(
        coordinator: AlarmCoordinator = AlarmCoordinator(isNavigationOrModal: false)
    ) {
        self._coordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        #if DEBUG1
        let _ = Self._printChanges()
        #endif
        
        root()
            .environmentObject(coordinator)
    }
    
    @ViewBuilder
    private func root() -> some View {
        if coordinator.isNavigationOrModal {
            NavigationStack(path: $coordinator.navigationPath) {
                coordinator.build(page: .startNavigation)
                    .navigationDestination(for: Page.self) { page in
                        coordinator.build(page: page)
                    }
            }
        }
        else {
            ZStack {
                coordinator.build(page: .startModal)
                
                if coordinator.modalPage != .none {
                    coordinator.buildBinding(page: $coordinator.modalPage)
                }
            }
        }
    }
}

#Preview {
    AlarmCoordinatorView()
        .environmentObject(AlarmCoordinator(isNavigationOrModal: false))
}
