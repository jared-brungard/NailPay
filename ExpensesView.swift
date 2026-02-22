import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { exp in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exp.category).font(.headline)
                        Text(exp.date, style: .date).font(.caption).foregroundStyle(.secondary)
                        Text("-$\(exp.amount, specifier: "%.2f")")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteExpenses)
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
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(expenses[index])
        }
    }
}
