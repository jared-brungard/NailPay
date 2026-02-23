import SwiftUI
import SwiftData

struct DashboardView: View {
    @AppStorage("taxRate") private var taxRate: Double = 0.25

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

                    Slider(value: $taxRate, in: 0...0.5, step: 0.01)

                    row("Set aside", taxSetAside)
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
