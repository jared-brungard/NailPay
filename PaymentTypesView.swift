import SwiftUI
import SwiftData

struct PaymentTypesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PaymentType.sortOrder) private var paymentTypes: [PaymentType]

    @State private var showingAdd = false
    @State private var editingType: PaymentType?

    var body: some View {
        List {
            ForEach(paymentTypes) { pt in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pt.name).font(.headline)
                        Text(pt.feeType == "percentage" ? "Percentage fee" : "Flat fee")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(pt.feeLabel)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture { editingType = pt }
            }
            .onDelete(perform: deletePaymentTypes)
        }
        .navigationTitle("Payment Types")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            PaymentTypeFormView(existingType: nil)
        }
        .sheet(item: $editingType) { pt in
            PaymentTypeFormView(existingType: pt)
        }
        .onAppear { seedDefaultPaymentTypesIfNeeded() }
    }

    private func deletePaymentTypes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(paymentTypes[index])
        }
    }

    private func seedDefaultPaymentTypesIfNeeded() {
        guard paymentTypes.isEmpty else { return }
        let defaults: [(String, String, Double, Int)] = [
            ("Cash",        "percentage", 0.0, 0),
            ("Credit Card", "percentage", 2.9, 1),
            ("Venmo",       "percentage", 1.8, 2),
            ("Zelle",       "percentage", 0.0, 3),
            ("Check",       "flat",       0.0, 4),
        ]
        for (name, feeType, feeAmount, order) in defaults {
            modelContext.insert(PaymentType(name: name, feeType: feeType, feeAmount: feeAmount, sortOrder: order))
        }
    }
}

struct PaymentTypeFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let existingType: PaymentType?

    @State private var name: String = ""
    @State private var feeType: String = "percentage"
    @State private var feeAmountText: String = ""

    private var isSaveDisabled: Bool {
        name.isEmpty || Double(feeAmountText) == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Venmo", text: $name)
                }
                Section("Fee") {
                    Picker("Fee Type", selection: $feeType) {
                        Text("Percentage (%)").tag("percentage")
                        Text("Flat ($)").tag("flat")
                    }
                    TextField(feeType == "percentage" ? "e.g. 2.9" : "e.g. 0.30",
                              text: $feeAmountText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(existingType == nil ? "New Payment Type" : "Edit Payment Type")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(isSaveDisabled)
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    private func populateIfEditing() {
        guard let pt = existingType else { return }
        name = pt.name
        feeType = pt.feeType
        feeAmountText = String(pt.feeAmount)
    }

    private func save() {
        let amount = Double(feeAmountText) ?? 0
        if let pt = existingType {
            pt.name = name
            pt.feeType = feeType
            pt.feeAmount = amount
        } else {
            let nextOrder = (try? modelContext.fetch(FetchDescriptor<PaymentType>()).count) ?? 0
            modelContext.insert(PaymentType(name: name, feeType: feeType, feeAmount: amount, sortOrder: nextOrder))
        }
        dismiss()
    }
}
