import SwiftUI

struct AlarmsView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appDelegate: AppDelegate
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject private var coordinator: AlarmCoordinator
    
    @StateObject private var vm: AlarmsVM
    
    @State private var selectedAlarmType: AlarmsModel.Kind
    @State private var selectedTime: Date
    @State private var selectedPeriodType = AlarmPeriodType.hours
    @State private var selectedPeriodDays: Int
    @State private var selectedPeriodHours: Int
    @State private var selectedPeriodMinutes: Int
    
    private var selectedPeriodSeconds: Int {
        switch selectedPeriodType {
        case .days:
            return selectedPeriodDays * 24 * 60 * 60
        case .hours:
            return selectedPeriodHours * 60 * 60
        case .minutes:
            return selectedPeriodMinutes * 60
        }
    }
    
    init(
        vm: AlarmsVM,
        selectedAlarmType: AlarmsModel.Kind = .time,
        selectedTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
        selectedPeriodType: AlarmPeriodType = .hours,
        selectedPeriodDays: Int = Constants.alarmPeriodMin,
        selectedPeriodHours: Int = Constants.alarmPeriodMin,
        selectedPeriodMinutes: Int = Constants.alarmPeriodMin
    ) {
        self._vm = StateObject(wrappedValue: vm)
        self._selectedAlarmType = State(initialValue: selectedAlarmType)
        self._selectedTime = State(initialValue: selectedTime)
        self._selectedPeriodType = State(initialValue: selectedPeriodType)
        self._selectedPeriodDays = State(initialValue: selectedPeriodDays)
        self._selectedPeriodHours = State(initialValue: selectedPeriodHours)
        self._selectedPeriodMinutes = State(initialValue: selectedPeriodMinutes)

        vm.requestPermission()
    }
    
    var body: some View {
        #if DEBUG1
        let _ = Self._printChanges()
        #endif

        VStack {
            if vm.permission == true {
                Spacer()
                VStack {
                    alarm(.time)
                    alarm(.period)
                }
            }
            else if vm.permission == false {
                buttonPermission()
            }
            Spacer()
            bottom()
        }
        .modifier(VStackModifier())
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // App will go into the background
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // App will go into the foreground
        }
        .onChange(of: scenePhase) { old, new in
            switch new {
            case .active:
                vm.requestPermission()
                break
            case .inactive:
                break
            case .background:
                coordinator.show(.none)
                break
            @unknown default:
                break
            }
        }
        .onChange(of: appDelegate.showParameters) { old, new in
            if appDelegate.showParameters { coordinator.show(.parameters) }
        }
    }
    
    @ViewBuilder private func buttonPermissionText() -> some View {
        Text("Notifications not allowed")
            .font(.title)
        Text("Click to open settings")
            .font(.body)
    }
    private func buttonPermission() -> some View {
        Button(action: {
            openAppSettings()
        }) {
            VStack {
                Spacer()
                buttonPermissionText()
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            .modifier(BorderOverlayStoke())
        }
    }

    private func alarmButtonContentWhenSet(_ kind: AlarmsModel.Kind, alarm: TimeInterval) -> some View {
        var timeText = ""
        switch kind {
        case .time:
            timeText = "\(Date(timeIntervalSince1970: alarm).stringValue())"
        case .period:
            timeText = "\(alarm.stringValue(selectedPeriodType))"
        }

        var titleText = ""
        switch kind {
        case .time:
            titleText = "Alarm set at"
        case .period:
            titleText = "Alarm set on every"
        }
        
        return VStack {
            Spacer()
            Text(titleText)
                .frame(maxWidth: .infinity)
                .font(.title)
                .bold()
            Text(timeText)
                .font(.body)
            Spacer()
        }
        .modifier(BorderBackgroundStoke(color: selectedAlarmType == kind ? Colors.defaultBorderSelected(colorScheme) : Colors.defaultBorderNotSelected(colorScheme)))
    }

    private func alarmButtonContentWhenNotSet(_ kind: AlarmsModel.Kind) -> some View {
        var titleText = ""
        switch kind {
        case .time:
            titleText = "Set alarm at"
        case .period:
            titleText = "Set alarm every"
        }
        
        return VStack {
            Spacer()
            Text(titleText)
                .frame(maxWidth: .infinity)
                .font(.title)
            switch kind {
            case .time:
                pickerDateTime()
                    .datePickerStyle(CompactDatePickerStyle())
            case .period:
                period()
                    .tint(Colors.defaultText(colorScheme))
                    .pickerStyle(MenuPickerStyle())
            }
            Spacer()
        }
        .modifier(BorderBackgroundStoke(color: selectedAlarmType == kind ? Colors.defaultBorderSelected(colorScheme) : Colors.defaultBorderNotSelected(colorScheme)))
    }
    
    private func alarm(_ kind: AlarmsModel.Kind) -> some View {
        var alarm: TimeInterval?
        
        switch kind {
        case .time:
            alarm = vm.alarmTime
        case .period:
            alarm = vm.alarmPeriod
        }
        
        if let alarm = alarm {
            return AnyView(
                Button(action: { selectedAlarmType = kind} ) {
                    alarmButtonContentWhenSet(kind, alarm: alarm)
                }
            )
        }
        return AnyView(
            ZStack {
                Button(action: {
                    selectedAlarmType = kind
                }) {
                    Text("")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                alarmButtonContentWhenNotSet(kind)
            }
        )
    }
    
    @ViewBuilder private func bottom() -> some View {
        VStack {
            if vm.permission == true {
                buttonSaveRemove()
            }
            if !coordinator.isNavigationOrModal {
                buttonDismiss()
            }
        }
    }
    
    private func pickerDateTime() -> some View {
        DatePicker("", selection: Binding(get: {
            selectedTime
        }, set: { newValue in
            let roundedTime = Calendar.current.date(bySetting: .second, value: 0, of: newValue) ?? newValue
            selectedTime = roundedTime
        }), displayedComponents: [.date, .hourAndMinute])
        .labelsHidden()
    }
    
    @ViewBuilder
    private func period() -> some View {
        
        switch selectedPeriodType {
        case .days:
            Picker("", selection: $selectedPeriodDays) {
                ForEach(Constants.alarmPeriodMin...Constants.alarmPeriodMax, id: \.self) { index in
                    Text("\(index)")
                }
            }
        case .hours:
            Picker("", selection: $selectedPeriodHours) {
                ForEach(Constants.alarmPeriodMin...Constants.alarmPeriodMax, id: \.self) { index in
                    Text("\(index)")
                }
            }
        case .minutes:
            Picker("", selection: $selectedPeriodMinutes) {
                ForEach(Constants.alarmPeriodMin...Constants.alarmPeriodMax, id: \.self) { index in
                    Text("\(index)")
                }
            }
        }
        
        Picker("", selection: $selectedPeriodType) {
            ForEach(AlarmPeriodType.allCases, id: \.self) { option in
                Text(option.rawValue)
            }
        }
    }
    
    @ViewBuilder
    private func buttonSaveRemove() -> some View {
        let saveOrRemove =
        (selectedAlarmType == .period && vm.alarmPeriod == nil) ||
        (selectedAlarmType == .time && vm.alarmTime == nil)

        let seconds = selectedAlarmType == .period ? TimeInterval(selectedPeriodSeconds) : selectedTime.timeIntervalSince1970
        
        Button(action: {
            if saveOrRemove {
                vm.saveAlarm(seconds, kind: selectedAlarmType)
            }
            else {
                vm.removeAlarm(selectedAlarmType)
            }
        }) {
            Text(saveOrRemove ? "Save" : "Remove")
                .frame(maxWidth: .infinity)
        }
        .modifier(ButtonModifier())
        .tint(saveOrRemove ? .green : .red)
        .disabled(saveOrRemove && selectedAlarmType == .time && seconds < Date().timeIntervalSince1970)
    }
    
    private func buttonDismiss() -> some View {
        Button(action: {
            if coordinator.isNavigationOrModal {
                return
            }
            coordinator.show(.none)
        }) {
            Text("Dissmiss")
                .frame(maxWidth: .infinity)
        }
        .modifier(ButtonModifier())
    }
    
    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}

#Preview {
    AlarmsView(vm: AlarmsVM(model: AlarmsModel()))
        .environmentObject(AlarmCoordinator(isNavigationOrModal: false))
}
