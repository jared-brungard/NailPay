import SwiftUI

struct SettingsView: View {
    @AppStorage("paycheckModeEnabled") private var paycheckModeEnabled: Bool = false
    @AppStorage("paycheckFrequency") private var paycheckFrequency: String = "biweekly"

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Payment Types
                Section("Payment Types") {
                    NavigationLink("Payment Types") {
                        PaymentTypesView()
                    }
                }

                // MARK: - Recurring Expenses
                Section("Recurring Expenses") {
                    NavigationLink("Recurring Expenses") {
                        RecurringExpensesView()
                    }
                }

                // MARK: - Paycheck Mode
                Section("Paycheck Mode") {
                    Toggle("Enable Paycheck Mode", isOn: $paycheckModeEnabled)
                    if paycheckModeEnabled {
                        Picker("Pay Period", selection: $paycheckFrequency) {
                            Text("Weekly").tag("weekly")
                            Text("Bi-Weekly").tag("biweekly")
                            Text("Monthly").tag("monthly")
                        }
                        NavigationLink("View Paycheck") {
                            PaycheckView()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
