import SwiftUI
import SwiftData
import Foundation

enum DashboardViewMode: String, CaseIterable, Identifiable {
    case payPeriod = "Pay Period"
    case monthly   = "Monthly"
    case annual    = "Annual"
    var id: String { rawValue }
}

struct DashboardView: View {
    @AppStorage("paycheckModeEnabled") private var paycheckModeEnabled: Bool = false
    @AppStorage("paycheckFrequency")   private var paycheckFrequency: String = "biweekly"

    @State private var viewMode: DashboardViewMode = .payPeriod
    @State private var currentPayPeriod: PayPeriod = PayPeriodHelper.currentPeriod(frequency: "biweekly")
    @State private var currentMonthAnchor: Date = Date()
    @State private var currentYearAnchor: Date = Date()

    @Query private var appointments: [Appointment]
    @Query private var expenses: [Expense]
    @Query private var recurringExpenses: [RecurringExpense]

    private var dateRange: (start: Date, end: Date) {
        let cal = Calendar.current
        switch viewMode {
        case .payPeriod:
            return (currentPayPeriod.start, currentPayPeriod.end)
        case .monthly:
            let start = cal.dateInterval(of: .month, for: currentMonthAnchor)?.start ?? currentMonthAnchor
            let end = cal.dateInterval(of: .month, for: currentMonthAnchor)
                .flatMap { cal.date(byAdding: .second, value: -1, to: $0.end) } ?? currentMonthAnchor
            return (start, end)
        case .annual:
            let start = cal.dateInterval(of: .year, for: currentYearAnchor)?.start ?? currentYearAnchor
            let end = cal.dateInterval(of: .year, for: currentYearAnchor)
                .flatMap { cal.date(byAdding: .second, value: -1, to: $0.end) } ?? currentYearAnchor
            return (start, end)
        }
    }

    private var filteredAppointments: [Appointment] {
        appointments.filter { $0.date >= dateRange.start && $0.date <= dateRange.end }
    }

    private var filteredExpenses: [Expense] {
        expenses.filter { $0.date >= dateRange.start && $0.date <= dateRange.end }
    }

    private var availablePayPeriods: [PayPeriod] {
        let current = PayPeriodHelper.currentPeriod(frequency: paycheckFrequency)
        let past = PayPeriodHelper.pastPeriods(frequency: paycheckFrequency, count: 24)
        return [current] + past
    }

    private var availableMonths: [Date] {
        let cal = Calendar.current
        let today = Date()
        var months: [Date] = []
        for i in 0...24 {
            if let d = cal.date(byAdding: .month, value: -i, to: today),
               let start = cal.dateInterval(of: .month, for: d)?.start {
                months.append(start)
            }
        }
        return months
    }

    private var availableYears: [Date] {
        let cal = Calendar.current
        let today = Date()
        var years: [Date] = []
        for i in 0...10 {
            if let d = cal.date(byAdding: .year, value: -i, to: today),
               let start = cal.dateInterval(of: .year, for: d)?.start {
                years.append(start)
            }
        }
        return years
    }

    private func monthLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    private func yearLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f.string(from: date)
    }

    private func payPeriodLabel(_ period: PayPeriod) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return "\(f.string(from: period.start)) – \(f.string(from: period.end))"
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

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("View", selection: $viewMode) {
                        ForEach(DashboardViewMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(viewMode.rawValue) {
                    switch viewMode {
                    case .payPeriod:
                        Picker("Select Period", selection: $currentPayPeriod) {
                            ForEach(availablePayPeriods, id: \.self) { p in
                                Text(payPeriodLabel(p)).tag(p)
                            }
                        }
                        .pickerStyle(.menu)
                    case .monthly:
                        Picker("Select Month", selection: $currentMonthAnchor) {
                            ForEach(availableMonths, id: \.self) { m in
                                Text(monthLabel(m)).tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                    case .annual:
                        Picker("Select Year", selection: $currentYearAnchor) {
                            ForEach(availableYears, id: \.self) { y in
                                Text(yearLabel(y)).tag(y)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                Section("\(viewMode.rawValue) Totals") {
                    let income = filteredAppointments.reduce(0) { $0 + $1.total }
                    let fees = filteredAppointments.reduce(0) { $0 + $1.fee }
                    let expenses = filteredExpenses.reduce(0) { $0 + $1.amount }
                    row("Income", income)
                    row("Transaction Fees", -fees)
                    row("Expenses", -expenses)
                    row("Profit", income - fees - expenses)
                }

                Section("Federal Tax Estimate (Projected to Year-End)") {
                    let ytdIncome = appointments.reduce(0) { $0 + $1.total }
                    let ytdFees = appointments.reduce(0) { $0 + $1.fee }
                    let ytdExpenses = expenses.reduce(0) { $0 + $1.amount } + ytdFees
                    let taxEstimate = TaxCalculator.calculateAnnualTaxes(
                        ytdIncome: ytdIncome,
                        ytdExpenses: ytdExpenses,
                        currentDate: Date.now
                    )

                    HStack {
                        Text("Projected Income")
                        Spacer()
                        Text("$\(taxEstimate.projectedYearlyIncome, specifier: "%.2f")")
                            .monospacedDigit()
                    }
                    HStack {
                        Text("Self-Employment Tax")
                        Spacer()
                        Text("$\(taxEstimate.selfEmploymentTax, specifier: "%.2f")")
                            .monospacedDigit()
                    }
                    HStack {
                        Text("Federal Income Tax")
                        Spacer()
                        Text("$\(taxEstimate.federalIncomeTax, specifier: "%.2f")")
                            .monospacedDigit()
                    }
                    HStack {
                        Text("Total Tax Liability")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("$\(taxEstimate.totalTaxLiability, specifier: "%.2f")")
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                    HStack {
                        Text("Quarterly Estimated Tax")
                            .font(.subheadline)
                        Spacer()
                        Text("$\(taxEstimate.quarterlyEstimatedTax, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
                if paycheckModeEnabled {
                    Section("Paycheck") {
                        let period = PayPeriodHelper.currentPeriod(frequency: paycheckFrequency)
                        let periodAppts = appointments
                            .filter { $0.date >= period.start && $0.date <= period.end }
                        let periodIncome = periodAppts.reduce(0) { $0 + $1.total }
                        let periodFees = periodAppts.reduce(0) { $0 + $1.fee }
                        let periodExpenses = expenses
                            .filter { $0.date >= period.start && $0.date <= period.end }
                            .reduce(0) { $0 + $1.amount }
                        let net = periodIncome - periodFees - periodExpenses
                        let ytdIncome = appointments.reduce(0) { $0 + $1.total }
                        let ytdFees = appointments.reduce(0) { $0 + $1.fee }
                        let ytdExpenses = expenses.reduce(0) { $0 + $1.amount } + ytdFees
                        let annual = TaxCalculator.calculateAnnualTaxes(
                            ytdIncome: ytdIncome,
                            ytdExpenses: ytdExpenses,
                            currentDate: Date.now
                        )
                        let effRate = annual.netProfit > 0 ? min(1, annual.totalTaxLiability / annual.netProfit) : 0
                        let takeHome = max(0, net) - max(0, net) * effRate

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
                    Button("Load Beginner (~$30k/yr)") {
                        loadProfile(DemoData.beginner)
                    }
                    Button("Load Established (~$50k/yr)") {
                        loadProfile(DemoData.established)
                    }
                    Button("Load Senior (~$115k/yr)") {
                        loadProfile(DemoData.senior)
                    }

                    Button("Clear All Data", role: .destructive) {
                        do {
                            try modelContext.delete(model: Appointment.self)
                            try modelContext.delete(model: Expense.self)
                            try modelContext.delete(model: RecurringExpense.self)
                            try modelContext.save()
                            importMessage = "All data cleared."
                        } catch {
                            importMessage = "Clear failed: \(error.localizedDescription)"
                        }
                    }

                    if let message = importMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Dashboard")
        }
        .onAppear {
            RecurringExpenseHelper.processRecurringExpenses(
                modelContext: modelContext,
                recurringExpenses: recurringExpenses
            )
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

    private func loadProfile(_ profile: DemoData.Profile) {
        do {
            try DemoData.load(profile: profile, modelContext: modelContext)
            importMessage = "Loaded: \(profile.label)"
        } catch {
            importMessage = "Load failed: \(error.localizedDescription)"
        }
    }
}
