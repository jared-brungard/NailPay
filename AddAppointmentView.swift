import SwiftUI
import SwiftData

struct AddAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var date = Date()
    @State private var clientName = ""
    @State private var serviceName = ""
    @State private var priceText = ""
    @State private var tipText = ""

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
            }
            .navigationTitle("New Appointment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(clientName.isEmpty || serviceName.isEmpty || Double(priceText) == nil)
                }
            }
        }
    }

    private func save() {
        let price = Double(priceText) ?? 0
        let tip = Double(tipText) ?? 0

        let appt = Appointment(date: date, clientName: clientName, serviceName: serviceName, price: price, tip: tip)
        modelContext.insert(appt)
        dismiss()
    }
}
