import SwiftUI

enum Page: Hashable, Equatable {
    case none
    case startNavigation
    case startModal
    case alarms(vm: AlarmsVM)
    case parameters
}

final class AlarmCoordinator: ObservableObject {
    
    @Published var navigationPath: NavigationPath
    @Published var modalPage: Page
    
    private(set) var isNavigationOrModal: Bool
    
    init(
        navigationPath: NavigationPath = NavigationPath(),
        modalPage: Page = .none,
        isNavigationOrModal: Bool
    ) {
        self.navigationPath = navigationPath
        self.modalPage = modalPage
        self.isNavigationOrModal = isNavigationOrModal
    }
    
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .none:
            Text("")
        case .startNavigation:
            StartNavigationView()
        case .startModal:
            StartModalView()
        case .alarms(let vm):
            AlarmsView(vm: vm)
        case .parameters:
            ParametersView()
        }
    }
    
    @ViewBuilder
    func buildBinding(page: Binding<Page>) -> some View {
        build(page: page.wrappedValue)
    }
    
    func show(_ page: Page) {
        if isNavigationOrModal {
            self.navigationPath.append(page)
        }
        else {
            //print("🔖 Show page: \(String(describing: page))")
            self.modalPage = page
        }
    }
}
