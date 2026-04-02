import SwiftUI
import SwiftData

struct PaycheckView: View {
    @AppStorage("taxRate")           private var taxRate: Double = 0.25
    @AppStorage("paycheckFrequency") private var paycheckFrequency: String = "biweekly"

    @Query private var appointments: [Appointment]
    @Query private var expenses: [Expense]

    private var period: PayPeriod {
        PayPeriodHelper.currentPeriod(frequency: paycheckFrequency)
    }

    var body: some View {
        PaycheckDetailView(
            period: period,
            appointments: appointments,
            expenses: expenses,
            taxRate: taxRate,
            frequencyLabel: frequencyLabel
        )
        .navigationTitle("Paycheck")
    }

    private var frequencyLabel: String {
        switch paycheckFrequency {
        case "weekly":   return "Weekly"
        case "biweekly": return "Bi-Weekly"
        default:         return "Monthly"
        }
    }
}

// Shared detail layout used by both PaycheckView and PastPaychecksView
struct PaycheckDetailView: View {
    let period: PayPeriod
    let appointments: [Appointment]
    let expenses: [Expense]
    let taxRate: Double
    let frequencyLabel: String

    private var periodAppointments: [Appointment] {
        appointments.filter { $0.date >= period.start && $0.date <= period.end }
    }

    private var periodExpenses: [Expense] {
        expenses.filter { $0.date >= period.start && $0.date <= period.end }
    }

    private var grossIncome: Double  { periodAppointments.reduce(0) { $0 + $1.total } }
    private var totalExpenses: Double { periodExpenses.reduce(0) { $0 + $1.amount } }
    private var netProfit: Double    { grossIncome - totalExpenses }
    private var taxSetAside: Double  { max(0, netProfit) * taxRate }
    private var takeHome: Double     { max(0, netProfit) - taxSetAside }

    var body: some View {
        Form {
            Section("Pay Period") {
                labelRow("Frequency", frequencyLabel)
                HStack {
                    Text("Period")
                    Spacer()
                    Text("\(period.start, style: .date) – \(period.end, style: .date)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }

            Section("This Period's Earnings") {
                moneyRow("Gross Income", grossIncome)
                moneyRow("Expenses", -totalExpenses)
                Divider()
                moneyRow("Net Profit", netProfit)
                    .fontWeight(.semibold)
            }

            Section("Paycheck Breakdown") {
                HStack {
                    Text("Tax Rate")
                    Spacer()
                    Text("\(Int(taxRate * 100))%")
                        .foregroundStyle(.secondary)
                }
                moneyRow("Set Aside for Taxes", taxSetAside)
                    .foregroundStyle(.orange)

                HStack {
                    Text("Your Paycheck")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("$\(takeHome, specifier: "%.2f")")
                        .fontWeight(.semibold)
                        .foregroundStyle(takeHome >= 0 ? .green : .red)
                        .monospacedDigit()
                }
            }

            if periodAppointments.isEmpty && periodExpenses.isEmpty {
                Section {
                    Text("No activity recorded for this pay period yet.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }

    @ViewBuilder
    private func moneyRow(_ title: String, _ value: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("$\(value, specifier: "%.2f")")
                .monospacedDigit()
                .foregroundStyle(value < 0 ? .red : .primary)
        }
    }

    @ViewBuilder
    private func labelRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}
