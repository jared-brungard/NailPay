import SwiftUI
import SwiftData

struct PastPaychecksView: View {
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
                            frequencyLabel: frequencyLabel
                        )
                        .navigationTitle("\(period.start, style: .date)")
                    } label: {
                        PastPaycheckRow(
                            period: period,
                            appointments: appointments,
                            expenses: expenses
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

    private var periodAppointments: [Appointment] {
        appointments.filter { $0.date >= period.start && $0.date <= period.end }
    }

    private var grossIncome: Double {
        periodAppointments.reduce(0) { $0 + $1.total }
    }

    private var fees: Double {
        periodAppointments.reduce(0) { $0 + $1.fee }
    }

    private var totalExpenses: Double {
        expenses
            .filter { $0.date >= period.start && $0.date <= period.end }
            .reduce(0) { $0 + $1.amount } + fees
    }

    private var effectiveTaxRate: Double {
        let ytdIncome = appointments.reduce(0) { $0 + $1.total }
        let ytdFees = appointments.reduce(0) { $0 + $1.fee }
        let ytdExpenses = expenses.reduce(0) { $0 + $1.amount } + ytdFees
        let estimate = TaxCalculator.calculateAnnualTaxes(
            ytdIncome: ytdIncome,
            ytdExpenses: ytdExpenses,
            currentDate: Date.now
        )
        guard estimate.netProfit > 0 else { return 0 }
        return min(1, estimate.totalTaxLiability / estimate.netProfit)
    }

    private var net: Double     { grossIncome - totalExpenses }
    private var takeHome: Double { max(0, net) - max(0, net) * effectiveTaxRate }

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
