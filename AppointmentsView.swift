import SwiftUI
import SwiftData

struct AppointmentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Appointment.date, order: .reverse) private var appointments: [Appointment]

    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(appointments) { appt in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appt.clientName).font(.headline)
                        Text(appt.serviceName).font(.subheadline).foregroundStyle(.secondary)
                        Text(appt.date, style: .date).font(.caption).foregroundStyle(.secondary)

                        Text("$\(appt.total, specifier: "%.2f")")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteAppointments)
            }
            .navigationTitle("Appointments")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddAppointmentView()
            }
        }
    }

    private func deleteAppointments(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(appointments[index])
        }
    }
}
