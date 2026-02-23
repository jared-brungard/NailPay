import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var filter: TimeFilter = .month
    @State private var showingAdd = false

    private func filteredExpenses() -> [Expense] {
        let (start, end) = DateRangeHelper.range(for: filter)
        guard let start, let end else { return expenses }
        return expenses.filter { $0.date >= start && $0.date < end }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredExpenses()) { exp in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exp.category).font(.headline)
                        Text(exp.date, style: .date).font(.caption).foregroundStyle(.secondary)
                        Text("-$\(exp.amount, specifier: "%.2f")").font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteExpenses)
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("", selection: $filter) {
                        ForEach(TimeFilter.allCases) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddExpenseView()
            }
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        let current = filteredExpenses()
        for index in offsets {
            modelContext.delete(current[index])
        }
    }
} 
