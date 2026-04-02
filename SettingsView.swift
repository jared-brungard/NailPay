import SwiftUI

struct SettingsView: View {
    @AppStorage("taxRate")           private var taxRate: Double = 0.25
    @AppStorage("taxMethod")         private var taxMethod: String = "flat"
    @AppStorage("paycheckModeEnabled") private var paycheckModeEnabled: Bool = false
    @AppStorage("paycheckFrequency") private var paycheckFrequency: String = "biweekly"

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Tax Calculation
                Section("Tax Calculation") {
                    Picker("Method", selection: $taxMethod) {
                        Text("Flat Rate").tag("flat")
                        Text("AI Approximation (Coming Soon)").tag("ai")
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .onChange(of: taxMethod) { _, newValue in
                        if newValue == "ai" { taxMethod = "flat" }
                    }

                    if taxMethod == "flat" {
                        HStack {
                            Text("Tax rate")
                            Spacer()
                            Text("\(Int(taxRate * 100))%")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $taxRate, in: 0...0.5, step: 0.01)
                    }
                }

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
