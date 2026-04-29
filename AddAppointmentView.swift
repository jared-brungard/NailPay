import SwiftUI
import SwiftData

struct AppointmentFormView: View {
    let existing: Appointment?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \PaymentType.sortOrder) private var paymentTypes: [PaymentType]

    @State private var date = Date()
    @State private var clientName = ""
    @State private var serviceName = ""
    @State private var priceText = ""
    @State private var tipText = ""
    @State private var selectedPaymentTypeID: PersistentIdentifier?

    private var selectedPaymentType: PaymentType? {
        guard let id = selectedPaymentTypeID else { return paymentTypes.first }
        return paymentTypes.first(where: { $0.persistentModelID == id }) ?? paymentTypes.first
    }

    private var computedFee: Double {
        guard let pt = selectedPaymentType else { return 0 }
        let price = Double(priceText) ?? 0
        let tip = Double(tipText) ?? 0
        let total = price + tip
        return pt.feeType == "percentage" ? total * (pt.feeAmount / 100.0) : pt.feeAmount
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date)

                TextField("Client name", text: $clientName)
                TextField("Service", text: $serviceName)

                TextField("Price", text: $priceText)
                    .keyboardType(.decimalPad)

                TextField("Tip (optional)", text: $tipText)
                    .keyboardType(.decimalPad)

                Section("Payment Type") {
                    if paymentTypes.isEmpty {
                        Text("Add payment types in Settings")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        Picker("Payment Type", selection: $selectedPaymentTypeID) {
                            ForEach(paymentTypes) { pt in
                                Text("\(pt.name) (\(pt.feeLabel))")
                                    .tag(Optional(pt.persistentModelID))
                            }
                        }
                        .pickerStyle(.menu)

                        HStack {
                            Text("Transaction Fee")
                            Spacer()
                            Text("$\(computedFee, specifier: "%.2f")")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle(existing == nil ? "New Appointment" : "Edit Appointment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(clientName.isEmpty || serviceName.isEmpty || Double(priceText) == nil)
                }
            }
            .onAppear { populate() }
        }
    }

    private func populate() {
        if let appt = existing {
            date = appt.date
            clientName = appt.clientName
            serviceName = appt.serviceName
            priceText = String(appt.price)
            tipText = appt.tip == 0 ? "" : String(appt.tip)
            if let typeName = appt.paymentTypeName,
               let match = paymentTypes.first(where: { $0.name == typeName }) {
                selectedPaymentTypeID = match.persistentModelID
            } else if selectedPaymentTypeID == nil {
                selectedPaymentTypeID = paymentTypes.first?.persistentModelID
            }
        } else if selectedPaymentTypeID == nil {
            selectedPaymentTypeID = paymentTypes.first?.persistentModelID
        }
    }

    private func save() {
        let price = Double(priceText) ?? 0
        let tip = Double(tipText) ?? 0
        let pt = selectedPaymentType

        if let appt = existing {
            appt.date = date
            appt.clientName = clientName
            appt.serviceName = serviceName
            appt.price = price
            appt.tip = tip
            appt.paymentTypeName = pt?.name
            appt.fee = computedFee
        } else {
            let appt = Appointment(
                date: date,
                clientName: clientName,
                serviceName: serviceName,
                price: price,
                tip: tip,
                paymentTypeName: pt?.name,
                fee: computedFee
            )
            modelContext.insert(appt)
        }

        try? modelContext.save()
        dismiss()
    }
}
