import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var date = Date()
    @State private var category = ""
    @State private var amountText = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date)
                TextField("Category (e.g., Supplies, Booth rent)", text: $category)
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(category.isEmpty || Double(amountText) == nil)
                }
            }
        }
    }

    private func save() {
        let amount = Double(amountText) ?? 0
        let exp = Expense(date: date, category: category, amount: amount)
        modelContext.insert(exp)

        do {
            try modelContext.save()
            print("✅ Expense saved: \(category)")
        } catch {
            print("❌ Failed to save expense: \(error)")
        }

        dismiss()
    }
}
