import SwiftUI
import SwiftData

struct DashboardView: View {
    @AppStorage("taxRate")             private var taxRate: Double = 0.25
    @AppStorage("paycheckModeEnabled") private var paycheckModeEnabled: Bool = false
    @AppStorage("paycheckFrequency")   private var paycheckFrequency: String = "biweekly"

    @State private var filter: TimeFilter = .month
    @Query private var appointments: [Appointment]
    @Query private var expenses: [Expense]

    private var filteredAppointments: [Appointment] {
        let (start, end) = DateRangeHelper.range(for: filter)
        guard let start, let end else { return appointments }
        return appointments.filter { $0.date >= start && $0.date < end }
    }

    private var filteredExpenses: [Expense] {
        let (start, end) = DateRangeHelper.range(for: filter)
        guard let start, let end else { return expenses }
        return expenses.filter { $0.date >= start && $0.date < end }
    }
    @Environment(\.modelContext) private var modelContext
    @State private var importMessage: String?

    
    
    var incomeTotal: Double {
        appointments.reduce(0) { $0 + $1.total }
    }

    var expenseTotal: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var profit: Double {
        incomeTotal - expenseTotal
    }

    var taxSetAside: Double {
        max(0, profit) * taxRate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("", selection: $filter) {
                        ForEach(TimeFilter.allCases) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("This Year (simple totals)") {
                    row("Income", incomeTotal)
                    row("Expenses", -expenseTotal)
                    row("Profit", profit)
                }

                Section("Taxes") {
                    HStack {
                        Text("Tax rate")
                        Spacer()
                        Text("\(Int(taxRate * 100))%")
                            .foregroundStyle(.secondary)
                    }

                    row("Set aside", taxSetAside)
                }
                if paycheckModeEnabled {
                    Section("Paycheck") {
                        let period = PayPeriodHelper.currentPeriod(frequency: paycheckFrequency)
                        let periodIncome = appointments
                            .filter { $0.date >= period.start && $0.date <= period.end }
                            .reduce(0) { $0 + $1.total }
                        let periodExpenses = expenses
                            .filter { $0.date >= period.start && $0.date <= period.end }
                            .reduce(0) { $0 + $1.amount }
                        let net = periodIncome - periodExpenses
                        let takeHome = max(0, net) - max(0, net) * taxRate

                        HStack {
                            Text("Period")
                            Spacer()
                            Text("\(period.start, style: .date) – \(period.end, style: .date)")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Your Paycheck")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("$\(takeHome, specifier: "%.2f")")
                                .fontWeight(.semibold)
                                .foregroundStyle(takeHome >= 0 ? .green : .red)
                                .monospacedDigit()
                        }
                        NavigationLink("Past Paychecks") {
                            PastPaychecksView()
                        }
                    }
                }

                Section("Demo Data") {
                    Button("Load Demo Data (CSV)") {
                        do {
                            try CSVImporter.importAppointments(modelContext: modelContext)
                            try CSVImporter.importExpenses(modelContext: modelContext)
                        } catch {
                            print("Import failed:", error)
                        }
                    }

                    Button("Clear All Data") {
                        do {
                            try modelContext.delete(model: Appointment.self)
                            try modelContext.delete(model: Expense.self)
                        } catch {
                            print("Clear failed:", error)
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
        }
    }

    private func row(_ title: String, _ value: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("$\(value, specifier: "%.2f")")
                .monospacedDigit()
        }
    }
}

