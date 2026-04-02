import SwiftUI
import SwiftData

struct PastPaychecksView: View {
    @AppStorage("taxRate")           private var taxRate: Double = 0.25
    @AppStorage("paycheckFrequency") private var paycheckFrequency: String = "biweekly"

    @Query private var appointments: [Appointment]
    @Query private var expenses: [Expense]

    private var periodsWithActivity: [PayPeriod] {
        PayPeriodHelper.pastPeriods(frequency: paycheckFrequency).filter { period in
            appointments.contains { $0.date >= period.start && $0.date <= period.end } ||
            expenses.contains    { $0.date >= period.start && $0.date <= period.end }
        }
    }

    var body: some View {
        Group {
            if periodsWithActivity.isEmpty {
                ContentUnavailableView(
                    "No Past Paychecks",
                    systemImage: "dollarsign.circle",
                    description: Text("Activity from previous pay periods will appear here.")
                )
            } else {
                List(periodsWithActivity, id: \.start) { period in
                    NavigationLink {
                        PaycheckDetailView(
                            period: period,
                            appointments: appointments,
                            expenses: expenses,
                            taxRate: taxRate,
                            frequencyLabel: frequencyLabel
                        )
                        .navigationTitle("\(period.start, style: .date)")
                    } label: {
                        PastPaycheckRow(
                            period: period,
                            appointments: appointments,
                            expenses: expenses,
                            taxRate: taxRate
                        )
                    }
                }
            }
        }
        .navigationTitle("Past Paychecks")
    }

    private var frequencyLabel: String {
        switch paycheckFrequency {
        case "weekly":   return "Weekly"
        case "biweekly": return "Bi-Weekly"
        default:         return "Monthly"
        }
    }
}

private struct PastPaycheckRow: View {
    let period: PayPeriod
    let appointments: [Appointment]
    let expenses: [Expense]
    let taxRate: Double

    private var grossIncome: Double {
        appointments
            .filter { $0.date >= period.start && $0.date <= period.end }
            .reduce(0) { $0 + $1.total }
    }

    private var totalExpenses: Double {
        expenses
            .filter { $0.date >= period.start && $0.date <= period.end }
            .reduce(0) { $0 + $1.amount }
    }

    private var net: Double     { grossIncome - totalExpenses }
    private var takeHome: Double { max(0, net) - max(0, net) * taxRate }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(period.start, style: .date) – \(period.end, style: .date)")
                    .font(.subheadline)
                Text("Gross $\(grossIncome, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("$\(takeHome, specifier: "%.2f")")
                    .fontWeight(.semibold)
                    .foregroundStyle(takeHome >= 0 ? .green : .red)
                    .monospacedDigit()
                Text("take-home")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
