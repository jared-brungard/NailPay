import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("paycheckFrequency") private var paycheckFrequency: String = "biweekly"
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var selectedPayPeriod: PayPeriod = PayPeriodHelper.currentPeriod(frequency: "biweekly")
    @State private var availablePeriods: [PayPeriod] = []
    @State private var showingAdd = false

    private var filteredExpenses: [Expense] {
        expenses.filter { $0.date >= selectedPayPeriod.start && $0.date <= selectedPayPeriod.end }
            .sorted { $0.date < $1.date }
    }

    private var periodSummary: (total: Double, count: Int) {
        let total = filteredExpenses.reduce(0) { $0 + $1.amount }
        return (total, filteredExpenses.count)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Pay Period", selection: $selectedPayPeriod) {
                    ForEach(availablePeriods, id: \.start) { period in
                        Text("\(period.start, style: .date) – \(period.end, style: .date)")
                            .tag(period)
                    }
                }
                .pickerStyle(.menu)
                .padding()

                List {
                    Section("Period Summary") {
                        HStack {
                            Text("Expenses")
                            Spacer()
                            Text("\(periodSummary.count)")
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Text("Total Expenses")
                            Spacer()
                            Text("-$\(periodSummary.total, specifier: "%.2f")")
                                .fontWeight(.semibold)
                                .monospacedDigit()
                                .foregroundStyle(.red)
                        }
                    }

                    Section("Details") {
                        if filteredExpenses.isEmpty {
                            Text("No expenses in this period")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(filteredExpenses) { exp in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(exp.category).font(.headline)
                                            Text(exp.date, style: .date).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text("-$\(exp.amount, specifier: "%.2f")")
                                            .fontWeight(.semibold)
                                            .monospacedDigit()
                                            .foregroundStyle(.red)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: deleteExpenses)
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddExpenseView()
            }
        }
        .onAppear(perform: loadAvailablePeriods)
        .onChange(of: paycheckFrequency) { _, _ in loadAvailablePeriods() }
    }

    private func loadAvailablePeriods() {
        var periods = PayPeriodHelper.pastPeriods(frequency: paycheckFrequency, count: 24)
        periods.insert(PayPeriodHelper.currentPeriod(frequency: paycheckFrequency), at: 0)
        availablePeriods = periods
        selectedPayPeriod = periods.first ?? PayPeriodHelper.currentPeriod(frequency: paycheckFrequency)
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredExpenses[index])
        }
    }
}
